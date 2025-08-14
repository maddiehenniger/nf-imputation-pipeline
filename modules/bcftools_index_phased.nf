/**
 * Process to run bcftools index on the phased samples.
 * 
 * Generates an index (CSI) file for the phased reference.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input  
 * @emit
 */

 process bcftools_index_phased {

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
        tuple val(chr), val(meta), path("${meta.sampleID}_${chr}_phased.bcf"), val(metadata), path(refPath), path(refIdx), path(mapPath)

    output:
        tuple val(chr), val(meta), path("${meta.sampleID}_${chr}_phased.bcf"), path("*.csi"), val(metadata), path(refPath), path(refIdx), path(mapPath), emit: indexedPhasedPair

    script:
        """
        bcftools index \
            ${bcf.name}
        """
 }