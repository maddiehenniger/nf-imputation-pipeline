/**
 * Process to run bcftools index on the phased samples.
 * 
 * Generates an index (CSI) file for the phased reference.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input LinkedHashMap 
 * @emit
 */

 process bcftools_index_phased {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.phased_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        path phasedSamples

    output:
        tuple path(phasedSamples), path("*.csi"), emit: phasedSamplesIndex

    script:
        """
        bcftools index \
            ${phasedSamples}
        """
 }