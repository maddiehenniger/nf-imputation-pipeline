/**
 * Process to run bcftools view to identify chromosomes present in input file.
 * 
 * Produces a text file containing the sorted and unique chromosome IDs present within each sample.
 * @see https://samtools.github.io/bcftools/bcftools.html#view
 * 
 * @input samplesheet - metadata map to the sample input information, including [ meta, [ samplePath ], [ sampleIndex ], [ wgsPath ], [ wgsIndex ] ]
 * @emit chromosomes - metadata map updated with a list of chromosomes present for each input sample, including [ meta, [ chromosomeFile ], [ samplePath ], [ sampleIndex ], [ wgsPath ], [ wgsIndex ] ]
 */

 process bcftools_identify_chromosomes {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/chromosome_validation/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(sample), path(sampleIndex), path(wgs), path(wgsIndex)

    output:
        tuple val(metadata), stdout, path(sample), path(sampleIndex), path(wgs), path(wgsIndex), emit: chromosomes

    script:
        """
        bcftools view -H ${sample} | cut -f1 | sort -n -u
        """
 }