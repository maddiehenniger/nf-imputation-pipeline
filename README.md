# nf-imputation-pipeline

GitHub repository for an imputation pipeline implemented in Nextflow. This documentation and pipeline are actively undergoing construction. Note that while documentation and testing are being developed for low pass WGS inputs, the pipeline is currently unavailable for LPWGS. 

## Overview of nf-imputation-pipeline

* Workflow image coming soon

The Rowan lab `nf-imputation-pipeline` aims to impute genotypes from array or low-pass whole genome sequencing datasets to provided haplotype reference panels. 

Please see "Modifying the Configuration File" for modifying defaults. 

## Preparing to Run the `nf-imputation-pipeline`

In order to run the pipeline, you must have the following inputs:

- Nextflow configured on your system (designed for SLURM-based schedulers)
- Input sample(s) that require imputation (BCF/VCF(.gz) with associated index (.csi))
- Reference panel(s) for imputing (BCF/VCF(.gz) with associated index (.csi))
- Sample and reference metadata for downstream processes

Input samples that require imputation will be referred to as test samples throughout this documentation. The reference population that you are using to impute with will be referred to as the reference panel. You may optionally provide genetic maps for recombination rates used for phasing and imputation steps.

## Quickstart

For users with experience with Nextflow and using a SLURM-based high-performance computing system, navigate or create your desired project directory and clone this repository. Then, create your test sample metadata sheet and reference panel metadata sheet as described in [Sample and Reference Files and Metadata](https://github.com/maddiehenniger/nf-imputation-pipeline?tab=readme-ov-file#sample-and-reference-files-and-metadata). Once complete, modify the `nextflow.config` file to supply the required fields. Nextflow will detect the files from the provided metadata sheets and start the pipeline.

Clone the GitHub repository. 

```
git clone https://github.com/maddiehenniger/nf-imputation-pipeline.git
```

Navigate into the cloned respository.

```
cd nf-imputation-pipeline
```

Modify the `nextflow.config` file to provide paths to your metadata sheets and supply a project title. Please make sure to fill out the appropriate information required for the pipeline to run.

If you are not running this pipeline on the University of Tennessee's ISAAC HPC, you will need to modify the SLURM parameters in the `conf/isaac.config` file. See [Preparing to Run on a Cluster](https://github.com/maddiehenniger/nf-imputation-pipeline/tree/main?tab=readme-ov-file#preparing-to-run-on-a-cluster) for more detail.

All of the imputed samples will be deposited in the `/data/final_imputed_samples/` directory generated during pipeline running and finalized after completion. Here, the samples will be named as `{sampleID}.{imputationRound}.ligated.{chromosome}` and be in BCF format with their associated indexed files (ex: test_sample.one.ligated.19.bcf would be for the user-provided sample named test_sample, after one round of imputation, ligated after chunking steps for chromosome 19, in BCF file format). If performing two rounds of imputation, as provided by the reference metadata sheet, there will also have a second sample with the same initial sampleID (ex: test_sample.two.ligated.19.bcf).

The user may track job progress in the file generated after the pipeline begins, located in the `sbatch_logs` directory. This is also where error messages will populate if the pipeline does not run correctly. 

### Required Input Files

The following are the user-required files for the pipeline to work. Please note the required input file extensions, expected file format, and pipeline assumptions for each file type. IMPORTANT: The input files for this are assumed to be in BCF/VCF(.gz) format and have already been filtered for the analysis-appropriate quality, allele frequencies, missingness, etc. The user must be aware of how including low-quality base calls in the dataset may impact downstream imputation accuracies. These assumptions apply to the test sample populations and reference panel populations provided. 

The pipeline will automatically detect where your sample(s), reference(s), and optionally, your genetic map(s) are located using your user-provided metadata sheets that are specified in your `nextflow.config` file. For details on how to populate these, please see below sections.

#### Sample and Reference Files and Metadata

The test samples must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The indexed file must be provided and are assumed to have the same naming scheme as the test sample. The test samples have no input requirement for the number of individuals. The pipeline will impute test samples regardless of the input number of markers, unless no markers exist for the region specified. The test samples are assumed to be unphased and there is currently no option to skip phasing. The input test sample(s) should not be split by chromosome as the pipeline will detect chromosomes from samples and split accordingly. For optional requirements, include the header name in your sheet, but leave fields empty. Please see `/examples/` for some examples of available options.

The sample metadata should be a comma-delimited file (.CSV) containing the following columns: sampleName, samplePath, sampleIndex, wgsPath, wgsIndex
- sampleName: [required] A string with no spaces containing the user-defined name of the sample with no file extensions (ex: samples_1)
- samplePath: [required] A file path to where the associated sample is located in your file system; this should end with the file extension `.bcf`, `.vcf`, or `.vcf.gz` (ex: `/path/to/sample/sample_1.vcf.gz`)
- sampleIndex: [required] A file path to where the associated sample's indexed file is located in your file system; this should end with the file extension `.csi` (ex: `/path/to/sample/sample_1.vcf.gz.csi`)
- wgsPath: [optional] If available, a file path to where the associated sample's whole genome sequencing sample is located in your file system; this should end with the file extension `.bcf`, `.vcf`, or `.vcf.gz`. (ex: `/path/to/samples/sample_wgs_1.bcf`) - this is treated as a "ground truth" sample to enable testing of imputation accuracies
- wgsIndex: [optional] If available, a file path to where the associated indexed file for the sample's whole genome sequencing sample is located in your file system; this should end with the file extension `.csi`. Note that if you're providing a `wgsPath`, the `wgsIndex` is required. (ex: `/path/to/samples/sample_wgs_1.bcf.csi`)

The reference panel(s) must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The reference panel should already be phased and there is no option currently to perform reference panel phasing. The reference panels must be provided on a by-chromosome basis. There are no marker or individual requirements for the reference panel(s). Users must be aware of how the number of markers and individuals may impact imputation performance. Similarly to the test sample metadata, if the user does not wish to provide an optional column, the column name must exist but the field may remain blank.

The reference metadata should be a comma-delimited file (.CSV) containing five columns: referenceName, referencePath, referenceIndex, chromosome, imputationStep, geneticMapPath
- referenceName: [required] A string with no spaces containing the user-defined name of the reference panel with no file extensions (ex: reference_chr1)
- referencePath: [required] A file path to where the associated reference panel is located in your file system; this should end with the file extension BCF/VCF(.gz). (ex: `/path/to/reference/reference_panel_chr1.bcf`)
- referenceIndex: [required] A file path to where the associated indexed file for the reference panel is located in your file system; this should end with the file extension `.csi`. (ex: `/path/to/reference/reference_panel_chr1.bcf.csi`)
- chromosome: [required] An integer in the form of a numerical value to the associated chromosome for the reference panel; at this time, sex chromosome values are not accepted
- imputationRound: [required] A string containing one of two values: either `one` or `two` - one should correspond to the reference panels used for the first round of imputation and two should correspond to the reference panel to use for the second round of imputation, if applicable. If only performing one round of imputation, the user does not have to supply a `two` value
- geneticMapPath: [optional] A file path to where the associated genetic maps for the specific chromosome are located in your file system, ending with the file extension gmap; if the genetic map is not provided, then the default 1 cM/Mb recombination rate is used for downstream phasing and imputation processes

The user may choose to optionally supply genetic maps containing recombination rates on a per-chromosome basis. The genetic maps are a tab-delimited file ending in `.gmap` that consists of 3 columns: pos / chr / cM:
- pos: The position in bases on the chromosome (must be in bases, not in mb, kb, etc.)
- chr: The chromosome number
- cM: Measure in centimorgans (cM) of how often recombination happens

If the genetic maps provided are not in this format, the tools will be unable to conduct phasing and imputation using the genetic maps and will return error messages and prevent further jobs spawning.

### The Configuration File

The `nextflow.config` file is where the workflow configurations are located. The configuration file is automatically detected by Nextflow, provided it is not moved from within the project launch directory. The user must modify the configuration file in order for the pipeline to run. The configuration file is built for the intention of running on a SLURM-based system. Before running the pipeline, the user must modify the `nextflow.config` file. 

The following "Input/Output Options" should be filled: supply a user-defined `projectTitle` (ex: `nf-project-imputation`, `henniger-dissertation-testing`, etc.), path to the `samplesheet` (containing the test sample metadata, ex: `/path/to/samplesheet.csv`, `samplesheet.csv`), the `dataType` of either value 'array' or 'lpwgs' (where your input data is either array genotypes or low-pass whole genome sequencing data), and the path to the `references` (containing the reference panel metadata, ex: `/path/to/references_metadata.csv`, `references.csv`). Please note that the default value of `dataType` is 'array'.

If the user's input data is 'array', please select which SHAPEIT parameters to use for phasing. It is up to the user to determine the appropriate phasing parameters for the input test samples by reviewing literature and best practices with tools. A brief summary of the different options for this step are provided. These include three values that correspond to three scenarios that are described below: 'use_reference','no_reference', or 'shapeit4_no_reference'.
- 'use_reference' : SHAPEIT5_phase_common will run to perform phasing, using the reference panel declared with round 'one' for informing phasing. Note that SHAPEIT5 will only phase where there are overlapping markers present in the reference panel, meaning that if the input sample's variants do not overlap with the reference panel, these variants will be removed. In the case zero variants are present for a region, SHAPEIT5 errors will cause the pipeline to exit.
- 'no_reference' : SHAPEIT5_phase_common will run to perform phasing, without using the reference panel for informing phasing. If the user supplies an input file with <50 individuals, this will return an error by SHAPEIT5 stating that you should use a reference to inform phasing. This error will cause the pipeline to exit as the pipeline will not be able to perform imputation. If applicable and the user must perform phasing without a reference panel and cannot increase the number of input individuals, please refer to the 'shapeit4_no_reference' for the workaround scenario.
- 'shapeit4_no_reference' : SHAPEIT4 will run to perform phasing, without using the reference panel for informing phasing. This option allows the user to bypass the error in the 'no_reference' scenario regarding the number of input individuals (if the user has <50 input test individuals). Note that you still must have at least 20 individuals within the file if using this approach - there is no current workaround for non-reference phasing with <20 individuals.

If the user's input dataType is 'lpwgs', the user must provide the 'phasingModel' for GLIMPSE2_chunk. The input must be of value 'recursive' or 'sequential'. See the GLIMPE2_chunk documentation for more information.

These configuration inputs allows the pipeline to classify the pipeline by project, locate input test samples, locate reference panels, and allow user flexibility for managing phasing and imputation parameters.

### Modifying Parameters for Phasing and Imputation

Within the `/conf/args.config` file, the modules run throughout the pipeline will have their additional parameters available for the user to modify. All parameters provided in the `/conf/args.config` file are the default arguments for phasing and imputation. If the user would like to perform parameter exploration or modification, the defaults may be modified. Further, if there is a specific argument the user would like to add that exists for the tool but is not provided here, the user may add it here. Please note that parameter modification may be critical to improving the user's imputation accuracy.

We provide an example, using the process labeled 'shapeit5_phase_common', which runs SHAPEIT5's phase_common. Located within the `conf/args.config` file, there are a number of default parameters specified by SHAPEIT5.

```
// SHAPEIT5 phase_common parameters
        // Please see @https://odelaneau.github.io/shapeit5/docs/documentation/phase_common/ for more details
        // All parameters specified below are the provided default parameters for SHAPEIT5 phase_common
    withName: 'shapeit5_phase_samples' {
        ext.argsDefault = [
            // Filter Parameters
            // '--filter-snp': ' ', // NA if specified, the program only considers SNPs
            '--filter-maf': '0', // FLOAT only consider variants with MAF above the specified value. It requires AC/AN tags in VCF/BCF file
            // MCMC Parameters - Expert
            '--mcmc-iterations': '5b,1p,1b,1p,1b,1p,5m', // STRING iteration scheme of the MCMC (burnin=b, pruning=p, main=m)
            '--mcmc-prune': 0.999, // FLOAT pruning threshold for genotype graphs (internal memory structures)
            '--mcmc-noinit': 'NA', // If specified, phasing initialized by PBWT sweep is disabled
            // PBWT Parameters - Expert
            '--pbwt-modulo': 0.1, // FLOAT storage frequency of PBWT indexes in chromosome
            '--pbwt-depth': 4, // INT depth of PBWT indexes to condition one
            '--pbwt-mac': 5, // INT minimal minor allele count at which PBWT is evaluated
            '--pbwt-mdr': 0.1, // FLOAT maximimal missing data rate at which PBWT is evaluated
            '--pbwt-window': 4, // INT run PBWT selection in windows of this size
            // HMM Parameters - Expert
            '--hmm-window': 4, // INT minimal size of the phasing window in chromosome
            '--hmm-ne': 15000, // INT effective size of the population
        ]
    }
```

To modify these parameters, adjust the value after the semicolon, as shown below in an example for `--filter-maf` in SHAPEIT5 phase_common.

```
'--filter-maf': '0.00001', // FLOAT only consider variants with MAF above the specified value. It requires AC/AN tags in VCF/BCF file
```

Keep in mind that the user-supplied values still must fall in the range of accepted values for the parameter (e.g., `--pbwt-window` must be in the range of 0.5 and 10 cM). Please note that the default values do not necessarily represent an optimal value for phasing and imputation, and modifying parameters can alter the accuracy of imputation and therefore appropriate parameter exploration should be conducted to determine ideal values within the user's testing population.

### Preparing to Run on a Cluster

The current implementation of this pipeline assumes that the pipeline is being ran on SLURM-based HPC and is specialized for the University of Tennessee's HPC (ISAAC). ISAAC maintains Apptainer/Singularity in addition to Nextflow on the cluster. If not planning to run this on ISAAC, some configurations will need to be set up by the user. Please make sure Apptainer/Singularity and Nextflow are maintained in some fashion on the user's system before attempting to run the pipeline, and that the SLURM scheduler is set up correctly.

See `/conf/isaac.config`, where the user's account, partition, and condo may be specified in addition to resource usage. Resources are additionally stored in the `/conf/resources.config` file. Please ensure that the scratch directory path is correctly defined for Nextflow to store large files generated throughout the process. Once configurations are appropriately set up, the user may then create a bash script to run the Nextflow pipeline, for example at the basic level: `nextflow run main.nf -profile PROFILE_HERE -plugins nf-schema@2.1.0`. Renaming or moving files within the `nf-imputation-pipeline` directories will nearly always cause the pipeline to fail unless the user is thorough in renaming profiles/etc.

Additional arguments may be added to `nextflow run`, such as `-qs` to limit the number of submissions (ex: `-qs 5` would submit manage 5 jobs at a time), or `-resume` to use cached files to start at a later step, if the pipeline exits and can be resumed. If modifying parameters, modules, etc., please use caution if intending to use `-resume`. 

## Detailed Walkthrough of the Workflow

The following sections will detail the processes executed by each workflow in the Nextflow `main.nf` script.

### PREPARE_INPUTS

PREPARE_INPUTS workflow performs the following steps: 
- `parse_input_sheets.nf`: Reads in the files defined in the `nextflow.config` file from the `samplesheet` and `references` categories. Here, the existence of optional inputs are evaluated and the references are divided by the round of imputation they are associated with. If no round 'two' option is provided by the user, this becomes an empty channel that is not used downstream. The presence of absence of genetic maps are evaluated here as well. 

### Phasing Test Samples to the Reference Population


### Intermediate Imputation of Test Samples to the Reference Population


### Two-step Imputation of Test Samples to To-Sequence Reference Population



