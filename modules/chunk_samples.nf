/**
 * Process to run Imp5Chunker to create imputation cunks from the target and reference panel. 
 * 
 * Generates a text file containing the following fields: Chunk ID / chromosome ID / Buffered region / Imputation region / Length / Number of target markers / Number of reference markers
 * @see IMPUTE5 documentation https://jmarchini.org/software/#impute-5
 * 
 * @input A channel containing the chromosome, test sample metadata, path to by-chromosome phased sample, path to the associated by-chromosome indexed phased sample, the reference panel metadata, the path to the reference panel, the path to the associated indexed reference panel, and the optionally provided path to the genetic map
 * @emit chunkedRegions - Containing the chromosome, test sample metadata, path to the by-chromosome phased sample, path to the associated by-chromosome indexed phased sample, path to the text file containing the chunked coordinates, the reference panel metadata, the path to the reference panel, the path to the associated indexed reference panel, and the optionally provided path to the genetic map
 */

 process chunk_samples {

    stageInMode 'copy'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/.chunked_regions/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(chr), val(meta), path(phasedSample), path(phasedIdx), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath)

    output:
        tuple val(chr), val(meta), path(phasedSample), path(phasedIdx), path("${meta.sampleID}_${chr}_chunked_coords.txt"), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath), emit: chunkedRegions

    script:

        """
        imp5Chunker_v1.2.0_static \\
            --h ${xcfRefPath} \\
            --g ${phasedSample} \\
            --r ${chr} \\
            --l ${meta.sampleID}_chunking.log \\
            --o ${meta.sampleID}_${chr}_chunked_coords.txt
        """
 }