include { Prepare_Twostep_Imputation } from "../subworkflows/prepare_twostep_imputation.nf"
include { Twostep_Imputation         } from "../subworkflows/twostep_imputation.nf"

workflow TWOSTEP_IMPUTATION {
    take:
        reference_twostep
        intermediate_imputed_paired

    main:
        Prepare_Twostep_Imputation(
            reference_twostep,
            intermediate_imputed_paired
        )

        twostep_chunked_regions = Twostep_Imputation.out.twostep_chunked_regions
        twostep_ref_xcf         = Twostep_Imputation.out.twostep_ref_xcf
        
        Twostep_Imputation(
            twostep_chunked_regions,
            twostep_ref_xcf
        )

    emit:
        twostep_chunked_regions      = Prepare_Twostep_Imputation.out.twostep_chunked_regions
        twostep_ref_xcf              = Prepare_Twostep_Imputation.out.twostep_ref_xcf
        imputed_twostep              = Twostep_Imputation.out.imputed_twostep_samples
        twostep_by_chromosomes       = Twostep_Imputation.out.twostep_by_chromosomes

}