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

    label 'glimpse2'

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

        def genetic_map_command = geneticMap ? "-M ${geneticMap}"  : ""

        """
        GLIMPSE2_chunk \\
            ${args} \\
            ${genetic_map_command} \\
            --${glimpse2Model} \\
            --threads ${task.cpus} \\
            -I ${reference} \\
            --region ${metadata.chromosome} \\
            -O ${metadata.referenceID}.chunks.${metadata.chromosome}.txt \\
            --log ${metadata.referenceID}.chunks.${metadata.chromosome}.log
        """
 }