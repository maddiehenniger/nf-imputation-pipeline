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
        path phasedSamples
        val(chromosomes)

    output:
        val "${phased_samples.baseName}_${chromosomes}_chunked_coords.txt", emit: chunkedRegions

    script:

        """
        imp5Chunker_v1.2.0_static \\
            --h ${referencePath} \\
            --g ${phasedSamples} \\
            --r ${chromosomes} \\
            --l ${phasedSamples.baseName}_chunking.log \\
            --o ${phasedSamples.baseName}_chunked_coords.txt
        """
 }