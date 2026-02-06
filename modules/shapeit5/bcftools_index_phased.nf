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
        path:    "${params.publishDirData}/phased_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(chr), val(sMetadata), path(phasedSample), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap)

    output:
        tuple val(chr), val(sMetadata), path(phasedSample), path("*.csi"), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap), emit: phasedSamples

    script:
        """
        bcftools index \
            ${phasedSample}
        """
 }