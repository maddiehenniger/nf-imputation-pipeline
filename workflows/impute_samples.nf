include { Prepare_Imputation } from "../subworkflows/prepare_imputation.nf"

workflow IMPUTE_SAMPLES {
    take:
        reference_intermediate
        phased_samples
        chromosomes

    main:
        Prepare_Imputation(
            reference_intermediate,
            phased_samples,
            chromosomes
        )

    emit:
        chunked_regions      = Prepare_Imputation.out.chunked_regions
        intermediate_ref_xcf = Prepare_Imputation.out.intermediate_ref_xcf

}