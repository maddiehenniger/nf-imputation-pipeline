/**
 * Process to run SHAPEIT4 to phase the test samples without using a reference, specifically to get around limitations with a small input sample size (<50 individuals)
 * 
 * Generates phased samples and associated index file.
 * @see https://odelaneau.github.io/shapeit4/#documentation
 * 
 * @input 
 * @emit
 */

 process shapeit4_phase_common_noref {
    
    label 'shapeit4'

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
       
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        if(rMetadata.geneticMaps == 'provided') {
            """
            shapeit4 \\
                ${args} \\
                --input ${sample} \\
                --region ${chromosome} \\
                --output ${sMetadata.sampleID}.${chromosome}.phased.bcf \\
                --map ${geneticMap} \\
                --log ${sMetadata.sampleID}.${chromosome}.phased.log
            """ 
        } else if(rMetadata.geneticMaps == 'none') {
            """
            shapeit4 \\
                ${args} \\
                --input ${sample} \\
                --region ${chromosome} \\
                --output ${sMetadata.sampleID}.${chromosome}.phased.bcf \\
                --log ${sMetadata.sampleID}.${chromosome}.phased.log
            """
        }
 }