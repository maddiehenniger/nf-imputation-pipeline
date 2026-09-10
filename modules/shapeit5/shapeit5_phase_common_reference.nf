/**
 * Process to run SHAPEIT5 to phase the test samples to the 'round one' reference panel.
 * 
 * Generates phased samples and associated index file.
 * @see https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/
 * 
 * @input 
 * @emit
 */

 process shapeit5_phase_common_reference {
    
    label 'shapeit5'

    label 'max_cpu'
    label 'max_mem'
    label 'max_time'

    publishDir(
        path:    "${params.publishDirData}/phased_samples/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(sample), path(sampleIndex), path(pedigree), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap)
        
    output:
        tuple val(chromosome), val(sMetadata), path("${sMetadata.sampleID}.${chromosome}.phased.bcf"), path("${sMetadata.sampleID}.${chromosome}.phased.bcf.csi"), path(pedigree), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap), emit: phasedSamples
        path("*log"), emit: phasedLog

    script:

        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        def pedigree_command = pedigree ? "--pedigree ${pedigree}"  : ""
        def genetic_map_command = geneticMap ? "--map ${geneticMap}" : ""

        """
        SHAPEIT5_phase_common \\
            ${args} \\
            ${genetic_map_command} \\
            ${pedigree_command} \\
            --thread ${task.cpus} \\
            --input ${sample} \\
            --reference ${reference} \\
            --region ${chromosome} \\
            --output ${sMetadata.sampleID}.${chromosome}.phased.bcf \\
            --log ${sMetadata.sampleID}.${chromosome}.phased.log
        """ 
 }