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
include { PHASE_SAMPLES        } from "./workflows/phase_samples.nf"
include { IMPUTE_SAMPLES       } from "./workflows/impute_samples.nf"

workflow {
    PREPARE_INPUTS(
        file(params.samplesheet),
        file(params.referencesheet)
        file(params.recombinationMaps)
    )
    ch_input_samples      = PREPARE_INPUTS.out.samples
    ch_references         = PREPARE_INPUTS.out.references
    ch_one_reference      = PREPARE_INPUTS.out.reference_intermediate
    ch_two_reference      = PREPARE_INPUTS.out.reference_twostep
    ch_recombination_maps = PREPARE_INPUTS.out.recombination_maps

    VALIDATE_CHROMOSOMES(
        ch_input_samples,
        ch_references
    )
    ch_chromosomes           = VALIDATE_CHROMOSOMES.out.chromosomes
    ch_sample_chromosomes    = VALIDATE_CHROMOSOMES.out.sample_chromosomes
    ch_reference_chromosomes = VALIDATE_CHROMOSOMES.out.reference_chromosomes

    PHASE_SAMPLES(
        ch_input_samples,
        ch_one_reference,
        ch_chromosomes
    )
    ch_phased_samples      = PHASE_SAMPLES.out.phased_samples
    ch_indexed_phased_pair = PHASE_SAMPLES.out.indexed_phased_pair

    IMPUTE_SAMPLES(
        ch_one_reference,
        ch_indexed_phased_pair,
        ch_chromosomes
    )
    ch_chunked_regions = IMPUTE_SAMPLES.out.chunked_regions
}