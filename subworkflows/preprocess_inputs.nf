include { bcftools_fill_tags } from '../modules/bcftools_fill_tags.nf'
include { bcftools_identify_chromosomes } from '../modules/bcftools_identify_chromosomes.nf'
include { bcftools_split_samples } from '../modules/bcftools_split_samples.nf'
include { convert_reference_to_xcf } from '../modules/impute5/convert_reference_to_xcf.nf'
include { convert_reference_to_xcf as convert_reference_two_to_xcf } from '../modules/impute5/convert_reference_to_xcf.nf'
include { glimpse2_chunk } from '../modules/glimpse2/glimpse2_chunk.nf'
include { glimpse2_split_reference } from '../modules/glimpse2/glimpse2_split_reference.nf'
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

        // Identify the chromosomes present in each sample
        bcftools_identify_chromosomes(
            samples
        )
        
        // Wrangles the output to add chromosome information into the channel
        bcftools_identify_chromosomes.out            
            .flatMap { meta, chrom_string, samplePath, sampleIndex, wgsPath, wgsIndex ->
                def chrom_list = chrom_string.trim().split('\n')
                def chromosomes = chrom_list.collect { chr ->
                    [ meta, chr, samplePath, sampleIndex, wgsPath, wgsIndex ]
                }

                return chromosomes
            }
            .set { ch_chromosomes }

        // Split samples by chromosome using bcftools view
        bcftools_split_samples(
            ch_chromosomes
        )

        // Make sure the AC/AN tags are filled
        bcftools_fill_tags(
            ch_chromosomes
        )
        // Change the chromosome value to string for downstream merging
        bcftools_fill_tags.out.filledTags.map { meta, chr, sample, sampleIdx, wgs, wgsIdx ->
            [ chr.toString(), meta, sample, sampleIdx, wgs, wgsIdx ]
        }
        .set { ch_split_samples }

        // Prepare reference panels for imputation
        switch( dataType.toUpperCase() ) {
            // If the input samples are specified to be arrays, the reference panels are converted to XCF
            case 'ARRAY':
                // Convert the reference identified for "round one" of imputation to XCF format
                convert_reference_to_xcf(
                    reference_one
                )
                // Wrangles the channel to convert the chromosome to a string, and flattens the XCF assocaited files together
                convert_reference_to_xcf.out.xcfReference.map { meta, refPath, refIdx, refBin, refFam, mapPath ->
                    [ meta.chromosome.toString(), meta, refPath, [refIdx, refBin, refFam].flatten(), mapPath ]
                }
                .set { ch_reference_one }
                
                // If a Round Two imputation reference is provided, it will convert the specified reference to XCF format
                convert_reference_two_to_xcf(
                    reference_two
                )
                // Wrangles the channel to convert the chromosome to a string, and flattens the XCF assocaited files together
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
                break
        }

        ch_samples_one = ch_split_samples.combine(ch_reference_one, by:0)

    emit:
        // splitSamples  = ch_split_samples 
        samples_one   = ch_samples_one
        chromosomes   = ch_chromosomes // Testing
        reference_one = ch_reference_one
        reference_two = ch_reference_two
}