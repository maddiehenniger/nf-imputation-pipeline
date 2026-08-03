/**
 * Process to phase and impute low-coverage WGS samples to the user-specified reference panel.
 * 
 * Generates phased and imputed genotypes using GLIMPSE2_phase.
 * @see GLIMPSE2_phase documentation https://odelaneau.github.io/GLIMPSE/docs/documentation/phase/
 * 
 * @input 
 * @emit
 */

 process glimpse2_phase_impute {

    label 'glimpse2'

    label 'med_cpu'
    label 'med_mem'
    label 'med_time'

    publishDir(
        path:    "${params.publishDirData}/glimpse2_phased/",
        mode:    "symlink"
    )

    input:
        tuple val(sMetadata), path(sample), path(sampleIndex), path(pedigree), val(rMetadata), path(reference), path(referenceIndex), path(geneticMap), path(chunkedRegions)
        path fastaReference

    output:
        tuple val(metadata), path(reference), path(referenceIndex), path(geneticMap), path("${metadata.referenceID}.chunks.${metadata.chromosome}*"), emit: chunkedReference

    script:
        
        // From nf-core parsing input data type for GLIMPSE2_phase
        def input_type = sample
            .collect { sample_ ->
                sample_.toString().endsWithAny("cram", "bam")
                    ? "bam"
                    : sample_.toString().endsWithAny("vcf", "bcf", "vcf.gz")
                        ? "gl"
                        : sample_.getExtension()
            }
            .unique()

        if (input_type.size() > 1 | !(input_type.contains("gl") | input_type.contains("bam"))) {
            error("[ERROR] Input files must be of the same type and either .bam/.cram or .vcf/.vcf.gz/.bcf format. Found: ${input_type}")
        }
        else {
            input_type = input_type[0]
        }
        if (input_type == "gl" & input.size() > 1) {
            error("[ERROR] Only one input .vcf/.vcf.gz/.bcf file can be provided")
        }
        def input_list = input.size() > 1

        // Check for optionally provided genetic maps
        def genetic_map_command = geneticMap ? "-M ${geneticMap}" : ""
        // Check for optionally provided fasta file
        def fasta_command = fastaReference ? "--fasta ${fastaReference}" : ""


        """
        if [ -n "${bamlist}" ] ;
        then
            input_command="--bam-list ${bamlist}"
        elif ${input_list} ;
        then
            ls -1 | grep '\\.cram\$\\|\\.bam\$' | sort > all_bam.txt
            input_command="--bam-list all_bam.txt"
        else
            if [ "${input_type}" == "bam" ];
            then
                input_command="--bam-file ${input}"
            elif [ "${input_type}" == "gl" ];
            then
                input_command="--input-gl ${input}"
            else
                echo "Input file type not recognised"
                echo "${input_type}"
                exit 1
            fi
        fi

        GLIMPSE2_phase \\
            ${args} \\
            -T ${task.cpus} \\
            \$input_command \\
            --reference ${reference} \\
            ${genetic_map_command} \\
            --input-region ${region} \\
            --output-region ${region} \\
            ${fasta_command} \\
            
        """
 }