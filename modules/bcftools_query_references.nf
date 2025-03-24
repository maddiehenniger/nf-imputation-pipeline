/**
 * Process to run bcftools query on the provided reference(s).
 * 
 * Generates a list of chromosome numbers present in the reference(s).
 * @see https://samtools.github.io/bcftools/bcftools.html#query
 * 
 * @input LinkedHashMap 
 * @emit
 */

 process bcftools_query_reference {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.chromosome_validation/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(meta), path(referencePath), path(referenceIndexPath)

    output:
        path "${meta.referenceName}_chromosomes.txt", emit: refChromosomes

    script:
        """
        bcftools query \
            -f '%CHROM' ${referencePath} | sort -u -n >> ${meta.referenceName}_chromosomes.txt
        """
 }