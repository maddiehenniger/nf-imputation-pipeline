include { impute5_impute_twostep_samples        } from '../modules/impute5_twostep.nf'
include { bcftools_concat_twostep_by_chromosome } from '../modules/bcftools_concat_twostep_by_chromosome.nf'
include { bcftools_concat_twostep_by_sample     } from '../modules/bcftools_concat_twostep_by_sample.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Twostep_Imputation {
    take:
        twostep_chunked_regions
        twostep_ref_xcf
    
    main:
        impute5_impute_twostep_samples(
            twostep_chunked_regions,
            twostep_ref_xcf
        )

        imputed_twostep_samples = impute5_impute_twostep_samples.out.twostepImputation

        bcftools_concat_twostep_by_chromosome(
            imputed_twostep_samples
        )

        twostep_by_chr = bcftools_concat_twostep_by_chromosome.out.twostepByChromosome

        bcftools_concat_twostep_by_sample(
            twostep_by_chr
        )

    emit: 
        imputed_twostep_samples        = impute5_impute_intermediate_samples.out.twostepImputation
        twostep_by_chromosomes         = bcftools_concat_twostep_by_chromosome.out.twostepByChromosome
        twostep_imputed_joined_samples = bcftools_concat_twostep_by_sample.out.twostepJoinedImputation
}