include { Prepare_Imputation      } from "../subworkflows/prepare_imputation.nf"
include { Intermediate_Imputation } from "../subworkflows/intermediate_imputation.nf"

workflow INTERMEDIATE_IMPUTATION {
    take:
        phased_samples

    main:
        Prepare_Imputation(
            phased_samples
        )

        intermediate_chunked_regions = Prepare_Imputation.out.intermediate_chunked_regions
        
        Intermediate_Imputation(
            intermediate_chunked_regions
        )

        ch_imputed_intermediate_samples        = impute5_impute_samples.out.imputedSamples
        ch_intermediate_by_chromosomes         = bcftools_concat_by_chromosome.out.ligateByChr
        ch_intermediate_by_samples             = bcftools_concat_by_sample.out.ligateSample

    emit:
        imputedSamples = ch_imputed_intermediate_samples
        ligatedSamples = ch_intermediate_by_samples
}