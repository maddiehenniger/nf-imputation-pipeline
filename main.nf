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
include { PREPARE_INPUTS                            } from "./workflows/prepare_inputs.nf"
include { PHASE_IMPUTE } from "./workflows/phase_impute.nf"
// include { CALCULATE_ACCURACY } from "./workflows/calculate_accuracy.nf"

workflow {

    // PREPARE_INPUTS performs the following: 
    // 1) Reads in the test sample(s), references, and optionally provided paths to genetic maps specified in the nextflow.config file
    // 1A) Separates the reference panels based on the user-defined imputationRound ('one' for the first round of imputation, 'two' for second round of imputation)
    // 1B) Detects if the user has provided a path to the genetic maps for downstream use 
    // TEMPORARILY UNAVAILABLE: 2) Indexes the input sample(s), first round reference, and the optionally provided second round reference
    // 2) Identifies the chromosomes present in the test samples and separates the test samples by chromosome, also generating the associated indexed file
    // 

    PREPARE_INPUTS(
        file(params.samplesheet),       // required: User-provided path to sample metadata identified in the nextflow.config file 
        file(params.references),        // required: User-provided path to the reference metadata identified in the nextflow.config file
        params.dataType                 // required: User-provided value of either 'array' or 'lpwgs' identified in the nextflow.config file
    )
    // ch_chromosomes   = PREPARE_INPUTS.out.chromosomes // Testing
    ch_samples_one   = PREPARE_INPUTS.out.samples_one
    ch_reference_one = PREPARE_INPUTS.out.reference_one
    ch_reference_two = PREPARE_INPUTS.out.reference_two

    // PHASE_IMPUTE performs the following:
    // Note: If genetic maps are provided with the reference metadata, the genetic maps will be used for the following steps
    // A) For 'array' dataTypes:
    // A1) Samples are phased using the user-selected SHAPEIT phasingModel 
    // A2) Phased samples and round one references are used to 'chunk' the chromosomes into imputation and buffer regions for efficient downstream imputation
    // A3) Phased samples are imputed to the round one reference in the generated imputation chunked regions
    // A4) Round one imputed chunked regions are ligated back together to produce one round-one imputed sample per chromosome
    // A5) If round two reference panels are provided in the reference metadata, steps A2-A4 are repeated again, using the round-one imputed samples to impute to the round two reference panel
    //      A5-A2) Round-one imputed samples and round two references are used to 'chunk' the chromosomes into imputation and buffer regions
    //      A5-A3) Round-one imputed samples are imputed to the round two reference in the generated imputation chunked regions
    //      A5-A4) Round two imputed chunked regions are ligated back together to produce one round-two imputed sample per chromosome
    PHASE_IMPUTE(
        ch_samples_one,
        ch_reference_one,
        ch_reference_two,
        params.dataType,
        params.phasingModel,
        params.glimpse2Model
    )

    ch_imputed_samples_one = PHASE_IMPUTE.out.imputedSamplesOne
    ch_imputed_samples_two = PHASE_IMPUTE.out.imputedSamplesTwo

    // If the user specifies in the nextflow.config that they would like to calculate imputation accuracies, the pipeline will run the following:
    // CALCULATE_ACCURACY performs the following:
    // 1) Indexes the two-round imputed BCF files and then converts two-round imputed BCF files to gzipped VCF files
    // 2) Calculates by-SNP imputation accuracies using the gzipped VCF file
    // 3) Calculates by-sample imputation accuracies using the BCF file
    // 4) Prints imputation accuracy statistics by-sample and by-SNP, per chromosome, to two statistics files per provided sample

    // if(params.truthset != 'skip') {
    //     CALCULATE_ACCURACY(

    //     )
    // } else if(params.truthset == 'skip') {
        
    // }

}