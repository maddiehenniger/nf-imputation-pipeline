/**
 * Process to create binary references in imputation chunks using GLIMPSE2.
 * 
 * Generates a binary reference file path for chunks of the reference, as output by GLIMPSE2 chunk.
 * @see GLIMPSE2 documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/split_reference/
 * 
 * @input 
 * @emit
 */

 process glimpse2_split_reference {

    tag "${metadata.referenceID}"

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
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path(chunkedRegions), path("${metadata.referenceID}.${metadata.round}.\${chr}.\${count}*.bin"), emit: chunkedReference

    script:
        
        // Allow for user flexible arguments - defined in the conf/args.config file
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()
        // Determine if genetic maps exist or not
        def genetic_map_command = geneticMap ? "-M ${geneticMap}"  : ""

        """
        while IFS= read -r line; do
        chr=\$(echo "\$line" | awk '{print \$2}')
        region=\$(echo "\$line" | awk '{print \$4}')
        buffer=\$(echo "\$line" | awk '{print \$3}')
        count=\$(echo "\$line" | awk '{print \$1}')
        out_file="${metadata.referenceID}.${metadata.round}.\${chr}.\${count}"
        log_file="${metadata.referenceID}.${metadata.round}.\${chr}.\${count}.log"
        GLIMPSE2_split_reference \\
            ${args} \\
            ${genetic_map_command} \\
            -T ${task.cpus} \\
            -R ${reference} \\
            --input-region \${buffer} \\
            --output-region \${region} \\
            -O \${out_file} \\
            --log \${log_file}
        done < ${chunkedRegions}
        """
 }