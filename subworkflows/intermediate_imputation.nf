include { impute5_impute_samples } from '../modules/impute5_impute_samples.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Intermediate_Imputation {
    take:
        indexed_phased_pair
        intermediate_ref_xcf
        chunked_regions
    
    main:
        impute5_impute_samples(
            indexed_phased_pair,
            intermediate_ref_xcf,
            chunked_regions
        )

    emit: 
        imputed_intermediate_samples = impute5_impute_samples.out.intermediateImputation
}