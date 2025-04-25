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
        path:    "${params.publishDirData}/.intermediate_imputed_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(sample_id), val(chromosomeNum), path(intermediateByChromosome), path(recombinationMapFile)

    output:
        tuple val(sample_id), val(chromosomeNum), path("${sample_id}_intermediate_ligated.bcf"), path(recombinationMapFile), emit: intermediateJoinedImputation

    script:
        """
        ls -v ${sample_id}*.bcf >> ${sample_id}_file_names.txt

        bcftools concat \
        -n \
        -f ${sample_id}_file_names.txt \
        -Ob \
        -o ${sample_id}_intermediate_ligated.bcf
        """
 }