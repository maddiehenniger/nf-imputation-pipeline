include { Prepare_Imputation      } from "../subworkflows/prepare_imputation.nf"
include { Intermediate_Imputation } from "../subworkflows/intermediate_imputation.nf"

workflow INTERMEDIATE_IMPUTATION {
    take:
        phased_samples

    main:
        Prepare_Imputation(
            phased_samples
        )

        intermediate_chunked_regions = Prepare_Imputation.out.chunked_regions
        
        Intermediate_Imputation(
            intermediate_chunked_regions
        )

        ch_imputed_intermediate_samples        = Intermediate_Imputation.out.imputed_intermediate_samples
        ch_intermediate_by_samples             = Intermediate_Imputation.out.intermediate_by_sample

    emit:
        imputed_intermediate_samples = ch_imputed_intermediate_samples
        ligated_intermediate_samples = ch_intermediate_by_samples
}