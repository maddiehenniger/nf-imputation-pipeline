/**
 * Process to run SHAPEIT5 to phase the test samples to the 'round one' reference panel.
 * 
 * Generates phased samples and associated index file.
 * @see https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/
 * 
 * @input 
 * @emit
 */

 process shapeit5_phase_common {
    
    label 'shapeit5'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/phased_samples/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(sample), path(sampleIndex), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap)
        
    output:
        tuple val(chromosome), val(sMetadata), path("${metadata.sampleID}.${chromosome}.phased.bcf"), path("${metadata.sampleID}.${chromosome}.phased.bcf.csi"), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap), emit: phasedSamples
        path("*log"), emit: phasedLog

    script:
        if(rMetadata.geneticMaps == 'provided') {
            """
            SHAPEIT5_phase_common \\
                ${args} \\
                --input ${sample} \\
                --reference ${reference} \\
                --region ${chromosome} \\
                --output ${sMetadata.sampleID}.${chromosome}.phased.bcf \\
                --map ${geneticMap} \\
                --log ${sMetadata.sampleID}.${chromosome}.phased.log
            """ 
        } else if(rMetadata.geneticMaps == 'none') {
            """
            SHAPEIT5_phase_common \\
                ${args} \\
                --input ${sample} \\
                --reference ${reference} \\
                --region ${chromosome} \\
                --output ${sMetadata.sampleID}.${chromosome}.phased.bcf \\
                --log ${sMetadata.sampleID}.${chromosome}.phased.log
            """
        }
 }