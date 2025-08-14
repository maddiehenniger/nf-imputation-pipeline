include { bcftools_view_samples        } from "../modules/bcftools_view_samples.nf"
include { bcftools_index_split_samples } from "../modules/bcftools_index_split_samples.nf"
// include { bcftools_index } from "../modules/convert_xcf.nf"

/**
 * Prepares the samples and references for phasing. 
 * 
 * 
 *
 * @take 
 * @emit 
 */

 workflow Prepare_Phasing {
    take:
        samples_by_chr
    
    main:
        bcftools_view_samples(
            samples_by_chr
        )

        ch_split_samples_by_chr = bcftools_view_samples.out.samplesByChr

        bcftools_index_split_samples(
            ch_split_samples_by_chr
        )

        ch_split_samples_idx = bcftools_index_split_samples.out.indexedSplitPair
    
    emit:
        split_samples_idx = ch_split_samples_idx

 }