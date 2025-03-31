include { chunk_samples           } from "../modules/chunk_samples.nf"
// include { convert_xcf             } from "../modules/convert_xcf.nf"

/**
 * Prepares the samples and references for imputation. 
 * 
 * 
 *
 * @take 
 * @emit 
 */

 workflow Prepare_Imputation {
    take:
        reference_intermediate
        phased_samples
        chromosomes
    
    main:
        chunk_samples(
            reference_intermediate,
            phased_samples,
            chromosomes
        )
    
        chunked_regions = chunk_samples.out.chunkedRegions

 }