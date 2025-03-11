/**
 * Process to run bcftools index on reference(s).
 * 
 * Generates a CSI index from a VCF/BCF file.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input reference - the reference(s) to be indexed
 * @emit refIndex - the indexed reference(s)
 */
process bcftools_index_reference {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/reference/",
        mode:    "${params.publishMode}"
    )

    input:
        path reference

    output:
        tuple path(reference), path "${reference}.csi", emit: refIndex

    script:
        """
        bcftools index \
            ${reference}
        """
}