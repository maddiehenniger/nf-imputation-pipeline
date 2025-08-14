/**
 * Process to run SHAPEIT5 to phase the test samples to the intermediate reference population.
 * 
 * Generates phased samples.
 * @see https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/
 * 
 * @input A map containing the test sample metadata, chromosome, path to the by-chromosome sample file, and path to the by-chromosome indexed sample file
 *        A map of the reference panel metadata for the first round of imputation, path to 'one' reference, path to the 'one' indexed reference, and path to the optionally provided genetic map.
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
        tuple val(chr), val(meta), path(samplePath), path(sampleIdx), val(metadata), path(referencePath), path(referenceIdx), path(mapPath)

    output:
        tuple val(chr), val(meta), path("${meta.sampleID}_${chr}_phased.bcf"), val(metadata), path(refPath), path(refIdx), path(mapPath), emit: phasedSamples

    script:

        if(metadata.geneticMaps == 'provided') {
            """
            SHAPEIT5_phase_common \\
                --input ${samplePath} \\
                --reference ${refPath} \\
                --region ${chr} \\
                --output ${meta.sampleID}_${chr}_phased.bcf \\
                --map ${mapPath}
            """ 
        } else if(metadata.geneticMaps == 'none') {
            """
            SHAPEIT5_phase_common \\
                --input ${samplePath} \\
                --reference ${refPath} \\
                --region ${chr} \\
                --output ${meta.sampleID}_${chr}_phased.bcf
            """
        }
 }