include { bcftools_view_samples        } from "../modules/bcftools_view_samples.nf"
include { bcftools_index_split_samples } from "../modules/bcftools_index_split_samples.nf"
include { convert_xcf                  } from "../modules/convert_xcf.nf"

/**
 * Prepares the samples and references for phasing. 
 * 
 * 
 *
 * @take samples_by_chr          - [ chr, [ sampleID ], samplePath, sampleIndex ]
 *       intermediate_idx        - [ chr, [ referenceID, chr, imputationStep, geneticMaps ], referencePath, referenceIndex, geneticMapPath ]
 * @emit prepare_phasing_samples - [ chr, [ sampleID ], samplePath, sampleIndex, [ referenceID, chr, imputationStep, geneticMaps ], xcfReferencePath, xcfReferenceIndex, xcfReferenceBim, xcfReferenceFam, geneticMapPath ]
 */

 workflow Prepare_Phasing {
    take:
        samples_by_chr
        intermediate_idx
    
    main:
        bcftools_view_samples(
            samples_by_chr
        )

        ch_split_samples_by_chr = bcftools_view_samples.out.samplesByChr

        bcftools_index_split_samples(
            ch_split_samples_by_chr
        )

        convert_xcf(
            intermediate_idx
        )

        ch_reference_xcf = convert_xcf.out.xcfReference

        bcftools_index_split_samples.out.indexedSplitPair
            .join(ch_reference_xcf)
            .set { ch_prepare_phasing_samples }

    
    emit:
        prepare_phasing_samples = ch_prepare_phasing_samples

 }