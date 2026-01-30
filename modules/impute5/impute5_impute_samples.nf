/**
 * Process to run IMPUTE5 to impute the test samples to the reference population.
 * 
 * Generates imputed samples by pre-specified chunks of chromosomes.
 * @see https://jmarchini.org/software/#impute-5
 * 
 * @input
 * @emit 
 */

 process impute5_impute_samples {

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/${rMetadata.round}_imputed_samples/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(phasedSample), path(phasedIndex), path(chunkedCoordinates), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap)

    output:
        tuple val(chromosome), val(sMetadata), path("${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.bcf"), path("${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.bcf.csi"), path(chunkedCoordinates), path(wgs), path(wgsIndex), val(rMetadata), path(reference), path(referenceIndices), path(geneticMap), emit: imputedSamples
        path "*.log", emit: imputationLog

    script:
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()

        if(rMetadata.geneticMaps == 'provided') {
            """
            while IFS= read -r line; do
            chr=\$(echo "\$line" | awk '{print \$2}')
            region=\$(echo "\$line" | awk '{print \$4}')
            buffer=\$(echo "\$line" | awk '{print \$3}')
            count=\$(echo "\$line" | awk '{print \$1}')
            out_file="${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.bcf"
            log_file="${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.log"
            impute5_v1.2.0_static \\
                ${args} \\
                --h ${reference} \\
                --g ${phasedSample} \\
                --r \${region} \\
                --buffer-region \${buffer} \\
                --m ${geneticMap} \\
                --o \${out_file} \\
                --l \${log_file}
            done < ${chunkedCoordinates}
            """
        } else if(rMetadata.geneticMaps == 'none') {
            """
            while IFS= read -r line; do
            chr=\$(echo "\$line" | awk '{print \$2}')
            region=\$(echo "\$line" | awk '{print \$4}')
            buffer=\$(echo "\$line" | awk '{print \$3}')
            count=\$(echo "\$line" | awk '{print \$1}')
            out_file="${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.bcf"
            log_file="${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.log"
            impute5_v1.2.0_static \\
                ${args} \\
                --h ${reference} \\
                --g ${phasedSample} \\
                --r \${region} \\
                --buffer-region \${buffer} \\
                --o \${out_file} \\
                --l \${log_file}
            done < ${chunkedCoordinates}
            """
        }
 }