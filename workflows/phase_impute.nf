include { Phase_Impute_Array } from "../subworkflows/phase_impute_array.nf"
include { Phase_Impute_Lpwgs } from "../subworkflows/phase_impute_lpwgs.nf"

workflow PHASE_IMPUTE {
    take:
        samples_one
        reference_one // Don't think I need this
        reference_two
        dataType
        phasingModel
        fastaReference

    main:

        if(dataType == 'array') {
            Phase_Impute_Array(
                samples_one,
                reference_two,
                phasingModel
            )
            ch_imputed_one = Phase_Impute_Array.out.ligatedSamples
            ch_imputed_two = Phase_Impute_Array.out.ligatedSamplesTwo

         } else if (dataType == 'lpwgs'){
            Phase_Impute_Lpwgs(
                samples_one,
                fastaReference
            )
            ch_imputed_one = Phase_Impute_Lpwgs.out.imputedSamples
            ch_imputed_two = Channel.empty()
        }

    emit:
        imputedSamplesOne = ch_imputed_one
        imputedSamplesTwo = ch_imputed_two
}