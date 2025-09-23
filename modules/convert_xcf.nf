/**
 * Process to convert the reference panel to an XCF file.
 * 
 * Generates 
 * @see IMPUTE5 documentation https://jmarchini.org/software/#impute-5
 * 
 * @input 
 * @emit
 */

 process convert_xcf {

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    input:
        tuple val(chr), val(metadata), path(refPath), path(refIdx), path(mapPath)

    output:
        tuple val(chr), val(metadata), path("${metadata.referenceID}_${chr}.xcf.bcf"), path("${metadata.referenceID}_${chr}.xcf.bcf.csi"), path("${metadata.referenceID}_${chr}.xcf.bin"), path("${metadata.referenceID}_${chr}.xcf.fam"), path(mapPath), emit: xcfReference
        path "${metadata.referenceID}_${chr}.xcf.log.out", emit: xcfLog

    script:
        """
        xcftools_static view \\
            --input ${refPath} \\
            --output ${metadata.referenceID}_${chr}.xcf.bcf \\
            --format sh \\
            --region ${chr} \\
            --thread 8 \\
            --maf 0.03125 \\
            --log ${metadata.referenceID}_${chr}.xcf.log.out
        """
 }