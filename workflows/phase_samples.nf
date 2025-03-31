include { shapeit5_phase_samples } from '../modules/shapeit5_phase_samples.nf'

/**
 * Workflow
 * 
 * 
 */

workflow PHASE_SAMPLES {
    take:
        samples
        reference_intermediate
        chromosomes
    
    main:
        shapeit5_phase_samples(
            samples,
            reference_intermediate,
            chromosomes
        )

    emit:
        phased_samples = shapeit5_phase_samples.out.phasedSamples
}