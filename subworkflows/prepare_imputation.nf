include { chunk_samples           } from "../modules/chunk_samples.nf"

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
        indexed_phased_pair
    
    main:
        chunk_samples(
            indexed_phased_pair
        )
    
    emit:
        intermediate_chunked_regions      = chunk_samples.out.chunkedRegions
 }