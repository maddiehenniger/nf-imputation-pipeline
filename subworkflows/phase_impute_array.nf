include { shapeit5_phase_samples } from '../modules/shapeit5/shapeit5_phase_samples.nf'
include { impute5 }
/**
 * Workflow to phase test samples using SHAPEIT5, identify imputation and buffer regions on a chromosome-by-chromosome basis, and then perform imputation using IMPUTE5.
 * 
 * 
 */

workflow Phase_And_Index_Array {
    take:
        samples_one
        samples_two

    main:
        // Phase samples to the reference defined as round 'one'
        shapeit5_phase_samples(
            samples_one
        )
        ch_phased_samples = shapeit5_phase_samples.out.phasedSamples

        // Identifying imputation and buffer regions



    emit:
        phased_samples      = ch_phased_samples
        indexed_phased_pair = bcftools_index_phased.out.indexedPhasedPair
}