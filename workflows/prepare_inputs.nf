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
        recombinationMaps

    main:
        Parse_Samplesheet(samplesheet)
        Parse_Referencesheet(referencesheet)
        Parse_Recombination_Maps(recombinationMaps)
    
    emit:
        samples                  = Parse_Samplesheet.out.samples
        references               = Parse_Referencesheet.out.references
        reference_intermediate   = Parse_Referencesheet.out.reference_intermediate
        reference_twostep        = Parse_Referencesheet.out.reference_twostep
        recombination_maps       = Parse_Recombination_Maps.out.recombination_maps
}