include { shapeit5_phase_samples } from '../modules/shapeit5_phase_samples.nf'
include { bcftools_index_phased  } from '../modules/bcftools_index_phased.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Phase_And_Index_Samples {
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
        ch_phased_samples = shapeit5_phase_samples.out.samplesPhased

        bcftools_index_phased(
            ch_phased_samples
        )

    emit:
        phased_samples = ch_phased_samples
        phased_samples_index = bcftools_index_phased.out.phasedSamplesIndex
}