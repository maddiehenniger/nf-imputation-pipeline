/**
 * Process to convert the reference panel to an XCF file.
 * 
 * Generates the XCF file format of the reference to improve processing speed.
 * @see IMPUTE5 documentation https://jmarchini.org/software/#impute-5
 * 
 * @input references
 * @emit xcfReferences - 
 */

 process convert_reference_to_xcf {

    publishDir(
        path:    "${params.publishDirData}/references/",
        mode:    "symlink",
    )

    input:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap)

    output:
        tuple val(metadata), path("${metadata.referenceID}_${metadata.chromosome}.xcf.bcf"), path("${metadata.referenceID}_${metadata.chromosome}.xcf.bcf.csi"), path("${metadata.referenceID}_${metadata.chromosome}.xcf.bin"), path("${metadata.referenceID}_${metadata.chromosome}.xcf.fam"), path(geneticMap), emit: xcfReference
        path "${metadata.referenceID}_${metadata.chromosome}.xcf.log.out", emit: xcfLog

    script:
        """
        xcftools_static view \\
            --input ${reference} \\
            --output ${metadata.referenceID}_${metadata.chromosome}.xcf.bcf \\
            --format sh \\
            --region ${metadata.chromosome} \\
            --thread 8 \\
            --maf 0.03125 \\
            --log ${metadata.referenceID}_${metadata.chromosome}.xcf.log.out
        """
 }