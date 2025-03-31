include { chunk_samples           } from "../modules/chunk_samples.nf"
include { convert_xcf             } from "../modules/convert_xcf.nf"

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
        phasedSamples
        references
    
    main:
        chunk_samples()

        convert_xcf()

 }