/**
 * Process to run bcftools concat to ligate all chunked imputed BCFs together.
 * 
 * Generates a combined BCF file from the output imputation step for each input sample.
 * @see https://samtools.github.io/bcftools/bcftools.html#concat
 * 
 * @input 
 * @emit 
 */

 process bcftools_ligate_chromosomes {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/final_imputed_samples/",
        pattern: "*.ligated.${chromosome}.bcf",
        mode:    "copy"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(imputedSample), path(imputedSampleIndex), path(chunkedCoordinates), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap)

    output:
        tuple val(chromosome), val(sMetadata), path("${sMetadata.sampleID}.${rMetadata.round}.ligated.${chromosome}.bcf"), path(wgs), path(wgsIndex), emit: ligatedByChr

    script:
        """
        ls -v ${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.*.bcf > ${sMetadata.sampleID}.${rMetadata.round}.filenames.${chromosome}.txt

        bcftools concat \\
        -n \\
        -f ${sMetadata.sampleID}.${rMetadata.round}.filenames.${chromosome}.txt \\
        -Ob \\
        -o ${sMetadata.sampleID}.${rMetadata.round}.ligated.${chromosome}.bcf
        """
 }