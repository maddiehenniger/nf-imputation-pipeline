/**
 * Process to phase and impute samples using GLIMPSE2.
 * 
 * Uses the binary chunks generated during GLIMPSE2 chunk and split reference to impute target population in chunks.
 * @see GLIMPSE2 documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/phase/
 * 
 * @input 
 * @emit
 */

 process glimpse2_phase {

    tag "${sMetadata.sampleID}-${rMetadata.referenceID}"

    label 'glimpse2'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_phase/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(samplePath), path(sampleIdx), path(pedigree), val(rMetadata), path(refPath), path(refIdx), path(geneticMap), path(chunkedRegions), path(refBins)
        path(fastaReference)

    output:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path(chunkedRegions), path(refBins), path("${sMetadata.sampleID}.*.bcf"), emit: imputedSamples

    script:
        
        // Allow for user flexible arguments - defined in the conf/args.config file
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()
        // Determine if genetic maps exist or not
        def genetic_map_command = geneticMap ? "-M ${geneticMap}"  : ""
        def fasta_reference_command = fastaReference ? "-F ${fastaReference}" : ""

        """
        ls *.bam > bamlist.txt

        while IFS= read -r line; do
        chr=\$(echo "\$line" | awk '{print \$2}')
        ORG=\$(echo "\$line" | awk '{print \$4}')
        IRG=\$(echo "\$line" | awk '{print \$3}')
        count=\$(echo "\$line" | awk '{print \$1}')
        REGS=\$(echo \${IRG} | cut -d":" -f 2 | cut -d"-" -f1)
        REGE=\$(echo \${IRG} | cut -d":" -f 2 | cut -d"-" -f2)
        out_file="${sMetadata.sampleID}.\${chr}.\${REGS}.\${REGE}"
        log_file="${sMetadata.sampleID}.\${chr}.\${REGS}.\${REGE}"
        GLIMPSE2_phase \\
            ${args} \\
            ${genetic_map_command} \\
            ${fasta_reference_command} \\
            --threads ${task.cpus} \\
            --reference ${rMetadata.referenceID}_\${chr}_\${REGS}_\${REGE}.bin \\
            --output \${out_file} \\
            --log \${log_file}
        done < ${chunkedRegions}
        """
 }