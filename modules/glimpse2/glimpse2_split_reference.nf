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

    label 'glimpse2'

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
        
        def genetic_map_command = geneticMap ? "-M ${geneticMap}"  : ""

        """
        while IFS= read -r line; do
        chr=\$(echo "\$line" | awk '{print \$2}')
        region=\$(echo "\$line" | awk '{print \$4}')
        buffer=\$(echo "\$line" | awk '{print \$3}')
        count=\$(echo "\$line" | awk '{print \$1}')
        out_file="${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.bcf"
        log_file="${sMetadata.sampleID}.${rMetadata.round}.${chromosome}.\${count}.log"
        GLIMPSE2_split_reference \\
            ${genetic_map_command} \\
            -R ${reference} \\
            --input-region \${buffer} \\
            --output-region \${region} \\
            -O \${out_file} \\
            --log \${log_file}
        done < ${chunkedRegions}
        """
 }