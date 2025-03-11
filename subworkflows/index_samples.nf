include { copy_samples           } from '../modules/copy_samples.nf'
include { bcftools_index_samples } from '../modules/bcftools_index_samples.nf'

/**
 * Purpose
 * 
 * Doc
 *
 * @take 
 * @emit 
 */

workflow Index_Samples {
    take:
        samples
    
    main:
        // copy samples to working directory
        copy_samples(samples)

        // index samples
        bcftools_index_samples(
            samples
        )
        ch_sampleIndex = bcftools_index_samples.out.sampleIndex

    emit:
        sampleIndex = ch_sample_index
}