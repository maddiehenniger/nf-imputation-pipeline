/**
 * Process to run bcftools index on the phased samples.
 * 
 * Generates an index (CSI) file for the phased reference.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input  
 * @emit
 */

 process bcftools_index_imputed {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.${metadata.step}_imputed_samples/",
        mode:    "${params.publishMode}",
        pattern: '*.{bcf,bcf.csi}'
    )

    input:
        tuple val(chr), val(meta), path(chunkedCoordinates), path(ligatedSample), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath)

    output:
        tuple val(chr), val(meta), path(ligatedSample), path("*.csi"), emit: indexedPhasedPair

    script:
        """
        bcftools index \
            ${ligatedSample}
        """
 }