/**
 * Process to run BCFtools to index BCF/VCF(.gz) files.
 * 
 * Generates indexed files (.csi) for input BCF/VCF(.gz) files.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input 
 * @emit 
 **/

process bcftools_index {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/file_inputs/",
        mode:    "symlink",
    )

    input: 
        tuple val(meta), path(input)

    output:
        tuple val(meta), path(input), path("*.csi"), emit: indexedPair

    script: 
        """
        bcftools index \\
        ${sample}
        """
}
