include { glimpse2_phase_impute } from '../modules/glimpse2/glimpse2_phase_impute.nf'

/**
 * Workflow to phase and impute lcWGS data.
 * 
 * 
 */

workflow Phase_Impute_Lpwgs {
    
    take:
        samples_one
        reference_one
        fasta_reference

    main:
        
        glimpse2_phase_impute(
            samples_one,
            reference_one,
            fasta_reference
        )
        ch_imputed_samples = glimpse2_phase_impute.out.imputedSamples

    emit:
        // phasedSamples    = ch_phased_samples // Testing
        // phasedSamplesTwo = ch_phased_two // Testing
        // ligatedSamples = ch_ligated_samples
        // ligatedSamplesTwo = ch_ligated_two
        imputedSamples = ch_imputed_samples
}