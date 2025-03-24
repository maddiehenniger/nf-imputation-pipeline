include { samplesheetToList } from 'plugin/nf-schema'

/**
 * Parse the input referencesheet.
 * 
 * Validate and parse the input referencesheet with nf-schema `samplesheetToList`.
 * Wrangles the input reference(s) into the format of channels expected by downstream processes.
 *
 * @take referencesheet - File object to input referencesheet.
 * @emit List - channel of samples of shape [ metadata, [ referencePath ], [ referenceIndexPath ], [ imputationStep ] ].
 */

workflow Parse_Referencesheet {
    take:
        referencesheet
    
    main:
        Channel
            .fromList(samplesheetToList(referencesheet, "${projectDir}/assets/schema_referencesheet.json"))
            .meta { metaRef, referencePath, referenceIndexPath -> tuple(metaRef, referencePath, referenceIndexPath) }
            .set { ch_reference }
        
        ch_reference
        .branch { metaRef, referencePath, referenceIndexPath ->
                // If imputationStep is equal to one, create a channel for the reference for the intermediate imputation step
                intermediate: metaRef.imputationStep == 'one'
                // If imputationStep is equal to two...
                twostep: metaRef.imputationStep == 'two'
            }
        .set { ch_ref_split }
    
    emit:
        references             = ch_reference
        reference_intermediate = ch_ref_split.intermediate
        reference_twostep      = ch_ref_split.twostep
}