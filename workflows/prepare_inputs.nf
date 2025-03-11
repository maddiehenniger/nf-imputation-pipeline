include { Parse_Samplesheet     } from "../subworkflows/parse_samplesheet.nf"

/**
 * Workflow to handle and prepare input files.
 * This includes parsing input metadata files.
 * Essentially, if a file is passed to a process downstream in the pipeline, it should run through this workflow.
 */

 workflow PREPARE_INPUTS {
    take:
        samplesheet

    main:
        Parse_Samplesheet(samplesheet)
    
    emit:
        samples      = Parse_Samplesheet.out.samples
}