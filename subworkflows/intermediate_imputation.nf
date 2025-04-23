include { impute5_impute_samples        } from '../modules/impute5_impute_samples.nf'
include { bcftools_concat_by_chromosome } from '../modules/ligate_samples_by_chromosome.nf'

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

        imputed_intermediate_samples = impute5_impute_samples.out.intermediateImputation

        bcftools_concat_by_chromosome(
            imputed_intermediate_samples
        )

    emit: 
        imputed_intermediate_samples = impute5_impute_samples.out.intermediateImputation
        intermediate_by_chromosomes  = bcftools_concat_by_chromosome.out.intermediateByChromosome
}