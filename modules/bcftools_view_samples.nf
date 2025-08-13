/**
 * Process to run BCFtools view to separate test samples by chromosome.
 * 
 * Generates a BCF file per chromosome present in test samples.
 * @see https://samtools.github.io/bcftools/bcftools.html#view
 * 
 * @input A map of test sample metadata, path to sample, and path to the indexed sample
 * @emit samplesByChr - A map of test sample metadata, chromosome, path to by-chromosome test samples
 */

process bcftools_view_samples {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.file_inputs/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(meta), path(samplePath)
        each chromosomes

    output:
        tuple val(meta), val(chromosomes), path("${meta.id}_${chromosomes}.bcf"), emit: samplesByChr

    script:
        """
        bcftools view \\
        -r ${chromosomes} \\
        -Ob \\
        -o ${meta.id}_${chromosomes}.bcf \\
        ${samplePath}
        """
 }