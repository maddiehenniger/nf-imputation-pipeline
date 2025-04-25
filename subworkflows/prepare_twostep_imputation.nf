include { chunk_samples           } from '../modules/chunk_samples.nf'
include { convert_int_ref_to_xcf  } from '../modules/convert_xcf.nf'

/**
 * Prepares the samples and references for imputation. 
 * 
 * 
 *
 * @take 
 * @emit 
 */

 workflow Prepare_Twostep_Imputation {
    take:
        reference_twostep
        imputed_intermediate
    
    main:
        chunk_samples(
            reference_twostep,
            imputed_intermediate
        )

        convert_int_ref_to_xcf(
            reference_twostep,
            indexed_phased_pair
        )
    
    emit:
        twostep_chunked_regions      = chunk_samples.out.chunkedRegions
        twostep_ref_xcf              = convert_int_ref_to_xcf.out.xcfReference

 }