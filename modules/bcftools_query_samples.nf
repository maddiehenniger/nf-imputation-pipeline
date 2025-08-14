/**
 * Process to run bcftools query.
 * 
 * Generates a list of chromosome numbers present in sample and reference files.
 * @see https://samtools.github.io/bcftools/bcftools.html#query
 * 
 * @input A map containing the test sample metadata, path to the test samples, and path to the indexed test samples.
 * @emit chromosomes - A text file containing the unique and sorted chromosome numbers from the test samples.
 */

 process bcftools_query_samples {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.chromosome_validation/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(meta), path(samplePath), path(sampleIdx)

    output:
        tuple val(meta), path(samplePath), path(sampleIdx), stdout

    script:
        """
        bcftools query \\
            -f '%CHROM' ${samplePath} | sort -u -n
        """
 }