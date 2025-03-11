/**
 * Process to copy samples to the main directory.
 * 
 * Generates a copy of the original samples input from the samplesheet metadata.
 * 
 * @input samples - the input test samples.
 */
process copy_samples {
    
    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/0_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        path samples

    output:
        tuple path(samples), emit: samples

    script:
        """
        cp ${samples} ${samples}
        """
}