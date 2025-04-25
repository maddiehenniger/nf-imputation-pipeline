/**
 * Process to run bcftools index on the phased samples.
 * 
 * Generates an index (CSI) file for the phased reference.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input LinkedHashMap 
 * @emit
 */

 process bcftools_index_imputed {
    
    tag "$sample_id"

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.two_phased_samples/",
        mode:    "${params.publishMode}",
        pattern: '*.{bcf,bcf.csi}'
    )

    input:
        tuple val(sample_id), val(chromosomeNum), path(intermediateBcf), path(recombinationMapFile)
    output:
        tuple val(sample_id), path(intermediateBcf), path("*.bcf.csi"), val(chromosomeNum), path(recombinationMapFile), emit: indexedIntermediatePaired

    script:
        """
        bcftools index \
            ${intermediateBcf.name}
        """
 }