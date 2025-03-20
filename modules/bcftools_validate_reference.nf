/**
 * Process to run bcftools view on reference files to print chromosomes.
 * 
 * Generates a text file with the list of chromosomes present in the input reference(s).
 * @see https://samtools.github.io/bcftools/bcftools.html#view
 * 
 * @input reference - the reference(s) to be assessed for chromosome number.
 * @emit reference_chr - Values for chromosomes present in reference file(s).
 */
 
process bcftools_validate_reference {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/0_references/",
        mode:    "${params.publishMode}"
    )

    input:
        

    output:
        path "${reference_intermediate}_chr.txt", emit: reference_intermediate_chr
        path "${reference_twostep}_chr.txt", emit: reference_twostep_chr

    script:
        """
        bcftools view \
            -H -G ${sample} | awk '{print $1}' >> ${sample}_chr.txt 
        """
}