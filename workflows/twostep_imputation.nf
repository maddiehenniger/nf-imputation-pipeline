include { Prepare_Imputation      } from "../subworkflows/prepare_imputation.nf"
include { Intermediate_Imputation } from "../subworkflows/intermediate_imputation.nf"

workflow TWOSTEP_IMPUTATION {
    take:
        prepared_samples

    main:
       
       Prepare_Imputation(
            prepared_samples
        )

        twostep_chunked_regions = Prepare_Imputation.out.chunked_regions
        
        Intermediate_Imputation(
            twostep_chunked_regions
        )

        ch_imputed_twostep_samples = Intermediate_Imputation.out.intermediate_imputation

    emit:
        imputed_twostep_samples = ch_imputed_twostep_samples


}