include { Prepare_Imputation      } from "../subworkflows/prepare_imputation.nf"
include { Intermediate_Imputation } from "../subworkflows/intermediate_imputation.nf"

workflow IMPUTE_SAMPLES {
    take:
        reference_intermediate
        indexed_phased_pair

    main:
        Prepare_Imputation(
            reference_intermediate,
            indexed_phased_pair
        )
        
        Intermediate_Imputation(
            indexed_phased_pair
            chromosomes
            intermediate_ref_xcf
            chunked_regions
        )

    emit:
        chunked_regions      = Prepare_Imputation.out.chunked_regions
        intermediate_ref_xcf = Prepare_Imputation.out.intermediate_ref_xcf

}