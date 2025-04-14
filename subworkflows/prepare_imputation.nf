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
        reference_intermediate
        phased_samples_index
        chromosomes
    
    main:
        chunk_samples(
            reference_intermediate,
            phased_samples_index,
            chromosomes
        )

        convert_int_ref_to_xcf(
            reference_intermediate,
            chromosomes
        )
    
    emit:
        chunked_regions      = chunk_samples.out.chunkedRegions
        intermediate_ref_xcf = convert_int_ref_to_xcf.out.xcfIntermediateReference

 }