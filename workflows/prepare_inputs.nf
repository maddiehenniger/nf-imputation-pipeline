include { Parse_Samplesheet     } from "../subworkflows/parse_samplesheet.nf"
include { Parse_Referencesheet  } from "../subworkflows/parse_referencesheet.nf"

/**
 * Workflow to handle and prepare input files.
 * This includes parsing input metadata files.
 * Essentially, if a file is passed to a process downstream in the pipeline, it should run through this workflow.
 */

 workflow PREPARE_INPUTS {
    take:
        samplesheet
        referencesheet

    main:
        Parse_Samplesheet(samplesheet)
        Parse_Referencesheet(referencesheet)
    
    emit:
        samples     = Parse_Samplesheet.out.samples
        reference   = Parse_Referencesheet.out.reference
}