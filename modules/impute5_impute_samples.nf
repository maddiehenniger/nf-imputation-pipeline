/**
 * Process to run SHAPEIT5 to phase the test samples to the intermediate reference population.
 * 
 * Generates phased samples.
 * @see https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/
 * 
 * @input Map of input samples, intermediate reference to be used, and region(s) of chromosomes to phase.
 * @emit phased
 */

 process impute5_impute_samples {
    
    tag "$sample_id"

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/.intermediate_imputed_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(sample_id), path(sampleBcf), path(sampleBcfIndex), val(chromosomeNum), path(chunkedCoordinates), path(recombinationMapFile)
        tuple val(metaRef), path(referencePath), path(referenceIndexPath), path(xcfIntermediateReferencePath), path(xcfIntermediateReferenceIndexPath), path(xcfIntBin), path(xcfIntFam)

    output:
        path "${sampleBcf.baseName}_${chromosomeNum}_intermediate_imputation.bcf", emit: intermediateImputation
        path "${sampleBcf.baseName}_${chromosomeNum}_intermediate_imputation.log", emit: intermediateImputationLog

    script:
        """
        while IFS= read -r line; do
        chr=\$(echo "\$line" | awk '{print \$2}')
        region=\$(echo "\$line" | awk '{print \$4}')
        buffer=\$(echo "\$line" | awk '{print \$3}')
        count=\$(echo "\$line" | awk '{print \$1}')
        out_file="${sampleBcf.baseName}_${chromosomeNum}_intermediate_imputation.bcf"
        log_file="${sampleBcf.baseName}_${chromosomeNum}_intermediate_imputation.log"
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