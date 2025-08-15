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
        path:    "${params.publishDirData}/.${metadata.step}_imputed_samples/",
        mode:    "${params.publishMode}"
    )

    input:
        tuple val(chr), val(meta), path(phasedSample), path(phasedIdx), path(chunkedCoordinates), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath)

    output:
        tuple val(chr), val(meta), path(phasedSample), path(phasedIdx), path(chunkedCoordinates), path("*.bcf"), path ("*.bcf.csi"), val(metadata), path(xcfRefPath), path(xcfRefIdx), path(xcfRefBin), path(xcfRefFam), path(mapPath), emit: imputedSamples
        path "*.log", emit: imputationLog

    script:

        if(metadata.geneticMaps == 'provided') {
            """
            while IFS= read -r line; do
            chr=\$(echo "\$line" | awk '{print \$2}')
            region=\$(echo "\$line" | awk '{print \$4}')
            buffer=\$(echo "\$line" | awk '{print \$3}')
            count=\$(echo "\$line" | awk '{print \$1}')
            out_file="${meta.sampleID}_${metadata.step}_${chr}_\${count}.bcf"
            log_file="${meta.sampleID}_${metadata.step}_${chr}_\${count}.log"
            impute5_v1.2.0_static \\
                --h ${xcfRefPath} \\
                --g ${phasedSample} \\
                --r \${region} \\
                --buffer-region \${buffer} \\
                --m ${mapPath} \\
                --o \${out_file} \\
                --l \${log_file}
            done < ${chunkedCoordinates}
            """
        } else if(metadata.geneticMaps == 'none') {
            """
            while IFS= read -r line; do
            chr=\$(echo "\$line" | awk '{print \$2}')
            region=\$(echo "\$line" | awk '{print \$4}')
            buffer=\$(echo "\$line" | awk '{print \$3}')
            count=\$(echo "\$line" | awk '{print \$1}')
            out_file="${meta.sampleID}_${metadata.step}_${chr}_\${count}.bcf"
            log_file="${meta.sampleID}_${metadata.step}_${chr}_\${count}.log"
            impute5_v1.2.0_static \\
                --h ${xcfRefPath} \\
                --g ${phasedSample} \\
                --r \${region} \\
                --buffer-region \${buffer} \\
                --o \${out_file} \\
                --l \${log_file}
            done < ${chunkedCoordinates}
            """
        }
 }