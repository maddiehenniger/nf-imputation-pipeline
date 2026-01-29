include { bcftools_identify_chromosomes } from '../modules/bcftools_identify_chromosomes.nf'
include { bcftools_split_samples        } from '../modules/bcftools_split_samples.nf'
include { convert_reference_to_xcf      } from '../impute5/convert_reference_to_xcf.nf'
include { convert_reference_to_xcf as convert_reference_two_to_xcf     } from '../impute5/convert_reference_to_xcf.nf'
/**
 * Index and query the number of chromosomes present in the input VCF/BCF files provided in the user-provided samplesheet and reference(s) files.
 * 
 * Tuples the VCF/BCF file and associated index together for downs
 * Wrangles the input samples into the format of channels expected by downstream processes.
 *
 * @take samples, references - A LinkedHashMap containing the metadata, file path to VCF/BCF, and file path to the associated indexed VCF/BCF file. 
 * @emit chromosomes - chromosome numbers present in a respective file.
 **/

workflow Preprocess_Inputs {
    take:
        samples
        reference_one
        reference_two
    
    main:        
        // TODO: Index the samples if index files are not provided

        // Identify the chromosomes present in each sample
        bcftools_identify_chromosomes(
            samples
        )
        bcftools_identify_chromosomes.out            
            .flatMap { meta, chrom_string, samplePath, sampleIndex, wgsPath, wgsIndex ->
                def chrom_list = chrom_string.trim().split('\n')
                def chromosomes = chrom_list.collect { chr ->
                    [ meta, chr, samplePath, sampleIndex, wgsPath, wgsIndex ]
                }

                return chromosomes
            }
            .set { ch_chromosomes }

        // Split samples by chromosome
        bcftools_split_samples(
            ch_chromosomes
        )

        ch_split_samples = bcftools_split_samples.out.splitSamples

        // Prepare reference panels for imputation
        switch( data_type.toUpperCase() ) {
            // If the input samples are specified to be arrays, the reference panels are converted to XCF
            case 'ARRAY':
                // Convert the reference identified for "round one" of imputation to XCF format
                convert_reference_to_xcf(
                    reference_one
                )
                ch_reference_one = convert_reference_to_xcf.out.xcfReference
                
                // If a Round Two imputation reference is provided, it will convert the specified reference to XCF format
                convert_reference_two_to_xcf(
                    reference_two
                )
                ch_reference_two = convert_reference_two_to_xcf.out.xcfReference
                break
            
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


    emit:
        splitSamples  = ch_split_samples
        chromosomes   = ch_chromosomes // Don't think we need this to follow downstream but in for testing
        reference_one = ch_reference_one
        reference_two = ch_reference_two
}