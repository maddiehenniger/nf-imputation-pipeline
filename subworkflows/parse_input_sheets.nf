include { samplesheetToList } from 'plugin/nf-schema'

/**
 * Parse the required and optional files provided in the Nextflow configuration file.
 * 
 * Validate and parse the input samplesheet, reference(s), and/or genetic maps with nf-schema `samplesheetToList`.
 * Wrangles the input datasets into the format of channels expected by downstream processes.
 *
 * @take samplesheet, references - File object to input samplesheet, references, and/or recombination maps as defined in the configuration file.
 * @emit List - channel of input datasheets of shape [ metadata, [ filePath ] ]
 **/
workflow Parse_Input_Sheets {
    take:
        samplesheet // channel (required): [ sampleMetadata, [ samplePath ], [ sampleIndex ], [ wgsPath ], [ wgsIndex] ]
        references  // channel (required): [ referenceMetadata, [ referencePath ], [ referenceIndex ], [ geneticMapPath ] ]
    
    main:
        // Use nf-schema to handle input sample & reference panel metadata 
        // Creates a channel that takes and validates the input samples
        Channel
            .fromList(
                samplesheetToList(samplesheet, "${projectDir}/assets/schema_samplesheet.json")
            )
            .map { meta, samplePath, sampleIndex, wgsPath, wgsIndex -> 
                tuple(meta, samplePath, sampleIndex, wgsPath, wgsIndex)
            }
            .set { ch_samples }

        // Creates a channel that takes and validates input reference sheets
        Channel
            .fromList(samplesheetToList(references, "${projectDir}/assets/schema_references.json"))
            .map { meta, referencePath, referenceIndex, geneticMapPath -> 
                createReferenceChannel(meta, referencePath, referenceIndex, geneticMapPath) 
            }
            .set { ch_references }
        
        ch_references
        .branch { meta, referencePath, referenceIndex, geneticMapPath ->
                // If imputationRound is equal to one, create a channel for the reference for the intermediate imputation step
                oneRound: meta.round == 'one' // Make a channel that contains only the reference panels for the first round of imputation (oneRound)
                // If imputationRound is equal to two...
                twoRound: meta.round == 'two' // Make a channel that contains only the reference panels for the second round of imputation (twoRound)
            }
        .set { ch_ref_split }

    emit:
        samples       = ch_samples
        references    = ch_references // I don't think we need this for downstream, was just for testing
        reference_one = ch_ref_split.oneRound
        reference_two = ch_ref_split.twoRound
}

def createReferenceChannel(meta, refPath, refIndex, mapPath) {
    // Store metadata in a Map shallow copied from the input meta map
    metadata = meta.clone()
    // Fill in the required metadata 
    metadata.geneticMaps = mapPath.isEmpty() ? "none" : "provided"
    // Store the references in lists
    def referencePath = file(refPath)
    def referenceIndex = file(refIndex)
    if(mapPath.isEmpty()) {
        def emptyFileName = "${refPath.simpleName}.NOFILE"
        def emptyFilePath = file("${workDir}").resolve(emptyFileName)
        file("${projectDir}/assets/NO_FILE").copyTo(emptyFilePath)
        geneticMapPath = file(emptyFilePath)
    } else {
        geneticMapPath = file(mapPath)
    }

    return [ metadata, referencePath, referenceIndex, geneticMapPath ]
}

/**
 * Determine whether or not a file is empty
 *
 * This method is necessary because the Path.isEmpty() method returns false for gzip compressed files.
 *
 * @param fq A Path for a fastq file
 *
 * @return A boolean indicating whether or not the fastq file is empty.
*/
def isEmpty(Path fq) {
    // set decimal representation of first byte of empty file
    def emptyDecimal = -1
    def firstByteOfFastq = readFirstByte(fq)

    return firstByteOfFastq == emptyDecimal
}

/**
 * Read the first byte of a gzip compressed file.
 *
 * @param f A Path object for a gzip compressed file.
 *
 * @return An integer representation of the first byte of the file.
*/
def readFirstByte(Path f) {
    f.withInputStream { fis ->
        new java.util.zip.GZIPInputStream(fis).withStream { gis ->
            return gis.read()
        }
    }
}