include { chunk_samples           } from "../modules/chunk_samples.nf"
include { convert_int_ref_to_xcf  } from "../modules/convert_xcf.nf"

/**
 * Prepares the samples and references for imputation. 
 * 
 * 
 *
 * @take 
 * @emit 
 */

 workflow Prepare_Imputation {
    take:
        indexed_phased_pair
    
    main:
        chunk_samples(
            indexed_phased_pair
        )

        convert_int_ref_to_xcf(
            indexed_phased_pair
        )
    
    emit:
        intermediate_chunked_regions      = chunk_samples.out.chunkedRegions
        intermediate_ref_xcf              = convert_int_ref_to_xcf.out.xcfReference

 }