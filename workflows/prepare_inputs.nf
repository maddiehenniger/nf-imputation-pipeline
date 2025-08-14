include { Parse_Input_Sheets   } from "../subworkflows/parse_input_sheets.nf"
include { Validate_Chromosomes } from "../subworkflows/validate_chromosomes.nf"
include { Prepare_Phasing      } from "../subworkflows/prepare_phasing.nf"

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

        samples = Parse_Input_Sheets.out.samples
        references = Parse_Input_Sheets.out.references
        reference_intermediate = Parse_Input_Sheets.out.reference_intermediate
        reference_twostep = Parse_Input_Sheets.out.reference_twostep

        Validate_Chromosomes(
            samples,
            reference_intermediate,
            reference_twostep
        )

        // ch_samples_idx              = Validate_Chromosomes.out.samples_idx
        // ch_chromosomes              = Validate_Chromosomes.out.chromosomes
        ch_samples_by_chr           = Validate_Chromosomes.out.samples_by_chr

        Prepare_Phasing(
            ch_samples_by_chr
        )

        split_samples_by_chr = Prepare_Phasing.out.split_samples_by_chr
    
    emit:
        samples                  = Parse_Input_Sheets.out.samples
        references               = Parse_Input_Sheets.out.references
        reference_intermediate   = Parse_Input_Sheets.out.reference_intermediate
        reference_twostep        = Parse_Input_Sheets.out.reference_twostep
        // samples_idx              = Validate_Chromosomes.out.samples_idx
        // intermediate_idx         = Validate_Chromosomes.out.intermediate_idx
        // twostep_idx              = Validate_Chromosomes.out.twostep_idx
        split_samples            = Prepare_Phasing.out.split_samples_by_chr
}