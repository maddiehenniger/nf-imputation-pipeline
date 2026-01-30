/**
 * Process to create imputation chunks from the reference panel using GLIMPSE2.
 * 
 * Generates a binary reference file path for each imputed chunk.
 * @see IMPUTE5 documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/split_reference/
 * 
 * @input 
 * @emit
 */

 process glimpse2_split_reference {

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_references/split_references/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path(chunkedRegions)

    output:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path("${metadata.referenceID}.chunks.${metadata.chromosome}*"), emit: chunkedReference

    script:
        """
        while IFS="" read -r LINE || [-n "\$LINE" ];
        do
            printf -v ID "%02d" \$(echo \$LINE | cut -d" " -f1)
            IRG=\$(echo \$LINE | cut -d" " -f3)
            ORG=\$(echo \$LINE | cut -d" " -f4)
            GLIMPSE2_split_reference_static \\
                -R ${reference} \\
                -M ${geneticMap} \\
                --input-region \\
                --output-region \\
                -O ${metadata.referenceID}.chunks.${metadata.chromosome} \\
                --log ${metadata.referenceID}.chunks.${metadata.chromosome}.log
        done < ${chunkedRegions}
        """
 }