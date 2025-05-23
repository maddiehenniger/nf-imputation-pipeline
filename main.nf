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
include { VALIDATE_CHROMOSOMES    } from "./workflows/validate_chromosomes.nf"
include { PHASE_SAMPLES           } from "./workflows/phase_samples.nf"
include { INTERMEDIATE_IMPUTATION } from "./workflows/intermediate_imputation.nf"
include { TWOSTEP_IMPUTATION      } from "./workflows/twostep_imputation.nf"

workflow {
    PREPARE_INPUTS(
        file(params.samplesheet),
        file(params.referencesheet),
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
        ch_recombination_maps
    )
    ch_phased_samples      = PHASE_SAMPLES.out.phased_samples
    ch_indexed_phased_pair = PHASE_SAMPLES.out.indexed_phased_pair

    INTERMEDIATE_IMPUTATION(
        ch_one_reference,
        ch_indexed_phased_pair
    )
    ch_intermediate_ref_xcf         = INTERMEDIATE_IMPUTATION.out.intermediate_ref_xcf
    ch_intermediate_chunked_regions = INTERMEDIATE_IMPUTATION.out.intermediate_chunked_regions
    ch_imputed_intermediate         = INTERMEDIATE_IMPUTATION.out.imputed_intermediate
    ch_imputed_intermediate_paired  = INTERMEDIATE_IMPUTATION.out.intermediate_imputed_paired

    TWOSTEP_IMPUTATION(
        ch_two_reference,
        ch_imputed_intermediate_paired
    )

    ch_twostep_chunked_regions      = TWOSTEP_IMPUTATION.out.twostep_chunked_regions
    ch_twostep_ref_xcf              = TWOSTEP_IMPUTATION.out.twostep_ref_xcf
    ch_imputed_twostep              = TWOSTEP_IMPUTATION.out.imputed_twostep
    ch_twostep_by_chromosomes       = TWOSTEP_IMPUTATION.out.twostep_by_chromosomes
}