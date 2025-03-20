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
include { VALIDATE_CHR   } from "./modules/bcftools_validate_samples.nf"

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

    VALIDATE_CHR(
        ch_input_samples
    )
    ch_sample_chr = VALIDATE_CHR.out.ch_sample_chr
        .view()
}