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
        recombination_maps
    
    main:
        shapeit5_phase_samples(
            samples,
            reference_intermediate,
            recombination_maps
        )
        ch_phased_samples = shapeit5_phase_samples.out.phasedSamples
            .map { bcf, chromosomeNum, recombinationMapFile -> [ bcf.baseName, bcf, chromosomeNum, recombinationMapFile ] }

        bcftools_index_phased(
            ch_phased_samples
        )

    emit:
        phased_samples      = ch_phased_samples
        indexed_phased_pair = bcftools_index_phased.out.indexedPhasedPair
}