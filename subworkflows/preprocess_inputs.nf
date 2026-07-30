include { bcftools_fill_tags } from '../modules/bcftools_fill_tags.nf'
include { bcftools_identify_chromosomes } from '../modules/bcftools_identify_chromosomes.nf'
include { bcftools_split_samples } from '../modules/bcftools_split_samples.nf'
include { convert_reference_to_xcf } from '../modules/impute5/convert_reference_to_xcf.nf'
include { convert_reference_to_xcf as convert_reference_two_to_xcf } from '../modules/impute5/convert_reference_to_xcf.nf'
include { glimpse2_chunk } from '../modules/glimpse2/glimpse2_chunk.nf'
include { glimpse2_split_reference } from '../modules/glimpse2/glimpse2_split_reference.nf'
include { samtools_identify_chromosomes } from '../modules/samtools_identify_chromosomes.nf'
include { samtools_split_samples } from '../modules/samtools_split_samples.nf'
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
    
    main:        
        // TODO: Detect if the indexed files are present for test samples and references. If yes, skip indexing. If not, index.

        // Determine file extension - expects (case insensitive) bam, cram, vcf, vcf.gz, or bcf file
        samples_process = samples.branch {
            bam: it[1].name.toLowerCase().endsWith('.bam') ||
                 it[1].name.toLowerCase().endsWith('.cram')
            vcf: it[1].name.toLowerCase().endsWith('.vcf') ||
                 it[1].name.toLowerCase().endsWith('vcf.gz') ||
                 it[1].name.toLowerCase().endsWith('bcf')
            unknown: true
        } 

        // Print error if detection goes wrong at the above step
        samples_process.bam.count()
            .combine(samples_process.vcf.count())
            .subscribe { bamCount, vcfCount ->
                if (bamCount > 0 && vcfCount > 0) {
                    error "\n[ERROR]: Mixed file extensions present in the input files.\n" +
                        "Your input contains $bamCount BAM/CRAM files AND $vcfCount BCF/VCF(.gz) files.\n" +
                        "Please provide only prove either BAM/CRAM files, OR BCF/VCF(.gz) files."
                }
                if (bamCount == 0 && vcfCount == 0) {
                    error "\n[ERROR]: No valid input files found.\n" +
                        "Check your file extensions (.bam, .cram, .vcf, .vcf.gz, .bcf)."
                }

                def type = bamCount > 0 ? "BAM/CRAM" : "BCF/VCF(.gz)"
                def counter = bamCount > 0 ? bamCount : vcfCount
                log.info "[IMPUTATION PIPELINE] Processing $counter provided $type files..."
            }

        // BAM FILE PROCESSING
        // Identify the chromosomes present in each sample
        samtools_identity_chromosomes(
            samples_process.bam
        )

        ch_bam_split = samtools_identify_chromosomes.out
            .flatMap { meta, chrom_string, path, idx, ped ->
                chrom_string.trim().split('\n').findAll { it }.collect { chr ->
                    [ meta, chr, path, idx, ped ]
                }
            }
            | samtools_split_samples
        
        // Map to standard format: [chr, meta, sample, idx, ped]
        ch_bams = samtools_split_samples.out.splitSamples.
            .flatmap { meta, chr, sample, idx, ped ->
                def chrom_list = chrom_string.trim().split('\n')
                def chromosomes = chrom_list.collect { chr ->
                    [ meta, chr, samplePath, sampleIndex, pedigree ]
                 }
                
                return chromosomes
        }
        .set { ch_chromosomes_bams }

        // VCF FILE PROCESSING
        // Identify the chromosomes present in each sample
        bcftools_identify_chromosomes(
            samples_process.vcf
        )
            
        // Wrangles the output to add chromosome information into the channel
        ch_vcfs_split = bcftools_identify_chromosomes.out            
            .flatMap { meta, chrom_string, samplePath, sampleIndex, pedigree ->
                def chrom_list = chrom_string.trim().split('\n')
                def chromosomes = chrom_list.collect { chr ->
                    [ meta, chr, samplePath, sampleIndex, pedigree ]
                }

                return chromosomes
            }
            | bcftools_split_samples
            | bcftools_fill_tags
        
        // Change the chromosome value to string for downstream merging
        bcftools_fill_tags.out.filledTags.map { meta, chr, sample, sampleIdx, ped ->
            [ chr.toString(), meta, sample, sampleIdx, ped ]
        }
        .set { ch_chromosomes_vcfs }

        // Prepare reference panels for imputation
        switch( dataType.toUpperCase() ) {
            // If the input samples are specified to be arrays, the reference panels are converted to XCF
            case 'ARRAY':
                // Convert the reference identified for "round one" of imputation to XCF format
                convert_reference_to_xcf(
                    reference_one
                )
                // Wrangles the channel to convert the chromosome to a string, and flattens the XCF associated files together
                convert_reference_to_xcf.out.xcfReference.map { meta, refPath, refIdx, refBin, refFam, mapPath ->
                    [ meta.chromosome.toString(), meta, refPath, [refIdx, refBin, refFam].flatten(), mapPath ]
                }
                .set { ch_reference_one }
                
                // If a Round Two imputation reference is provided, it will convert the specified reference to XCF format
                convert_reference_two_to_xcf(
                    reference_two
                )
                // Wrangles the channel to convert the chromosome to a string, and flattens the XCF associated files together
                convert_reference_two_to_xcf.out.xcfReference.map { meta, refPath, refIdx, refBin, refFam, mapPath ->
                    [ meta.chromosome.toString(), meta, refPath, [refIdx, refBin, refFam].flatten(), mapPath ]
                }
                .set { ch_reference_two }
                break

            // If the input samples are specified to be from low-pass WGS, the reference panels are assessed for imputation/buffer regions (chunked) and then converted to GLIMPSE2 binary format
            case 'LPWGS':
                glimpse2_chunk(
                    reference_one
                )
                ch_reference_one = glimpse2_chunk.out.chunkedRegions

                glimpse2_split_reference(
                    ch_reference_one
                )
                ch_reference_one = glimpse2_split_reference.out.chunkedReference
                ch_reference_two = Channel.empty()
                break
        }

        ch_samples     = ch_chromosomes_bams.mix(ch_chromosomes_vcfs)
        ch_samples_one = ch_samples.combine(ch_reference_one, by:0)

    emit:
        samples_one   = ch_samples_one
        chromosomes   = ch_chromosomes // Testing
        reference_one = ch_reference_one
        reference_two = ch_reference_two
}