/**
 * Process to run bcftools view.
 * 
 * Separates the input samples on a chromosome-by-chromosome basis.
 * @see https://samtools.github.io/bcftools/bcftools.html#view
 * 
 * @input
 * @emit
 */

 process bcftools_view {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.chromosome_validation/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(sample), path(sampleIndex), path(wgs), path(wgsIndex)
        val(chromosomes)

    output:
        tuple val(metadata), val(chromosome), path("${metadata.sampleID}_${chromosome}.bcf"), path("$${metadata.sampleID}_${chromosome}.bcf.csi"), emit: splitSamples

    script:
        """
        bcftools view -r ${chromosome} \\
        -Ob \\
        -o ${metadata.sampleID}_${chromosome}.bcf \\
        --write-index \\
        ${samplePath}
        """
 }