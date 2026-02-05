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
// include { PHASE_SAMPLES                             } from "./workflows/phase_samples.nf"
// include { IMPUTE_SAMPLES as FIRST_ROUND_IMPUTATION  } from "./workflows/impute_samples.nf"
// include { IMPUTE_SAMPLES as SECOND_ROUND_IMPUTATION } from "./workflows/impute_samples.nf"
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
    ch_splitSamples  = PREPARE_INPUTS.out.splitSamples
    ch_reference_one = PREPARE_INPUTS.out.reference_one
    ch_reference_two = PREPARE_INPUTS.out.reference_two

    // PHASE_IMPUTE performs the following:
    PHASE_IMPUTE(
        ch_splitSamples,
        ch_reference_one,
        ch_reference_two
    )

    ch_phased_samples = PHASE_IMPUTE.out.phasedSamples
    ch_phased_samples_two = PHASE_IMPUTE.out.phasedSamplesTwo
    ch_imputed_samples = PHASE_IMPUTE.out.imputedSamples
        .view()

    // PHASE_SAMPLES performs the following:
    // 1) Phases the test sample(s) to the intermediate (imputationStep: 'one') reference panel on a chromosome-by-chromosome basis
    //      Note: If a genetic map is provided, the pipeline will supply that to the genetic map parameter
    //      If a genetic map is not provided, SHAPEIT5 uses a default 1 cm/Mb recombination rate 
    // 2) Indexes the phased test sample(s) per chromosome

    // PHASE_SAMPLES(
    //    ch_prepare_phasing_samples       // channel: [ chr, [ sampleID ], samplePath, sampleIdx, [ referenceID, chromosome, imputationStep, geneticMaps ], xcfReferencePath, xcfReferenceIdx, xcfReferenceBin, xcfReferenceFam, geneticMapPath ]
    // )
    // ch_phased_samples = PHASE_SAMPLES.out.indexed_phased_pair

    // INTERMEDIATE_IMPUTATION performs the following:
    // 1) Chunks the samples by chromosome to prepare for imputation
    // 2) Imputes the samples to the intermediate reference panel
        // Note: If a genetic map is provided, the pipeline will supply that to the genetic map parameter
        // If a genetic map is not provided, IMPUTE5 uses a default 1 cM/Mb recombination rate
    // 3) Ligates the chunked regions for imputed samples together to generate one BCF per input sample
    // 3A) First, ligates on chromosome-by-chromosome basis
    // 3B) Second, ligates all chromosomes together on a sample-by-sample basis
    // 4) Indexes the imputed sample and generates summary statistics
    // 4A) By-chromosome samples are indexed and used for input to the second round of imputation
    // 4B) Ligated samples are separated to generate summary statistics for the first round of imputation 

    // FIRST_ROUND_IMPUTATION(
    //     ch_phased_samples              // channel: [ chr, [ sampleID ], phasedSample, phasedSampleIdx, [ referenceID, chromosome, imputationStep, geneticMaps ], xcfReferencePath, xcfReferenceIdx, xcfReferenceBin, xcfReferenceFam, geneticMapPath ]
    // )

    // Join the output samples that are imputed by the reference panel specified for the first round of imputation with the reference panels specified for the second round of imputation 
    // FIRST_ROUND_IMPUTATION.out.imputed_samples_by_chr
    //     .join(ch_twostep_ref_xcf)
    //     .set { ch_intermediate_imputed_samples }

    // TWOSTEP_IMPUTATION performs the following:
    // 1) Chunks the first-round imputed samples by chromosome to prepare for the second round of imputation
    // 2) Imputes the samples to the reference panel specified for the second round of imputation
        // Note: If a genetic map is provided, the pipeline will supply that to the genetic map parameter
        // If a genetic map is not provided, IMPUTE5 uses a default 1 cM/Mb recombination rate 
    // 3) Ligates teh chunked regions for the second round of imputed samples together to generate one BCF per input sample
    // 3A) First, ligates on a chromosome-by-chromosome basis
    // 3B) Second, ligates all chromosomes together on a sample-by-sample basis
    // 4) Indexes the imputed sample and generates summary statistcs

    // SECOND_ROUND_IMPUTATION(
    //     ch_intermediate_imputed_samples      // channel: [ chr, [ sampleID ], imputedSampleByChr, imputedSampleByChrIdx, [ referenceID, chromosome, imputationStep, geneticMaps ], xcfReferencePath, xcfReferenceIdx, xcfReferenceBin, xcfReferenceFam, geneticMapPath ]
    // )

    // SECOND_ROUND_IMPUTATION.out.imputed_samples_by_chr
    //     .view()

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