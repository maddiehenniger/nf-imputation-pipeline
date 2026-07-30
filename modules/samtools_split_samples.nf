/**
 * Process to run samtools view to split each provided test sample by chromosomes present.
 * 
 * Separates the input files on a chromosome-by-chromosome basis.
 * @see https://www.htslib.org/doc/samtools-view.html
 * 
 * @input samplesheet - metadata map to the sample input information, including [ meta, [ samplePath ], [ sampleIndex ], [ pedigree ] ]
 * @emit splitSamples - containing the samples split by chromosome, including [ meta, chromosome, [ samplePath+BY_CHR ], [ sampleIndex+BY_CHR ], [ pedigree ] ]
 */

 process samtools_split_samples {
    
    label 'samtools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/input_files/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), val(chromosomes), path(sample), path(sampleIndex), path(pedigree)

    output:
        tuple val(metadata), val(chromosomes), path("${metadata.sampleID}_${chromosomes}.bcf"), path("${metadata.sampleID}_${chromosomes}.bcf.csi"), path(pedigree), emit: splitSamples

    script:
        """
        samtools view -r ${chromosomes} \\
        -b \\
        -o ${metadata.sampleID}_${chromosomes}.bcf \\
        --write-index \\
        ${sample}
        """
 }