include { impute5_impute_samples        } from '../modules/impute5_impute_samples.nf'
include { bcftools_concat_by_chromosome } from '../modules/ligate_samples_by_chromosome.nf'
include { bcftools_concat_by_sample     } from '../modules/ligate_samples.nf'
include { bcftools_index_imputed        } from '../modules/bcftools_index_imputed.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Intermediate_Imputation {
    take:
        chunked_regions
    
    main:
        impute5_impute_samples(
            chunked_regions
        )

        ch_imputed_intermediate_samples = impute5_impute_samples.out.imputedSamples

        bcftools_concat_by_chromosome(
            ch_imputed_intermediate_samples
        )

        ch_intermediate_by_chr = bcftools_concat_by_chromosome.out.ligateByChr

        // bcftools_concat_by_sample(
        //     intermediate_by_chr
        // )

        // intermediate_imputed_joined_samples = bcftools_concat_by_sample.out.ligateSample

        bcftools_index_imputed(
            ch_intermediate_by_chr
        )

       ch_intermediate_imputation = bcftools_index_imputed.out.indexedPhasedPair

    emit: 
        intermediate_imputation             = ch_intermediate_imputation
}