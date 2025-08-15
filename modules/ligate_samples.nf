/**
 * Process to run bcftools concat to ligate all chunked imputed BCFs together.
 * 
 * Generates a combined BCF file from the output imputation step for each input sample.
 * @see https://samtools.github.io/bcftools/bcftools.html#concat
 * 
 * @input 
 * @emit 
 */

 process bcftools_concat_by_sample {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.${metadata.step}_imputed_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(chr), val(meta), path(chunkedCoordinates), path(ligatedByChr), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath)

    output:
        tuple val(chr), val(meta), path(chunkedCoordinates), path("${meta.sampleID}_${metadata.step}_ligated.bcf"), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath), emit: ligateSample

    script:
        """
        ls -v ${meta.sampleID}*.bcf >> ${meta.sampleID}_file_names.txt

        bcftools concat \
        -n \
        -f ${meta.sampleID}_file_names.txt \
        -Ob \
        -o ${meta.sampleID}_${metadata.step}_ligated.bcf
        """
 }