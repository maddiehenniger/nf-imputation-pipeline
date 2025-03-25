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
        val(chromosomes)

    output:
        path "${meta.sampleName}_phased.bcf", emit: phased

    script:
        """
        shapeit5 SHAPEIT5_phase_common \
        --input ${samples} \
        --reference ${reference_intermediate} \
        --thread 24 \
        --region ${chromosomes} \
        --out ${meta.sampleName}_phased.bcf
        """
 }