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
include { PREPARE_INPUTS } from "./workflows/prepare_inputs.nf"

workflow {
    PREPARE_INPUTS(
        file(params.samplesheet)
    )
    ch_input_samples = PREPARE_INPUTS.out.samples
        .view()
}