include { Phase_Impute_Array } from "../subworkflows/phase_impute_array.nf"
// include { Phase_Impute_Lpwgs } from "../subworkflows/phase_impute_lpwgs.nf"

workflow PHASE_IMPUTE {
    take:
        samples_one
        reference_one
        reference_two
        dataType
        phasingModel
        // fastaReference

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
            // Phase_Impute_Lpwgs(
            //     samples_one,
            //     reference_one //,
            //     // fasta_reference
            // )
            ch_imputed_one = samples_one
            ch_imputed_two = Channel.empty()
        }

    emit:
        // phasedSamples = ch_phased_samples
        imputedSamplesOne = ch_imputed_one
        imputedSamplesTwo = ch_imputed_two
}