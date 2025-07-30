include { Parse_Input_Sheets } from "../subworkflows/parse_input_sheets.nf"

/**
 * Workflow to handle and prepare input files.
 * This includes parsing input metadata files.
 * Essentially, if a file is passed to a process downstream in the pipeline, it should run through this workflow.
 */

 workflow PREPARE_INPUTS {
    take:
        samplesheet
        references

    main:
        Parse_Input_Sheets(
            samplesheet,
            references
        )
    
    emit:
        samples                  = Parse_Input_Sheets.out.samples
        references               = Parse_Input_Sheets.out.references
        reference_intermediate   = Parse_Input_Sheets.out.reference_intermediate
        reference_twostep        = Parse_Input_Sheets.out.reference_twostep
}