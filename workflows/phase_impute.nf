include { Phase_Impute_Array } from "../subworkflows/phase_impute_array.nf"

workflow PHASE_IMPUTE {
    take:
        samples_one
        reference_one
        reference_two
        dataType

    main:

        if(dataType == 'array') {
            Phase_Impute_Array(
                samples_one,
                reference_one,
                reference_two
            )
         } else if (dataType == 'lpwgs'){
            Phase_Impute_Lpwgs(
                samples_one,
                reference_one,
                reference_two
            )
        }

        ch_phased_samples = Phase_Impute_Array.out.phasedSamples
        ch_phased_samples_two = Phase_Impute_Array.out.phasedSamplesTwo
        ch_imputed_samples = Phase_Impute_Array.out.imputedSamples

    emit:
        phasedSamples = ch_phased_samples
        phasedSamplesTwo = ch_phased_samples_two
        imputedSamples = ch_imputed_samples
}