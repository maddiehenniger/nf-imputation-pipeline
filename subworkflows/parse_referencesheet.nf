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
            // use nf-schema to handle samplesheet parsing
            .fromList(
                samplesheetToList(referencesheet, "${projectDir}/assets/schema_referencesheet.json")
            )
            .map { meta, referencePath, referenceIndexPath -> tuple(meta, [ referencePath, referencePathIndex ]) }
            .set { ch_reference }
    
    emit:
        reference = ch_reference
}