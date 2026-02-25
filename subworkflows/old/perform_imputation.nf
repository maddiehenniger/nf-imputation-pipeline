include { impute5_impute_samples        } from '../modules/impute5_impute_samples.nf'
include { bcftools_concat_by_chromosome } from '../modules/ligate_samples_by_chromosome.nf'
include { bcftools_concat_by_sample     } from '../modules/ligate_samples.nf'
include { bcftools_index_imputed        } from '../modules/bcftools_index_imputed.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Perform_Imputation {
    take:
        chunked_regions
    
    main:
        impute5_impute_samples(
            chunked_regions
        )

        ch_imputed_samples = impute5_impute_samples.out.imputedSamples

        bcftools_concat_by_chromosome(
            ch_imputed_samples
        )

        ch_ligated_by_chr = bcftools_concat_by_chromosome.out.ligatedByChr

        // bcftools_concat_by_sample(
        //     intermediate_by_chr
        // )

        // intermediate_imputed_joined_samples = bcftools_concat_by_sample.out.ligatedSamples

        bcftools_index_imputed(
            ch_ligated_by_chr
        )

       ch_imputed_samples = bcftools_index_imputed.out.indexedImputed

    emit: 
        imputed_samples             = ch_imputed_samples
}