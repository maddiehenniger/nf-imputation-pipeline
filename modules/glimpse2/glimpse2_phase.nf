/**
 * Process to phase and impute low-coverage WGS samples to the user specified reference panel.
 * 
 * Generates GLIMPSE2-imputed data
 * @see IMPUTE5 documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/split_reference/
 * 
 * @input 
 * @emit
 */

 process glimpse2_split_reference {

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_references/split_references/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path(chunkedRegions)

    output:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path("${metadata.referenceID}.chunks.${metadata.chromosome}*"), emit: chunkedReference

    script:
        """
        
        """
 }