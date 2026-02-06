include { Phase_Impute_Array } from "../subworkflows/phase_impute_array.nf"

workflow PHASE_IMPUTE {
    take:
        samples_one
        reference_one
        reference_two
        dataType
        phasingModel
        glimpse2Model

    main:

        if(dataType == 'array') {
            Phase_Impute_Array(
                samples_one,
                reference_one,
                reference_two,
                phasingModel
            )
         } else if (dataType == 'lpwgs'){
            Phase_Impute_Lpwgs(
                samples_one,
                reference_one,
                glimpse2Model
            )
        }

        ch_imputed_one = Phase_Impute_Array.out.ligatedSamples
        ch_imputed_two = Phase_Impute_Array.out.ligatedSamplesTwo

    emit:
        // phasedSamples = ch_phased_samples
        imputedSamplesOne = ch_imputed_one
        imputedSamplesTwo = ch_imputed_two
}