include { bcftools_fill_tags } from '../modules/bcftools_fill_tags.nf'
include { bcftools_identify_chromosomes } from '../modules/bcftools_identify_chromosomes.nf'
include { bcftools_split_samples } from '../modules/bcftools_split_samples.nf'
include { convert_reference_to_xcf } from '../modules/impute5/convert_reference_to_xcf.nf'
include { convert_reference_to_xcf as convert_reference_two_to_xcf } from '../modules/impute5/convert_reference_to_xcf.nf'
include { glimpse2_chunk } from '../modules/glimpse2/glimpse2_chunk.nf'
include { glimpse2_split_reference } from '../modules/glimpse2/glimpse2_split_reference.nf'
include { samtools_identify_chromosomes } from '../modules/samtools_identify_chromosomes.nf'
// include { samtools_split_samples } from '../modules/samtools_split_samples.nf'
/**
 * Preprocess_Inputs:
 * For test samples: Identifes the number of chromosomes present in the test samples and then splits the samples by chromosome, providing the associated index.
 * For references: If the test samples are array genotypes, the reference panel (for both rounds) is converted to XCF format. 
 *                 If the test samples are from low-pass WGS, the reference panel is chunked into imputation/buffer regions and then converted to GLIMPSE2-binary format.
 * 
 * Then, test samples are tupled together by chromosome with their appropriate reference panel to ensure proper imputation.
 * The resultant channel is wrangled into the format expected for downstream processes. 
 *
 * @take 
 * @emit 
 **/
    
workflow Preprocess_Inputs {
    take:
        samples
        reference_one
        reference_two
        dataType
        glimpse2Model
    
    main:        
        // Determine file extension
        samples_process = samples.branch { meta, path, index, pedigree ->
            def ext = path.toString().toLowerCase()
            bam: ext.endsWith('.bam') ||
                 ext.endsWith('.cram')
            vcf: ext.endsWith('.vcf') ||
                 ext.endsWith('vcf.gz') ||
                 ext.endsWith('bcf')
            unknown: true
        } 

        // Error handling for mixed or missing files
        samples_process.bam.count()
            .combine(samples_process.vcf.count())
            .subscribe { bamCount, vcfCount ->
                if (bamCount > 0 && vcfCount > 0) {
                    error "\n[ERROR]: Mixed or unknown file extensions present in the input files: ${it[1]}. Only BAM/CRAM -OR- BCF/VCF(.gz) are supported."
                }
                if (bamCount == 0 && vcfCount == 0) {
                    error "\n[ERROR]: No valid input files found."
                }
                def type = bamCount > 0 ? "BAM/CRAM" : "BCF/VCF(.gz)"
                def counter = bamCount > 0 ? bamCount : vcfCount
                log.info "[IMPUTATION PIPELINE] Processing $counter $type file(s)..."
            }

        // BAM FILE PROCESSING
        samtools_identify_chromosomes(samples_process.bam)

        // Split chromosomes into individual channel items
        ch_bam_split = samtools_identify_chromosomes.out
            .flatMap { meta, chrom_string, path, idx, ped ->
                chrom_string.trim().split('\n').findAll { it }.collect { chr ->
                    [ chr.trim(), meta, path, idx, ped ]
                }
            }

        // TESTING IF WE SHOULD JUST HAVE THE WHOLE FILE GO?
        // samtools_split_samples(ch_bam_split)
        
        // Map to standard format: [chr, meta, sample, idx, ped]
        //ch_chromosomes_bams = samtools_split_samples.out.splitSamples
        //    .map { meta, chr, sample, idx, ped ->
        //        [ chr.toString(), meta, sample, idx, ped ]
        //    }

        // VCF FILE PROCESSING
        bcftools_identify_chromosomes(samples_process.vcf)
            
        ch_vcfs_split = bcftools_identify_chromosomes.out            
            .flatMap { meta, chrom_string, samplePath, sampleIndex, pedigree ->
                def chrom_list = chrom_string.trim().split('\n').findAll { it }
                chrom_list.collect { chr ->
                    [ meta, chr.trim(), samplePath, sampleIndex, pedigree ]
                }
            }
        
        bcftools_split_samples(ch_vcfs_split)
        bcftools_fill_tags(bcftools_split_samples.out)
        
        ch_chromosomes_vcfs = bcftools_fill_tags.out.filledTags.map { meta, chr, sample, sampleIdx, ped ->
            [ chr.toString(), meta, sample, sampleIdx, ped ]
        }

        // Initialize reference channels to avoid "undefined" errors
        ch_reference_one = Channel.empty()
        ch_reference_two = Channel.empty()

        // Prepare reference panels
        switch( dataType.toUpperCase() ) {
            case 'ARRAY':
                convert_reference_to_xcf(reference_one)
                ch_reference_one = convert_reference_to_xcf.out.xcfReference.map { meta, refPath, refIdx, refBin, refFam, mapPath ->
                    [ meta.chromosome.toString(), meta, refPath, [refIdx, refBin, refFam].flatten(), mapPath ]
                }
                
                convert_reference_two_to_xcf(reference_two)
                ch_reference_two = convert_reference_two_to_xcf.out.xcfReference.map { meta, refPath, refIdx, refBin, refFam, mapPath ->
                    [ meta.chromosome.toString(), meta, refPath, [refIdx, refBin, refFam].flatten(), mapPath ]
                }
                break

            case 'LPWGS':
                glimpse2_chunk(
                    reference_one,
                    glimpse2Model
                )
                glimpse2_split_reference(glimpse2_chunk.out.chunkedRegions)
                ch_reference_one = glimpse2_split_reference.out.chunkedReference
                break
        }

        ch_samples = ch_bam_split.mix(ch_chromosomes_vcfs)
        ch_samples_one = ch_samples.combine(ch_reference_one, by: 0)

    emit:
        samples_one   = ch_samples_one
        chromosomes   = ch_samples
        reference_one = ch_reference_one
        reference_two = ch_reference_two
}