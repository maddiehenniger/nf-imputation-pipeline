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
    
    main:
        Phase_And_Index_Samples(
            samples,
            reference_intermediate
        )

    emit:
        phased_samples = Phase_And_Index_Samples.out.phased_samples
        // indexed_phased_pair = Phase_And_Index_Samples.out.indexed_phased_pair
}