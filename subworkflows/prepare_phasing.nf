include { bcftools_view_samples } from "../modules/bcftools_view_samples.nf"
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
        samples
    
    main:
        bcftools_view_samples(
            samples
        )

        ch_samples_by_chr = bcftools_view_samples.out.samplesByChr

        // bcftools_index_samples(
        //     ch_samples_by_chr
        // )
    
    emit:
        ch_samples_by_chr = bcftools_view_samples.out.samplesByChr

 }