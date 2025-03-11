include { samplesheetToList } from 'plugin/nf-schema'

/**
 * Parse the input samplesheet.
 * 
 * Validate and parse the input samplesheet with nf-schema `samplesheetToList`.
 * Wrangles the input samples into the format of channels expected by downstream processes.
 *
 * @take samplesheet - File object to input samplesheet.
 * @emit List - channel of samples of shape [ metadata, [ samplePath ] ].
 */

workflow Parse_Samplesheet {
    take:
        samplesheet
    
    main:
        Channel
            // use nf-schema to handle samplesheet parsing
            .fromList(
                samplesheetToList(samplesheet, "${projectDir}/assets/schema_samplesheet.json")
            )
            /*
                Reshape nf-schema output to format I want
                This gives a shape of:
                [
                    metadata map,
                    [ samplePath VCF/BCF(.gz) file ]
                ]
                This general shape is passed into most downstream steps that take in input samples.
            */
            .map { meta, samplePath ->
                createSampleReadsChannel(meta, samplePath)
            }
            .set { ch_samples }
    
    emit:
        samples = ch_samples
}