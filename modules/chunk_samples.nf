/**
 * Process to run Imp5Chunker to create imputation cunks from the target and reference panel. 
 * 
 * Generates a text file containing the following fields: Chunk ID / chromosome ID / Buffered region / Imputation region / Length / Number of target markers / Number of reference markers
 * @see IMPUTE5 documentation https://jmarchini.org/software/#impute-5
 * 
 * @input 
 * @emit
 */

 process chunk_samples {
    tag "$sample_id"

    stageInMode 'copy'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/.chunked_regions/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(metaRef), path(referencePath), path(referenceIndexPath)
        ttuple val(sample_id), path(sampleBcf), path(sampleBcfIndex), val(chromosomeNum), path(recombinationMapFile)

    output:
        tuple val(chromosomeNum), path("${sampleBcf.baseName}_${chromosomeNum}_chunked_coords.txt"), path(recombinationMapFile), emit: chunkedRegions

    script:

        """
        imp5Chunker_v1.2.0_static \\
            --h ${referencePath} \\
            --g ${sampleBcf} \\
            --r ${chromosomeNum} \\
            --l ${sampleBcf.baseName}_chunking.log \\
            --o ${sampleBcf.baseName}_${chromosomeNum}_chunked_coords.txt
        """
 }