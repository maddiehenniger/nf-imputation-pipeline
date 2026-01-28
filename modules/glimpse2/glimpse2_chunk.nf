/**
 * Process to create imputation chunks from the reference panel using GLIMPSE2.
 * 
 * Generates 
 * @see IMPUTE5 documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/chunk/
 * 
 * @input 
 * @emit
 */

 process glimpse2_chunk {

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_references/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap)
        val model

    output:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path("${metadata.referenceID}.chunks.${metadata.chromosome}.txt"), emit: chunkedRegions

    script:
        """
        GLIMPSE2_chunk_static \\
            --threads ${task.cpus} \\
            -I ${reference} \\
            --region ${metadata.chromosome} \\
            -M ${geneticMap} \\
            ${model} \\
            -O ${metadata.referenceID}.chunks.${metadata.chromosome}.txt \\
            --log ${metadata.referenceID}.chunks.${metadata.chromosome}.log
        """
 }