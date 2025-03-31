include { Phase_And_Index_Samples } from '../subworkflows/phase_and_index_samples.nf'

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
        Phase_And_Index_Samples(
            samples,
            reference_intermediate,
            chromosomes
        )

    emit:
        phased_samples = Phase_And_Index_Samples.out.phased_samples
        phased_samples_index = Phase_And_Index_Samples.out.phased_samples_index
}