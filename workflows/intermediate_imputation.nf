include { Prepare_Imputation      } from "../subworkflows/prepare_imputation.nf"
include { Intermediate_Imputation } from "../subworkflows/intermediate_imputation.nf"

workflow INTERMEDIATE_IMPUTATION {
    take:
        reference_intermediate
        indexed_phased_pair

    main:
        Prepare_Imputation(
            reference_intermediate,
            indexed_phased_pair
        )

        intermediate_chunked_regions = Prepare_Imputation.out.intermediate_chunked_regions
        intermediate_ref_xcf         = Prepare_Imputation.out.intermediate_ref_xcf
        
        Intermediate_Imputation(
            intermediate_chunked_regions,
            intermediate_ref_xcf
        )

    emit:
        intermediate_chunked_regions = Prepare_Imputation.out.intermediate_chunked_regions
        intermediate_ref_xcf         = Prepare_Imputation.out.intermediate_ref_xcf
        imputed_intermediate         = Intermediate_Imputation.out.imputed_intermediate_samples
        intermediate_by_chromosomes  = Intermediate_Imputation.out.intermediate_by_chromosomes
        intermediate_imputed_paired  = Intermediate_Imputation.out.intermediate_imputed_paired

}