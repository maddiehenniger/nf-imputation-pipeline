/**
 * Process to run SHAPEIT5 to phase the test samples to the intermediate reference population.
 * 
 * Generates phased samples.
 * @see https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/
 * 
 * @input Map of input samples, intermediate reference to be used, and region(s) of chromosomes to phase.
 * @emit phased
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
        tuple val(meta), path(samplePath), path(sampleIndexPath)
        tuple val(metaRef), path(referencePath), path(referenceIndexPath)
        tuple val(chromosomeNum), path(recombinationMapFile)

    output:
        tuple path("${meta.sampleName}_${chromosomeNum}_phased.bcf"), val(chromosomeNum), path(recombinationMapFile) emit: phasedSamples

    script:
        """
        SHAPEIT5_phase_common \\
            --input ${samplePath} \\
            --reference ${referencePath} \\
            --thread 24 \\
            --filter-maf 0.001 \\
            --map ${recombinationMapFile} \\
            --region ${chromosomeNum} \\
            --output ${meta.sampleName}_${chromosomeNum}_phased.bcf
        """
 }