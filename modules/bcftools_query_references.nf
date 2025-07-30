/**
 * Process to run bcftools query on the provided reference(s).
 * 
 * Generates a list of chromosome numbers present in the reference(s).
 * @see https://samtools.github.io/bcftools/bcftools.html#query
 * 
 * @input LinkedHashMap 
 * @emit
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
        path "${meta.id}_chromosomes.txt", emit: chromosomes

    script:
        """
        bcftools query \
            -f '%CHROM' ${refPath} | sort -u -n >> ${meta.id}_chromosomes.txt
        """
 }