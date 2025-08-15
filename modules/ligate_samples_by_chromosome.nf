/**
 * Process to run bcftools concat to ligate all chunked imputed BCFs together.
 * 
 * Generates a combined BCF file from the output imputation step for each input sample.
 * @see https://samtools.github.io/bcftools/bcftools.html#concat
 * 
 * @input 
 * @emit 
 */

 process bcftools_concat_by_chromosome {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.${metadata.step}_imputed_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(chr), val(meta), path(phasedSample), path(phasedIdx), path(chunkedCoordinates), path(chunkedImputed), path (chunkedImputedIdx), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath), emit: imputedSamples

    output:
        tuple val(chr), val(meta), path(chunkedCoordinates), path("${meta.sampleID}_${metadata.step}_ligated_${chr}.bcf"), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath), emit: ligateByChr

    script:
        """
        ls -v ${meta.sampleID}_${metadata.step}_${chr}*.bcf >> ${meta.sampleID}_file_names_${chr}.txt

        bcftools concat \
        -n \
        -f ${meta.sampleID}_file_names_${chr}.txt \
        -Ob \
        -o ${meta.sampleID}_${metadata.step}_ligated_${chr}.bcf
        """
 }