include { Parse_Input_Sheets   } from "../subworkflows/parse_input_sheets.nf"
include { Preprocess_Inputs    } from '../subworkflows/preprocess_inputs.nf'
// include { Validate_Chromosomes } from "../subworkflows/validate_chromosomes.nf"
// include { Prepare_References   } from '../subworkflows/prepare_references.nf'
// include { Prepare_Phasing      } from "../subworkflows/prepare_phasing.nf"

/**
 * Workflow to handle and prepare input files.
 * This includes parsing input metadata files.
 * Essentially, if a file is passed to a process downstream in the pipeline, it should run through this workflow.
 */

 workflow PREPARE_INPUTS {
    take:
        samplesheet
        references
        dataType

    main:
        Parse_Input_Sheets(
            samplesheet,
            references
        )

        ch_samples        = Parse_Input_Sheets.out.samples
        ch_reference_one  = Parse_Input_Sheets.out.reference_one
        ch_reference_two  = Parse_Input_Sheets.out.reference_two

        // Validate_Chromosomes(
        //     ch_samples,
        //     ch_reference_intermediate,
        //     ch_reference_twostep
        // )

        // ch_samples_by_chr           = Validate_Chromosomes.out.samples_by_chr
        // ch_intermediate_by_chr      = Validate_Chromosomes.out.intermediate_by_chr
        // ch_twostep_by_chr           = Validate_Chromosomes.out.twostep_by_chr

        Preprocess_Inputs(
            ch_samples,
            ch_reference_one,
            ch_reference_two,
            dataType
        )

        ch_split_samples = Preprocess_Inputs.out.splitSamples

        // ch_samples_one = Preprocess_Inputs.out.samples_one
        // ch_samples_two = Preprocess_Inputs.out.samples_two

        // Prepare_Phasing(
        //     ch_samples_by_chr,
        //     ch_intermediate_by_chr,
        //     ch_twostep_by_chr
        // )

        // ch_prepare_phasing_samples     = Prepare_Phasing.out.prepare_phasing_samples
        // ch_twostep_ref_xcf             = Prepare_Phasing.out.twostep_ref_xcf

    emit:
        splitSamples = ch_split_samples
        // chromosomes = ch_chromosomes // Testing
        reference_one = ch_reference_one
        reference_two = ch_reference_two
        // samples_one = ch_samples_one // Testing
        // samples_two = ch_samples_two // Testing
}