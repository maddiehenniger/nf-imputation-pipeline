include { impute5_impute_samples } from '../modules/impute5_impute_samples.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Intermediate_Imputation {
    take:
        intermediate_chunked_regions
        intermediate_ref_xcf
    
    main:
        impute5_impute_samples(
            intermediate_chunked_regions,
            intermediate_ref_xcf
        )

    emit: 
        imputed_intermediate_samples = impute5_impute_samples.out.intermediateImputation
}