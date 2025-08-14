/**
 * Process to run bcftools query on the provided reference(s).
 * 
 * Generates a list of chromosome numbers present in the reference(s).
 * @see https://samtools.github.io/bcftools/bcftools.html#query
 * 
 * @input A map containing reference sheet metadata, path to the references, path to the indexed references, and path to the genetic maps if provided.
 * @emit chromosomes - A text file containing the unique and sorted chromosome numbers from the reference.
 */

 process bcftools_query_references {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.chromosome_validation/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(meta), path(refPath), path(refIdx), path(mapPath)

    output:
        tuple val(meta), path(refPath), path(refIdx), path(mapPath), stdout

    script:
        """
        bcftools query \\
            -f '%CHROM' ${refPath} | sort -u -n
        """
 }