/**
 * Process to run bcftools view to split each provided test sample by chromosomes present.
 * 
 * Separates the input samples on a chromosome-by-chromosome basis.
 * @see https://samtools.github.io/bcftools/bcftools.html#view
 * 
 * @input samplesheet - metadata map to the sample input information, including [ meta, [ samplePath ], [ sampleIndex ], [ wgsPath ], [ wgsIndex ] ]
 * @emit splitSamples - containing the samples split by chromosome, including [ meta, chromosome, [ samplePath+BY_CHR ], [ sampleIndex+BY_CHR ], [ wgsPath ], [ wgsIndex ] ]
 */

 process bcftools_split_samples {
    
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
        tuple val(metadata), val(chromosomes), path("${metadata.sampleID}_${chromosomes}.bcf"), path("${metadata.sampleID}_${chromosomes}.bcf.csi"), path(wgs), path(wgsIndex), emit: splitSamples

    script:
        """
        bcftools view -r ${chromosomes} \\
        -Ob \\
        -o ${metadata.sampleID}_${chromosomes}.bcf \\
        --write-index \\
        ${sample}
        """
 }