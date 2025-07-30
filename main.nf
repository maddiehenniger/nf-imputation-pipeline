/*
---------------------------------------------------------------------
    maddiehenniger/nf-imputation-pipeline
---------------------------------------------------------------------
https://github.com/maddiehenniger/nf-imputation-pipeline
*/

nextflow.enable.dsl=2

/*
---------------------------------------------------------------------
    RUN MAIN WORKFLOW
---------------------------------------------------------------------
*/

// include custom workflows
include { PREPARE_INPUTS          } from "./workflows/prepare_inputs.nf"
// include { PHASE_SAMPLES           } from "./workflows/phase_samples.nf"
// include { INTERMEDIATE_IMPUTATION } from "./workflows/intermediate_imputation.nf"
// include { TWOSTEP_IMPUTATION      } from "./workflows/twostep_imputation.nf"

workflow {
    // STEP ONE: PREPARE INPUTS
    // In this step, samplesheet and references provided in the nextflow.config file are read into the pipeline, indexed, and assessed for chromosome numbers.
    PREPARE_INPUTS(
        file(params.samplesheet),
        file(params.references)
    )

    ch_input_samples          = PREPARE_INPUTS.out.samples
    ch_references             = PREPARE_INPUTS.out.references
    ch_one_reference          = PREPARE_INPUTS.out.reference_intermediate
    ch_two_reference          = PREPARE_INPUTS.out.reference_twostep
    ch_samples                = PREPARE_INPUTS.out.samples_idx
        .view()
    ch_intermediate_reference = PREPARE_INPUTS.out.intermediate_idx
        .view()
    ch_twostep_reference      = PREPARE_INPUTS.out.twostep_idx
        .view()

    // PHASE_SAMPLES(
    //     ch_input_samples,
    //     ch_one_reference,
    //     ch_recombination_maps
    // )
    // ch_phased_samples      = PHASE_SAMPLES.out.phased_samples
    // ch_indexed_phased_pair = PHASE_SAMPLES.out.indexed_phased_pair

    // INTERMEDIATE_IMPUTATION(
    //     ch_one_reference,
    //     ch_indexed_phased_pair
    // )
    // ch_intermediate_ref_xcf         = INTERMEDIATE_IMPUTATION.out.intermediate_ref_xcf
    // ch_intermediate_chunked_regions = INTERMEDIATE_IMPUTATION.out.intermediate_chunked_regions
    // ch_imputed_intermediate         = INTERMEDIATE_IMPUTATION.out.imputed_intermediate
    // ch_imputed_intermediate_paired  = INTERMEDIATE_IMPUTATION.out.intermediate_imputed_paired

    // TWOSTEP_IMPUTATION(
    //     ch_two_reference,
    //     ch_imputed_intermediate_paired
    // )

    // ch_twostep_chunked_regions      = TWOSTEP_IMPUTATION.out.twostep_chunked_regions
    // ch_twostep_ref_xcf              = TWOSTEP_IMPUTATION.out.twostep_ref_xcf
    // ch_imputed_twostep              = TWOSTEP_IMPUTATION.out.imputed_twostep
    // ch_twostep_by_chromosomes       = TWOSTEP_IMPUTATION.out.twostep_by_chromosomes
}