include { Prepare_Imputation      } from "../subworkflows/prepare_imputation.nf"
include { Intermediate_Imputation } from "../subworkflows/intermediate_imputation.nf"

workflow INTERMEDIATE_IMPUTATION {
    take:
        prepared_samples

    main:
        Prepare_Imputation(
            prepared_samples
        )

        intermediate_chunked_regions = Prepare_Imputation.out.chunked_regions
        
        Intermediate_Imputation(
            intermediate_chunked_regions
        )

        ch_imputed_intermediate_samples = Intermediate_Imputation.out.intermediate_imputation

    emit:
        imputed_intermediate_samples_by_chr = ch_imputed_intermediate_samples
}