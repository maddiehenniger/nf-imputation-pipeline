include { chunk_intermediate_imputed_samples } from '../modules/chunk_intermediate_imputed_samples.nf'
include { convert_twostep_ref_to_xcf } from '../modules/convert_twostep_xcf.nf'

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
        imputed_intermediate_paired
    
    main:
        chunk_intermediate_imputed_samples(
            reference_twostep,
            imputed_intermediate_paired
        )

        convert_twostep_ref_to_xcf(
            reference_twostep,
            imputed_intermediate_paired
        )
    
    emit:
        twostep_chunked_regions      = chunk_intermediate_imputed_samples.out.twoChunkedRegions
        twostep_ref_xcf              = convert_twostep_ref_to_xcf.out.xcfTwostepReference

 }