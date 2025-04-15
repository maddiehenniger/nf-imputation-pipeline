include { impute5_impute_samples } from '../modules/impute5_impute_samples.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Intermediate_Imputation {
    take:
        indexed_phased_pair
        chromosomes
        intermediate_ref_xcf
        chunked_regions
    
    main:
        impute5_impute_samples(
            
        )

    emit:
        
}