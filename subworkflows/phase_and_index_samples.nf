include { shapeit5_phase_samples } from '../modules/shapeit5_phase_samples.nf'
include { bcftools_index_phased  } from '../modules/bcftools_index_phased.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Phase_And_Index_Samples {
    take:
        prepare_phasing_samples // channel: [ chr, [sampleMetadata], path(samplePath), path(sampleIndex), [intReferenceMetadata], path(intReferencePath), path(intReferenceIndex), path(geneticMapPath) ]
    
    main:
        shapeit5_phase_samples(
            prepare_phasing_samples
        )
        ch_phased_samples = shapeit5_phase_samples.out.phasedSamples

        bcftools_index_phased(
            ch_phased_samples
        )

    emit:
        phased_samples      = ch_phased_samples
        indexed_phased_pair = bcftools_index_phased.out.indexedPhasedPair
}