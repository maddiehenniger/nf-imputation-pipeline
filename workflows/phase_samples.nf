include { Phase_And_Index_Samples } from '../subworkflows/phase_and_index_samples.nf'

/**
 * Workflow
 * 
 * 
 */

workflow PHASE_SAMPLES {
    take:
        prepare_phasing_samples
    
    main:
        Phase_And_Index_Samples(
            prepare_phasing_samples
        )

    emit:
        phased_samples = Phase_And_Index_Samples.out.phased_samples
        // indexed_phased_pair = Phase_And_Index_Samples.out.indexed_phased_pair
}