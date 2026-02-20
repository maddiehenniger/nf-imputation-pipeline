/**
 * Process to run bcftools stats on the imputed sample(s).
 * 
 * Generates non-reference discordance rates, concordance, 
 * @see https://samtools.github.io/bcftools/bcftools.html#stats
 * 
 * @input Channel containing the chromosome, sampleID, path to imputed sample, and path to indexed imputed sample [ chr, [ meta ], imputedSample, imputedSampleIdx ]
 * @emit bySampleStats - 
 */

 process bcftools_stats_samples {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.calculate_accuracy/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(chr), val(meta), path(imputedSample), path(imputedSampleIdx)

    output:
        tuple

    script:
        """
        bcftools query \\
            -f '%CHROM' ${refPath} | sort -u -n
        """
 }