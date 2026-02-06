/**
 * Process to run bcftools +fill-tags to fill AC and AN tags in by-chromosome split test samples.
 * 
 * Produces a BCF file with the AC/AN INFO field calculated.
 * @see https://samtools.github.io/bcftools/bcftools.html#plugin
 * 
 * @input
 * @emit
 */

 process bcftools_fill_tags {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/input_files/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), val(chromosomes), path(sample), path(sampleIndex), path(wgs), path(wgsIndex)

    output:
        tuple val(metadata), val(chromosomes), path("${metadata.sampleID}.tags.${chromosomes}.bcf"), path("${metadata.sampleID}.tags.${chromosomes}.bcf.csi"), path(wgs), path(wgsIndex), emit: filledTags

    script:
        """
        bcftools +fill-tags ${sample} \\
        -Ob \\
        --write-index \\
        -o ${metadata.sampleID}.tags.${chromosomes}.bcf -- -t AN,AC
        """
 }