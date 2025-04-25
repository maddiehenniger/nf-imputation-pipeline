include { impute5_impute_samples        } from '../modules/impute5_impute_samples.nf'
include { bcftools_concat_by_chromosome } from '../modules/ligate_samples_by_chromosome.nf'
include { bcftools_concat_by_sample     } from '../modules/ligate_samples.nf'
include { bcftools_index_imputed        } from '../modules/bcftools_index_imputed.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Perform_Intermediate_Imputation {
    take:
        intermediate_chunked_regions
        intermediate_ref_xcf
    
    main:
        impute5_impute_samples(
            intermediate_chunked_regions,
            intermediate_ref_xcf
        )

        imputed_intermediate_samples = impute5_impute_samples.out.imputedSamples

        bcftools_concat_by_chromosome(
            imputed_intermediate_samples
        )

        intermediate_by_chr = bcftools_concat_by_chromosome.out.ligatedByChromosome

        bcftools_concat_by_sample(
            intermediate_by_chr
        )

        intermediate_imputed_joined_samples = bcftools_concat_by_sample.out.ligatedAllChromosomes

        bcftools_index_imputed(
            intermediate_imputed_joined_samples
        )

    emit: 
        imputed_intermediate_samples        = impute5_impute_samples.out.imputedSamples
        intermediate_by_chromosomes         = bcftools_concat_by_chromosome.out.ligatedByChromosome
        intermediate_imputed_joined_samples = bcftools_concat_by_sample.out.ligatedAllChromosomes
        intermediate_imputed_paired         = bcftools_index_imputed.out.indexedIntermediatePaired
}