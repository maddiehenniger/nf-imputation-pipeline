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
include { PHASE_SAMPLES           } from "./workflows/phase_samples.nf"
include { INTERMEDIATE_IMPUTATION } from "./workflows/intermediate_imputation.nf"
// include { TWOSTEP_IMPUTATION      } from "./workflows/twostep_imputation.nf"

workflow {

    // PREPARE_INPUTS performs the following: 
    // 1) Reads in the test sample(s), references, and optionally provided paths to genetic maps specified in the nextflow.config file
    // 1A) Separates the reference panels based on the user-defined imputationStep ('one' for the first round of imputation, 'two' for second round of imputation)
    // 1B) Detects if the user has provided a path to the genetic maps for downstream use 
    // 2) Indexes the input sample(s), intermediate reference, and twostep reference
    // 3) Extracts the unique chromosome values from each sample and reference panel, storing the chromosome values for downstream phasing/imputation
    // 4) Separates the input test sample by chromosome and then indexes the split files
    // 5) Converts the references to XCF file format for downstream phasing and imputation 

    PREPARE_INPUTS(
        file(params.samplesheet),       // required: User-provided path to sample metadata identified in the nextflow.config file 
        file(params.references)         // required: User-provided path to the reference metadata identified in the nextflow.config file 
    )

    ch_prepare_phasing_samples = PREPARE_INPUTS.out.prepare_phasing_samples

    // PHASE_SAMPLES performs the following:
    // 1) Phases the test sample(s) to the intermediate (imputationStep: 'one') reference panel on a chromosome-by-chromosome basis
    //      Note: If a genetic map is provided, the pipeline will supply that to the genetic map parameter
    //      If a genetic map is not provided, SHAPEIT5 uses a default 1 cm/Mb recombination rate 
    // 2) Indexes the phased test sample(s) per chromosome

    PHASE_SAMPLES(
       ch_prepare_phasing_samples       // channel: [ chr, [ sampleID ], samplePath, sampleIdx, [ referenceID, chromosome, imputationStep, geneticMaps ], xcfReferencePath, xcfReferenceIdx, xcfReferenceBin, xcfReferenceFam, geneticMapPath ]
    )
    ch_phased_samples = PHASE_SAMPLES.out.indexed_phased_pair

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

    INTERMEDIATE_IMPUTATION(
        ch_phased_samples              // channel: [ chr, [ sampleID ], phasedSample, phasedSampleIdx, [ referenceID, chromosome, imputationStep, geneticMaps ], xcfReferencePath, xcfReferenceIdx, xcfReferenceBin, xcfReferenceFam, geneticMapPath ]
    )

    ch_intermediate_imputation = INTERMEDIATE_IMPUTATION.out.imputed_intermediate_samples_by_chr
        .view()

    // TWOSTEP_IMPUTATION performs the following:
    // 1) Chunks the samples by chromosome to prepare for the second round of imputation
    // 2) Imputes the samples to the reference panel specified for the second round of imputation
        // Note: If a genetic map is provided, the pipeline will supply that to the genetic map parameter
        // If a genetic map is not provided, IMPUTE5 uses a default 1 cM/Mb recombination rate 

    // TWOSTEP_IMPUTATION(
    //     ch_two_reference,
    //     ch_imputed_intermediate_paired
    // )

    // ch_twostep_chunked_regions      = TWOSTEP_IMPUTATION.out.twostep_chunked_regions
    // ch_twostep_ref_xcf              = TWOSTEP_IMPUTATION.out.twostep_ref_xcf
    // ch_imputed_twostep              = TWOSTEP_IMPUTATION.out.imputed_twostep
    // ch_twostep_by_chromosomes       = TWOSTEP_IMPUTATION.out.twostep_by_chromosomes
}