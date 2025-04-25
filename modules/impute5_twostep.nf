/**
 * Process to run SHAPEIT5 to phase the test samples to the intermediate reference population.
 * 
 * Generates phased samples.
 * @see https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/
 * 
 * @input Map of input samples, intermediate reference to be used, and region(s) of chromosomes to phase.
 * @emit phased
 */

 process impute5_impute_twostep_samples {
    
    tag "$sample_id"

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/.twostep_imputed_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(sample_id), path(sampleBcf), path(sampleBcfIndex), val(chromosomeNum), path(chunkedCoordinates), path(recombinationMapFile)
        tuple val(metaRef), path(referencePath), path(referenceIndexPath), path(xcfIntermediateReferencePath), path(xcfIntermediateReferenceIndexPath), path(xcfIntBin), path(xcfIntFam)

    output:
        tuple val(sample_id), val(chromosomeNum), path("*.bcf"), path("*.csi"), path(recombinationMapFile), emit: twostepImputation
        path "*.log", emit: twostepImputationLog

    script:
        """
        while IFS= read -r line; do
        chr=\$(echo "\$line" | awk '{print \$2}')
        region=\$(echo "\$line" | awk '{print \$4}')
        buffer=\$(echo "\$line" | awk '{print \$3}')
        count=\$(echo "\$line" | awk '{print \$1}')
        out_file="${sample_id}_twostep_${chromosomeNum}_\${count}.bcf"
        log_file="${sample_id}_twostep_${chromosomeNum}_\${count}.log"
        impute5_v1.2.0_static \
            --h ${xcfIntermediateReferencePath} \
            --g ${sampleBcf} \
            --r \${region} \
            --buffer-region \${buffer} \
            --m ${recombinationMapFile} \
            --o \${out_file} \
            --l \${log_file}
        done < ${chunkedCoordinates}
        """
 }