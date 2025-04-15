include { impute5_impute_samples } from '../modules/impute5_impute_samples.nf'

/**
 * Workflow
 * 
 * 
 */

workflow Intermediate_Imputation {
    take:
        
    
    main:
        shapeit5_phase_samples(
            samples,
            reference_intermediate,
            chromosomes
        )
        ch_phased_samples = shapeit5_phase_samples.out.phasedSamples
            .map { bcf -> [ bcf.baseName, bcf ] }

        bcftools_index_phased(
            ch_phased_samples
        )

    emit:
        phased_samples      = ch_phased_samples
        indexed_phased_pair = bcftools_index_phased.out.indexedPhasedPair
}