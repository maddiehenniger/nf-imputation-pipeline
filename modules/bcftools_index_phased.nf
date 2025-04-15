/**
 * Process to run bcftools index on the phased samples.
 * 
 * Generates an index (CSI) file for the phased reference.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input LinkedHashMap 
 * @emit
 */

 process bcftools_index_phased {
    
    tag "$sample_id"

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.phased_samples/$sample_id",
        mode:    "${params.publishMode}",
        pattern: '*.{bcf,bcf.csi}'
    )

    input:
        tuple val(sample_id), path(bcf), val(chromosomeNum), path(recombinationMapFile)

    output:
       tuple val(sample_id), path(bcf), path("*.bcf.csi"), val(chromosomeNum), path(recombinationMapFile), emit: indexedPhasedPair

    script:
        """
        bcftools index \
            ${bcf.name}
        """
 }