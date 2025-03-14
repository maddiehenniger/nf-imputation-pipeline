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
            .branch { meta, referencePath, referenceIndexPath ->
                // If imputationStep is equal to one, create a channel for the reference for the intermediate imputation step
                intermediate: meta.imputationStep == 'one'
                // If imputationStep is equal to two...
                twostep: meta.imputationStep == 'two'
            }
            .set { ch_reference }
    
    emit:
        reference_intermediate = ch_reference.intermediate
        reference_twostep      = ch_reference.twostep
}