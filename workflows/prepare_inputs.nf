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

        ch_samples                 = Parse_Input_Sheets.out.samples
        ch_reference_intermediate  = Parse_Input_Sheets.out.reference_intermediate
        ch_reference_twostep       = Parse_Input_Sheets.out.reference_twostep

        Validate_Chromosomes(
            ch_samples,
            ch_reference_intermediate,
            ch_reference_twostep
        )

        ch_samples_by_chr           = Validate_Chromosomes.out.samples_by_chr
        ch_intermediate_by_chr      = Validate_Chromosomes.out.intermediate_by_chr

        Prepare_Phasing(
            ch_samples_by_chr,
            ch_intermediate_by_chr
        )

        ch_prepare_phasing_samples     = Prepare_Phasing.out.prepare_phasing_samples

    emit:
        samples                  = Parse_Input_Sheets.out.samples
        references               = Parse_Input_Sheets.out.references
        reference_intermediate   = Parse_Input_Sheets.out.reference_intermediate
        reference_twostep        = Parse_Input_Sheets.out.reference_twostep
        intermediate_idx         = Validate_Chromosomes.out.intermediate_by_chr
        twostep_idx              = Validate_Chromosomes.out.twostep_by_chr
        prepare_phasing_samples  = ch_prepare_phasing_samples
}