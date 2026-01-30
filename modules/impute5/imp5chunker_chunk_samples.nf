/**
 * Process to run Imp5Chunker to identify imputation regions.
 * 
 * Generates a text file containing the following fields: Chunk ID / chromosome ID / Buffered region / Imputation region / Length / Number of target markers / Number of reference markers
 * @see IMPUTE5 documentation https://jmarchini.org/software/#impute-5
 * 
 * @input 
 * @emit chunkedRegions 
 */

 process imp5chunker_chunk_samples {

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/chunked_regions/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(phasedSample), path(phasedIndex), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap)

    output:
        tuple val(chromosome), val(sMetadata), path(phasedSample), path(phasedIndex), path("${sMetadata.sampleID}.${chromosome}.${rMetadata.round}.chunked.txt"), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap), emit: chunkedRegions
        path("${sMetadata.sampleID}.${chromosome}.${rMetadata.round}.chunked.log"), emit: chunkedLog

    script:

        """
        imp5Chunker_v1.2.0_static \\
            --h ${reference} \\
            --g ${phasedSample} \\
            --r ${chromosome} \\
            --l ${sMetadata.sampleID}.${chromosome}.${rMetadata.round}.chunked.log \\
            --o ${sMetadata.sampleID}.${chromosome}.${rMetadata.round}.chunked.txt
        """
 }