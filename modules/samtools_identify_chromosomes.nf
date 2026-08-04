/**
 * Process to run samtools view to identify chromosomes present in input file.
 * 
 * Produces a text file containing the sorted and unique chromosome IDs present within each provided file.
 * @see https://www.htslib.org/doc/samtools-view.html
 * 
 * @input samplesheet - metadata map to the sample input information, including [ meta, [ samplePath ], [ sampleIndex ], [ pedigree ] ]
 * @emit chromosomes - metadata map updated with a list of chromosomes present for each input sample, including [ meta, [ chromosomeFile ], [ samplePath ], [ sampleIndex ], [ pedigree ] ]
 */

 process samtools_identify_chromosomes {
    
    label 'samtools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/chromosome_validation/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(sample), path(sampleIndex), path(pedigree)

    output:
        tuple val(metadata), stdout, path(sample), path(sampleIndex), path(pedigree), emit: chromosomes

    script:
        """
        samtools view -H ${sample} | grep '^@SQ' | cut -f2 | sed 's/SN://'
        """
 }