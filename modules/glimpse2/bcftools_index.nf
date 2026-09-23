/**
 * Process to index the ligated imputed files provided by the user. 
 * 
 * Generates an index file associated with the ligated and imputed samples.
 * @see BCFtools documentation https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input 
 * @emit
 */

 process bcftools_index {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/final_imputed_samples/",
        mode:    "copy"
    )

    input:
        tuple val(rMetadata), path(ligatedSamples)

    output:
        tuple path(ligatedSamples), path("*.bcf.csi"), emit: ligatedIndexedSamples
        
    script:
        """
        bcftools index \\
        ${ligatedSamples}
        """
 }