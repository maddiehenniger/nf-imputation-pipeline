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
            .map { meta, samplePath, wgsPath -> 
                // Create a runType variable to determine pipeline version to run
                def runType = ""
                // Check if the file paths exist
                if (samplePath && wgsPath) {
                    log.info "Found existing paths to test samples and WGS samples, calculating imputation accuracy statistics."
                    runType = "statistics"
                } else if (samplePath && !wgsPath) {
                    log.info "Found existing path to test samples without paired WGS sample, performing standard imputation pipeline."
                    runType = "impute"
                } else if (!samplePath && wgsPath) {
                    log.info "Found existing path to WGS sample without paired test sample, performing downsampling as ..."
                    runType = "downsample"
                }
                // Create the updated metadata map, adding 'runType'
                def new_meta = meta + [runtype: runType]
                // Convert paths to file objects inside lists [path]
                // and use an empty list if the path is missing/empty
                def sample_list = samplePath ? [file(samplePath)] : []
                def wgs_list    = wgsPath ? [file(wgsPath)] : []
                // Return with structure [ metadata, [ samplePath ], [ wgsPath ]]
                return [ new_meta, sample_list, wgs_list ]
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
                // If imputationRound is equal to one, create a channel for the reference for the intermediate imputation step
                oneRound: meta.round == 'one' // Make a channel that contains only the reference panels for the first round of imputation (oneRound)
                // If imputationRound is equal to two...
                twoRound: meta.round == 'two' // Make a channel that contains only the reference panels for the second round of imputation (twoRound)
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
        def emptyFileName = "${refPath.simpleName}.NOFILE"
        def emptyFilePath = file("${workDir}").resolve(emptyFileName)
        file("${projectDir}/assets/NO_FILE").copyTo(emptyFilePath)
        geneticMapPath = file(emptyFilePath)
    } else {
        geneticMapPath = file(mapPath)
    }

    return [ metadata, referencePath, geneticMapPath ]
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