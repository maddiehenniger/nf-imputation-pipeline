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

        Preprocess_Inputs(
            ch_samples,
            ch_reference_one,
            ch_reference_two,
            dataType
        )
        ch_samples_one   = Preprocess_Inputs.out.samples_one
        ch_reference_two = Preprocess_Inputs.out.reference_two

    emit:
        reference_one = ch_reference_one
        reference_two = ch_reference_two
        samples_one   = ch_samples_one
}