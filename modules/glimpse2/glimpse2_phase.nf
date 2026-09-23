/**
 * Process to phase and impute samples using GLIMPSE2.
 *
 * Uses the binary chunks generated during GLIMPSE2 chunk and split reference to impute target population in chunks.
 * @see GLIMPSE2 documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/phase/
 *
 * GLIMPSE2 phasing is joint across samples but performed on a by-chromosome basis, so
 * the input tuple arrives as a list (sMetadata/samplePath/sampleIdx/pedigree)
 * per sample sharing this chromosome), bundled upstream via
 * groupTuple. The actual per-sample file references (via --bam-list) live
 * in `bamList`, so `samplePath`/`sampleIdx` are provided here to ensure
 * appropriate staging
 *
 * @input
 * @emit
 */

 process glimpse2_phase {

    tag "${chromosome}-${rMetadata.referenceID}"

    label 'glimpse2'

    label 'huge_cpu'
    label 'huge_mem'
    label 'huge_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_phase/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(samplePath), path(sampleIdx), path(pedigree), val(rMetadata), path(refPath), path(refIdx), path(geneticMap), path(chunkedRegions), path(refBins), path(bamList)
        path(fastaReference)

    output:
        tuple val(rMetadata), path(refPath), path(refIdx), path(geneticMap), path(chunkedRegions), path(refBins), path("*.bcf"), path("*.bcf.csi"), emit: imputedSamples
        tuple path("*coverage.txt.gz"), path("*log"), emit: imputedStatistics

    script:

        // Allow for user flexible arguments - defined in the conf/args.config file
        String args = new Args(argsDefault: task.ext.argsDefault, argsDynamic: task.ext.argsDynamic, argsUser: task.ext.argsUser).buildArgsString()
        // Determine if genetic maps exist or not
        def genetic_map_command = geneticMap ? "-M ${geneticMap}"  : ""
        // Determine if the path to the FASTA reference in the appropriate genome build was provided
        def fasta_reference_command = fastaReference ? "-F ${fastaReference}" : ""
        // Pull sample path information from the lists
        def first_sample_path = (samplePath instanceof List) ? samplePath[0] : samplePath
        def file_extension = first_sample_path.name.toLowerCase()
        // Check the input file type to determine how to read in files to GLIMPSE2
        def input_file_command = (file_extension.endsWith('bam') || file_extension.endsWith('cram')) ? "--bam-list ${bamList}" : "--input-gl ${bamList}"

        """
        while IFS= read -r line; do
        chr=\$(echo "\$line" | awk '{print \$2}')
        ORG=\$(echo "\$line" | awk '{print \$4}')
        IRG=\$(echo "\$line" | awk '{print \$3}')
        count=\$(echo "\$line" | awk '{print \$1}')
        REGS=\$(echo \${IRG} | cut -d":" -f 2 | cut -d"-" -f1)
        REGE=\$(echo \${IRG} | cut -d":" -f 2 | cut -d"-" -f2)
        out_file="${chromosome}.\${chr}.\${REGS}.\${REGE}.bcf"
        log_file="${chromosome}.\${chr}.\${REGS}.\${REGE}.log"
        GLIMPSE2_phase \\
            ${input_file_command} \\
            ${args} \\
            ${genetic_map_command} \\
            ${fasta_reference_command} \\
            --threads ${task.cpus} \\
            --reference ${rMetadata.referenceID}.${rMetadata.round}.\${chr}._\${chr}_\${REGS}_\${REGE}.bin \\
            --output \${out_file} \\
            --log \${log_file}
        done < ${chunkedRegions}
        """
 }