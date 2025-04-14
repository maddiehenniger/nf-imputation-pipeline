/**
 * Process to convert the reference panel to an XCF file.
 * 
 * Generates 
 * @see IMPUTE5 documentation https://jmarchini.org/software/#impute-5
 * 
 * @input 
 * @emit
 */

 process convert_int_ref_to_xcf {

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/.reference_xcf/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(metaRef), path(referencePath), path(referenceIndexPath)
        val(chromosomes)

    output:
        path "${referencePath.baseName}_${chromosomes}_xcf.bcf", emit: xcfIntermediateReference
        path "${referencePath.baseName}_${chromosomes}_xcf_log.out", emit: xcfIntermediateReferenceLog

    script:
        """
        xcftools_static view \
            --input ${referencePath} \
            --output ${referencePath.baseName}_${chromosomes}_xcf.bcf \
            --format sh \
            --region ${chromosomes} \
            --thread 8 \
            --maf 0.03125 \
            --log ${referencePath.baseName}_${chromosomes}_xcf_log.out
        """
 }