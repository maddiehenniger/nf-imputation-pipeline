include { Prepare_Imputation      } from "../subworkflows/prepare_imputation.nf"
include { Perform_Imputation      } from "../subworkflows/perform_imputation.nf"

workflow IMPUTE_SAMPLES {
    take:
        prepared_samples

    main:
        Prepare_Imputation(
            prepared_samples
        )

        ch_chunked_regions = Prepare_Imputation.out.chunked_regions
        
        Perform_Imputation(
            ch_chunked_regions
        )

        ch_imputed_samples = Perform_Imputation.out.imputed_samples

    emit:
        imputed_samples_by_chr = ch_imputed_samples
}