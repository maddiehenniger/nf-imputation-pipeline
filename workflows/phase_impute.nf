include { Phase_Impute_Array      } from "../subworkflows/phase_impute_array.nf"
include { Perform_Imputation      } from "../subworkflows/perform_imputation.nf"

workflow PHASE_IMPUTE {
    take:
        splitSamples
        reference_one
        reference_two

    main:
        Phase_Impute_Array(
            splitSamples,
            reference_one,
            reference_two
        )

        ch_phased_samples = Phase_Impute_Array.out.phasedSamples
        ch_phased_samples_two = Phase_Impute_Array.out.phasedSamplesTwo

    emit:
        phasedSamples = ch_phased_samples
        phasedSamplesTwo = ch_phased_samples_two
}