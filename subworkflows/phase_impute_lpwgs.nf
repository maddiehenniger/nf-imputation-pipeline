/**
 * Workflow to phase and impute lcWGS data.
 * 
 * 
 */

workflow Phase_Impute_Lpwgs {
    take:
        samples_one
        reference_one
        glimpse2Model

    main:
        
        

    emit:
        // phasedSamples    = ch_phased_samples // Testing
        // phasedSamplesTwo = ch_phased_two // Testing
        ligatedSamples = ch_ligated_samples
        ligatedSamplesTwo = ch_ligated_two
}