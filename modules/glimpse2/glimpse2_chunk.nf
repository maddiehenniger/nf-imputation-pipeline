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
        path:    "${params.publishDirData}/glimpse2_references/chunked_references/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap)
        val glimpse2Model

    output:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path("${metadata.referenceID}.chunks.${metadata.chromosome}.txt"), emit: chunkedRegions

    script:
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        """
        GLIMPSE2_chunk_static \\
            ${args} \\
            ${glimpse2Model} \\
            --threads ${task.cpus} \\
            -I ${reference} \\
            --region ${metadata.chromosome} \\
            -M ${geneticMap} \\
            -O ${metadata.referenceID}.chunks.${metadata.chromosome}.txt \\
            --log ${metadata.referenceID}.chunks.${metadata.chromosome}.log
        """
 }