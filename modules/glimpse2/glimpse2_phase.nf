/**
 * Process to phase and impute low-coverage WGS samples to the user-specified reference panel.
 * 
 * Generates phased and imputed genotypes using GLIMPSE2_phase.
 * @see GLIMPSE2_phase documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/phase/
 * 
 * @input 
 * @emit
 */

 process glimpse2_phase_impute {

    label 'glimpse2'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_phased/",
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