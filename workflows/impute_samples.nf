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

        chunked_regions = Prepare_Imputation.out.chunked_regions

}