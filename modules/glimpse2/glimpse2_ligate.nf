/**
 * Process to ligate imputed samples together with GLIMPSE2.
 *
 * Uses the imputed chunks generated during GLIMPSE2 phase to ligate samples together.
 * @see GLIMPSE2 documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/ligate/
 *
 *
 * @input
 * @emit
 */

 process glimpse2_ligate {

    tag "${chromosome}-${rMetadata.referenceID}"

    label 'glimpse2'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_ligated_samples/",
        mode:    "symlink"
    )

    input:
        tuple val(rMetadata), path(refPath), path(refIdx), path(geneticMap), path(chunkedRegions), path(refBins), path(imputedSamples), path(imputedSamplesIndex)

    output:
        tuple val(rMetadata), path("imputed.chr.${rMetadata.chromosome}.bcf"), emit: ligatedImputedSamples

    script:
        """
        ls -1v *.bcf > imputed_files.txt

        GLIMPSE2_ligate \\
            -I imputed_files.txt \\
            -T ${task.cpus} \\
            -O imputed.chr.${rMetadata.chromosome}.bcf
        """
 }