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
include { PREPARE_INPUTS       } from "./workflows/prepare_inputs.nf"
include { VALIDATE_CHROMOSOMES } from "./workflows/validate_chromosomes.nf"

workflow {
    PREPARE_INPUTS(
        file(params.samplesheet),
        file(params.referencesheet)
    )
    ch_input_samples    = PREPARE_INPUTS.out.samples
        .view()
    ch_one_reference    = PREPARE_INPUTS.out.reference_intermediate
        .view()
    ch_two_reference    = PREPARE_INPUTS.out.reference_twostep
        .view()

    VALIDATE_CHROMOSOMES(
        ch_input_samples,
        ch_one_reference,
        ch_two_reference
    )
    ch_sample_chromosomes = VALIDATE_CHROMOSOMES.out.sample_chromosomes
        .view()
}