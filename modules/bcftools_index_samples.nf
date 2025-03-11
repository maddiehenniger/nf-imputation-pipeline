/**
 * Process to run bcftools index on samples.
 * 
 * Generates a CSI index from a VCF/BCF file.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input sample - the samples to be indexed
 * @emit sampleIndex - the indexed samples
 */
process bcftools_index_samples {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/0_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        path sample

    output:
        tuple path(sample), path "${sample}.csi", emit: sampleIndex

    script:
        """
        bcftools index \
            ${sample}
        """
}
