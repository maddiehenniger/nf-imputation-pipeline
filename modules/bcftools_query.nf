/**
 * Process to run bcftools query.
 * 
 * Generates a list of chromosome numbers present in sample and reference files.
 * @see https://samtools.github.io/bcftools/bcftools.html#query
 * 
 * @input LinkedHashMap 
 * @emit
 */

 process bcftools_query {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.chromosome_validation/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(metaSamples), path(samplePath), path(samplePathIndex)
        tuple val(metaReferences), path(referencePath), path(referencePathIndex)

    output:
        path "${metaSamples.sampleName}_chromosomes.txt", emit: sampleChr
        path "${metaReferences.sampleName}_chromosomes.txt", emit: referenceChr

    script:
        """
        bcftools query \
            -f '%CHROM' | sort -u > ${inputs}_chromosomes.txt
        """
 }