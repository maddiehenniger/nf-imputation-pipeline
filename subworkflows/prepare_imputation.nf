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
        phased_samples
    
    main:
    
        chunk_samples(
            phased_samples
        )
    
    emit:
        chunked_regions      = chunk_samples.out.chunkedRegions
 }