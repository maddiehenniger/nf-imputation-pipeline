/**
 * Process to generate imputation accuracy statistics.
 * 
 * Generates 
 * @see 
 * 
 * @input 
 * @emit
 */

 process assess_imputation_accuracy {

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/imputation_accuracy/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(metaRef), path(referencePath), path(referenceIndexPath)
        tuple val(sample_id), path(sampleBcf), path(sampleBcfIndex), val(chromosomeNum), path(recombinationMapFile)

    output:
        tuple val(metaRef), path(referencePath), path(referenceIndexPath), path("${referencePath.baseName}_${chromosomeNum}_xcf.bcf"), path("${referencePath.baseName}_${chromosomeNum}_xcf.bcf.csi"), path("${referencePath.baseName}_${chromosomeNum}_xcf.bin"), path("${referencePath.baseName}_${chromosomeNum}_xcf.fam"), emit: xcfIntermediateReference
        path "${referencePath.baseName}_${chromosomeNum}_xcf_log.out", emit: xcfIntermediateReferenceLog

    script:
        """
        python3.6 Compare_imputation_to_WGS.py \\
        --ga ${samplePath} \\
        --imputed ${imputedSample} \\
        --wgs ${groundTruth}
        """
 }