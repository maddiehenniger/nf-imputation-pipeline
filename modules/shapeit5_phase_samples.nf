/**
 * Process to run SHAPEIT5 to phase the test samples to the intermediate reference population.
 * 
 * Generates phased samples.
 * @see https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/
 * 
 * @input A map of test sample metadata, path to sample, and path to the indexed sample
 *        A map of the reference panel metadata, path to reference, path to the indexed reference, and path to the optionally provided genetic map.
 * @emit phasedSamples - TBD lol 
 */

 process shapeit5_phase_samples {
    
    label 'shapeit5'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/.phased_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(meta), path(samplePath), path(sampleIdx)
        tuple val(metadata), path(refPath), path(refIdx), path(mapPath)

    output:
        tuple val(meta), val(metadata.chromosome), path("${meta.id}_${metadata.chromosome}_phased.bcf"), path(refPath), path(refIdx), path(mapPath), emit: phasedSamples

    script:

        if(metadata.geneticMaps == 'provided') {
            """
            SHAPEIT5_phase_common \\
                --input ${samplePath} \\
                --reference ${refPath} \\
                --region ${metadata.chromosome} \\
                --output ${meta.id}_${metadata.chromosome}_phased.bcf \\
                --map ${mapPath}
            """ 
        } else if(metadata.geneticMaps == 'none') {
            """
            SHAPEIT5_phase_common \\
                --input ${samplePath} \\
                --reference ${refPath} \\
                --region ${metadata.chromosome} \\
                --output ${meta.id}_${metadata.chromosome}_phased.bcf
            """
        }
 }