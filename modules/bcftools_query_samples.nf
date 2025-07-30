/**
 * Process to run bcftools query.
 * 
 * Generates a list of chromosome numbers present in sample and reference files.
 * @see https://samtools.github.io/bcftools/bcftools.html#query
 * 
 * @input LinkedHashMap 
 * @emit
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
        tuple val(meta), path(samplePath), path(sampleIndexPath)

    output:
        path "${meta.id}_chromosomes.txt", emit: chromosomes

    script:
        """
        bcftools query \
            -f '%CHROM' ${samplePath} | sort -u -n >> ${meta.id}_chromosomes.txt
        """
 }