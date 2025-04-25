include { Prepare_Twostep_Imputation } from "../subworkflows/prepare_twostep_imputation.nf"
include { Perform_Twostep_Imputation } from "../subworkflows/perform_twostep_imputation.nf"

workflow TWOSTEP_IMPUTATION {
    take:
        reference_twostep
        indexed_phased_pair

    main:
        Prepare_Twostep_Imputation(
            reference_twostep,
            indexed_phased_pair
        )

        twostep_chunked_regions = Prepare_Imputation.out.twostep_chunked_regions
        twostep_ref_xcf         = Prepare_Imputation.out.twostep_ref_xcf
        
        Perform_Twostep_Imputation(
            twostep_chunked_regions,
            twostep_ref_xcf
        )

    emit:
        twostep_chunked_regions      = Prepare_Twostep_Imputation.out.twostep_chunked_regions
        twostep_ref_xcf              = Prepare_Twostep_Imputation.out.twostep_ref_xcf
        imputed_twostep              = Perform_Twostep_Imputation.out.imputed_twostep_samples
        twostep_by_chromosomes       = Perform_Twostep_Imputation.out.twostep_by_chromosomes

}