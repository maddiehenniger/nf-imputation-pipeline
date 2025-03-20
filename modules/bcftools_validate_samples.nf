/**
 * Process to run bcftools view on sample files to print chromosomes.
 * 
 * Generates a text file with the list of chromosomes present in the input samples.
 * @see https://samtools.github.io/bcftools/bcftools.html#view
 * 
 * @input sample - the samples to be assessed for chromosome number
 * @emit sample_chr - Values for chromosomes present
 */
 
process bcftools_validate_samples {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/0_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple path(sample), path(sampleIndex)

    output:
        path "${sample}_chr.txt", emit: sample_chr

    script:
        """
        bcftools view \
            -H -G ${sample} | awk '{print $1}' >> ${sample}_chr.txt 
        """
}