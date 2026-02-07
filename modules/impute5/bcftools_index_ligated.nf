/**
 * Process to run bcftools index to index the ligated and imputed BCFs together.
 * 
 * Generates an indexed file for the combined BCF file from the output imputation step for each input sample.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input 
 * @emit 
 */

 process bcftools_index_ligated {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/final_imputed_samples/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(imputedSample), path(wgs), path(wgsIndex)

    output:
        tuple val(chromosome), val(sMetadata), path(imputedSample), path("*.csi"), path(wgs), path(wgsIndex), emit: ligatedIndexed

    script:
        """
        bcftools index \\
        ${imputedSample}
        """
 }