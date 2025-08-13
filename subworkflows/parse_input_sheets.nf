include { samplesheetToList } from 'plugin/nf-schema'

/**
 * Parse the required and optional files provided in the Nextflow configuration file.
 * 
 * Validate and parse the input samplesheet, reference(s), and/or genetic maps with nf-schema `samplesheetToList`.
 * Wrangles the input datasets into the format of channels expected by downstream processes.
 *
 * @take samplesheet, references, recombinationMaps - File object to input samplesheet, references, and/or recombination maps as defined in the configuration file.
 * @emit List - channel of input datasheets of shape [ metadata, [ filePath ] ]
 **/

workflow Parse_Input_Sheets {
    take:
        samplesheet // channel (required): [ [id], samplePath ]
        references  // channel (required): [ [id, chr, step], referencePath, mapPath ]
    
    main:
        // Use nf-schema to handle input sample, reference panel, and optionall genetic map parsing
        
        // Creates a channel that takes and validates the input samples
        Channel
            .fromList(
                samplesheetToList(samplesheet, "${projectDir}/assets/schema_samplesheet.json")
            )
            .map { meta, samplePath -> 
                tuple(meta, samplePath) 
            }
            .set { ch_samples }

        // Creates a channel that takes and validates input reference sheets
        Channel
            .fromList(samplesheetToList(references, "${projectDir}/assets/schema_references.json"))
            .map { meta, referencePath, geneticMapPath -> 
                createReferenceChannel(meta, referencePath, geneticMapPath) 
            }
            .set { ch_references }
        
        ch_references
        .branch { meta, referencePath, geneticMapPath ->
                // If imputationStep is equal to one, create a channel for the reference for the intermediate imputation step
                intermediate: meta.step == 'one' // Make a channel that contains only the reference panels for the first round of imputation (intermediate)
                // If imputationStep is equal to two...
                twostep: meta.step == 'two' // Make a channel that contains only the reference panels for the second round of imputation (twostep)
            }
        .set { ch_ref_split }

    emit:
        samples                = ch_samples
        references             = ch_references
        reference_intermediate = ch_ref_split.intermediate
        reference_twostep      = ch_ref_split.twostep
}

def createReferenceChannel(meta, refPath, mapPath) {
    // Store metadata in a Map shallow copied from the input meta map
    metadata = meta.clone()
    // Fill in the required metadata 
    metadata.geneticMaps = mapPath.isEmpty() ? "none" : "provided"
    
    // Store the references in lists
    def referencePath = file(refPath)
    if(mapPath.isEmpty()) {
        def emptyFileName = "${geneticMapPath.simpleName}.NOFILE"
        def emptyFilePath = file("${workDir}").resolve(emptyFileName)
        file("${projectDir}/assets/NO_FILE").copyTo(emptyFilePath)
        geneticMapPath = file(emptyFilePath)
    } else {
        geneticMapPath = file(mapPath)
    }

    return [ metadata, referencePath, geneticMapPath ]
}