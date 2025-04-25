include { impute5_impute_samples        } from '../modules/impute5_impute_samples.nf'
include { bcftools_concat_by_chromosome } from '../modules/ligate_samples_by_chromosome.nf'
include { bcftools_concat_by_sample     } from '../modules/ligate_samples.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Perform_Twostep_Imputation {
    take:
        twostep_chunked_regions
        twostep_ref_xcf
    
    main:
        impute5_impute_samples(
            twostep_chunked_regions,
            twostep_ref_xcf
        )

        imputed_twostep_samples = impute5_impute_samples.out.imputedSamples

        bcftools_concat_by_chromosome(
            imputed_twostep_samples
        )

        twostep_by_chr = bcftools_concat_by_chromosome.out.ligatedByChromosome

        bcftools_concat_by_sample(
            twostep_by_chr
        )

    emit: 
        imputed_twostep_samples        = impute5_impute_samples.out.imputedSamples
        twostep_by_chromosomes         = bcftools_concat_by_chromosome.out.ligatedByChromosome
        twostep_imputed_joined_samples = bcftools_concat_by_sample.out.ligatedAllChromosomes
}