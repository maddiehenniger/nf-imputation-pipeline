# nf-imputation-pipeline

GitHub repository for an imputation pipeline implemented in Nextflow. This documentation and pipeline are actively undergoing construction and are not currently ready for use.

## Overview of nf-imputation-pipeline

* Workflow image coming soon *

The Rowan lab `nf-imputation-pipeline` aims to impute genotypes from array or low-pass whole genome sequencing datasets using either a one or two steps of imputation. Input samples are phased to the reference panel by default, but can optionally be phased to a pedigree file. By default, input samples undergo an intermediate imputation step and then a to-sequence imputation step, but can optionally undergo only one imputation step.

Please see "Modifying the Configuration File" for modifying defaults. 

## Preparing to Run the `nf-imputation-pipeline`

In order to run the pipeline, you must have the following inputs:

- Nextflow configured on your system (designed for SLURM-based schedulers)
- Input sample(s) that require imputation
- Reference panel(s) for imputing
- Sample and reference metadata for downstream processes

Input samples that require imputation will be referred to as test samples throughout this documentation. The reference population that you are using to impute with will be referred to as the reference panel. You may optionally provide genetic maps for recombination rates used for phasing and imputation steps.

## Quickstart

For users with experience with Nextflow and using a SLURM-based high-performance computing system, navigate or create your desired project directory and clone this repository. Then, create your test sample metadata sheet and reference panel metadata sheet as described in [Sample and Reference Files and Metadata](https://github.com/maddiehenniger/nf-imputation-pipeline?tab=readme-ov-file#sample-and-reference-files-and-metadata). Once complete, modify the `nextflow.config` file to supply a user-defined projectTitle, the path to the sample metadata, and path to the reference metadata. Nextflow will detect the files from the provided metadata sheets and start the pipeline. Please note at this time that AC/AN tags must be filled in the test sample population for the pipeline to work.

Clone the GitHub repository. 

```
git clone https://github.com/maddiehenniger/nf-imputation-pipeline.git
```

Navigate into the cloned respository.

```
cd nf-imputation-pipeline
```

Modify the `nextflow.config` file to provide paths to your metadata sheets and supply a project title. Please make sure to fill out the appropriate information required for the pipeline to run.

### Required Input Files

The following are the user-required files for the pipeline to work. Please note the required input file extensions, expected file format, and pipeline assumptions for each file type. IMPORTANT: The input files for this are assumed to be in BCF/VCF(.gz) format and have already been filtered for the analysis-appropriate quality, allele frequencies, missingness, etc. The user must be aware of how including low-quality base calls in the dataset may impact downstream imputation accuracies. The test samples must currently also have the AC/AN tags filled prior to supplying to the pipeline.

The pipeline will automatically detect where your sample(s), reference(s), and optionally, your genetic map(s) are located using your user-provided metadata sheets that are specified in your `nextflow.config` file. For details on how to populate these, please see below sections.

#### Sample and Reference Files and Metadata

The test samples must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The indexed file must be provided and are assumed to have the same naming scheme as the test sample. The test samples have no input requirement for the number of individuals. The pipeline will impute test samples regardless of the input number of markers, unless no markers exist for the region specified. The test samples are assumed to be unphased and there is currently no option to skip phasing. The input test sample(s) should not be split by chromosome as the pipeline will detect chromosomes from samples and split accordingly.

The sample metadata should be a comma-delimited file (.CSV) containing two columns: sampleName, samplePath
- sampleName: [required] A string with no spaces containing the user-defined name of the sample with no file extensions (ex: samples_1)
- samplePath: [required] A file path to where the associated sample is located in your file system; this should end with the file extension `.bcf`, `.vcf`, or `.vcf.gz` (ex: `/path/to/sample/sample_1.vcf.gz`)
- sampleIndex: [required] A file path to where the associated sample's indexed file is located in your file system; this should end with the file extension `.csi` (ex: `/path/to/sample/sample_1.vcf.gz.csi`)
- wgsPath: [optional] If available, a file path to where the associated sample's whole genome sequencing sample is located in your file system; this should end with the file extension `.bcf`, `.vcf`, or `.vcf.gz`. (ex: `/path/to/samples/sample_wgs_1.bcf`) - this is treated as a "ground truth" sample to enable testing of imputation accuracies
- wgsIndex: [optional] If available, a file path to where the associated indexed file for the sample's whole genome sequencing sample is located in your file system; this should end with the file extension `.csi`. Note that if you're providing a `wgsPath`, the `wgsIndex` is required. (ex: `/path/to/samples/sample_wgs_1.bcf.csi`)

The reference panel(s) must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The reference panel should already be phased and there is no option currently to perform reference panel phasing. The reference panels must be provided on a by-chromosome basis. There are no marker or individual requirements for the reference panel(s). Users must be aware of how the number of markers and individuals may impact imputation performance.

The reference metadata should be a comma-delimited file (.CSV) containing five columns: referenceName, referencePath, chromosome, imputationStep, geneticMapPath
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

If the genetic maps provided are not in this format, the tools will be unable to conduct phasing and imputation using the genetic maps and will return error messages.

### The Configuration File

The `nextflow.config` file is where the workflow configurations are located. The configuration file is automatically detected by Nextflow, provided it is not moved from within the project launch directory. The user must modify the configuration file in order for the pipeline to run. The configuration file is built for the intention of running on a SLURM-based system. Before running the pipeline, the user must modify the `nextflow.config` file. 

The following "Input/Output Options" should be filled: supply a user-defined `projectTitle` (ex: `nf-project-imputation`, `henniger-dissertation-testing`, etc.), path to the `samplesheet` (containing the test sample metadata, ex: `/path/to/samplesheet.csv`, `samplesheet.csv`), the `dataType` of either value 'array' or 'lpwgs' (where your input data is either array genotypes or low-pass whole genome sequencing data), and the path to the `references` (containing the reference panel metadata, ex: `/path/to/references_metadata.csv`, `references.csv`). Please note that the default value of `dataType` is 'array'.

If the user's input data is 'array', please select which SHAPEIT parameters to use for phasing. It is up to the user to determine the appropriate phasing parameters for the input test samples by reviewing literature and best practices with tools. A brief summary of the different options for this step are provided. These include three values that correspond to three scenarios that are described below: 'use_reference','no_reference', or 'shapeit4_no_reference'.
- 'use_reference' : SHAPEIT5_phase_common will run to perform phasing, using the reference panel declared with round 'one' for informing phasing. Note that SHAPEIT5 will only phase where there are overlapping markers present in the reference panel, meaning that if the input sample's variants do not overlap with the reference panel, these variants will be removed. In the case zero variants are present for a region, SHAPEIT5 errors will cause the pipeline to exit.
- 'no_reference' : SHAPEIT5_phase_common will run to perform phasing, without using the reference panel for informing phasing. If the user supplies an input file with <50 individuals, this will return an error by SHAPEIT5 stating that you should use a reference to inform phasing. This error will cause the pipeline to exit as the pipeline will not be able to perform imputation. If applicable and the user must perform phasing without a reference panel and cannot increase the number of input individuals, please refer to the 'shapeit4_no_reference' for the workaround scenario.
- 'shapeit4_no_reference' : SHAPEIT4 will run to perform phasing, without using the reference panel for informing phasing. This option allows the user to bypass the error in the 'no_reference' scenario regarding the number of input individuals (if the user has <50 input test individuals). 

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

See `/conf/isaac.config`, where the user's account, partition, and condo may be specified in addition to resource usage. Resources are additionally stored in the `/conf/resources.config` file. Once configurations are appropriately set up, the user may then create a bash script to run the Nextflow pipeline, for example at the basic level: `nextflow run main.nf -profile PROFILE_HERE -plugins nf-schema@2.1.0`. Renaming or moving files within the `nf-imputation-pipeline` directories will nearly always cause the pipeline to fail.

Additional arguments may be added to `nextflow run`, such as `-qs` to limit the number of submissions (ex: `-qs 5` would submit manage 5 jobs at a time), or `-resume` to use cached files to start at a later step, if the pipeline exits and can be resumed.

## Detailed Walkthrough of the Workflow

The following sections will detail the processes executed by each workflow in the Nextflow `main.nf` script.

### PREPARE_INPUTS

### Phasing Test Samples to the Reference Population

Once the number of chromosomes are validated, the test samples then undergo phasing to the intermediate reference population using `SHAPEIT5`. In most cases, the pipeline is ran using the `phase_common`, which takes an `--input` of test samples and `--reference` of the reference panel used for the intermediate imputation step (specified as 'one' in the metadata). As an input, `phase_common` requires an unphased file (with AC and AN tags filled up) and automatically sub-sets the file to the desired MAF (`--filter-maf 0.001`, which is MAF >= 0.1%). `phase_common` performs phasing in regions, or chromosome chunks. Once phasing is complete, the output file is a phased BCF. 

Future features for phasing include: 
- Chunking files for phasing WGS data, which will improve processing time, and then remerging
- Allowing the user to select their `--filter-maf` value for phasing 
- Allowing the user to phase by pedigree if they meet a minimum number of test samples (at least >= 25 per `SHAPEIT5`)
- Allowing the user to run `phase_rare` in the case of >=2000 test samples
- Allowing the user to optionally supply the `--map` argument for recombination rates

### Intermediate Imputation of Test Samples to the Reference Population

! TODO: Decide how to incorporate IMPUTE5 for the user!

After phasing, phased test samples will be imputed to the intermediate reference panel specified in the metadata (as the `imputationStep` column set to `one`). Briefly, the samples are first broken down into chunks using `imp5chunker` from the `IMPUTE5` package. The input arguments require the reference panel, the target test sample, the chromosome to break into chunks, and outputs a text file with coordinates. The text file contains the Chunk ID / chromosome ID / Buffered region / Imputation region / Length / Number of target markers / Number of reference markers. The default parameters for `--window-size` and `--buffer-size` are used in the pipeline. Ensuring a buffering region is present around the imputation region is critical for ensuring accuracy at the edges of imputation regions. 

Future features for chunking test samples include:
- Converting the reference panel to only positions (no GT field) to improve efficiency
- Allowing the user to modify `--window-size`, `--buffer-size`, and other marker-related options 

While samples are being chunked, the reference panels are converted to the XCF file format. An XCF file format contains a set of files with genotype information on a region within a chromosome, and we will generate this for each chromosome in order to perform imputation on different chunks of the chromosome. `IMPUTE5` strongly suggests converting to this file format to speed up the process of imputation for the reference panel file.

Future features for converting to XCF file format include:
- Allowing the user to convert test samples to the XCF file format to improve efficiency

Once the imputation and buffered regions have been generated for each chromosome, the test samples will be imputed to the intermediate reference panel using `IMPUTE5`. Briefly, `impute5` accepts a haplotype reference panel with associated indexed file (`--h`). `--m` specifies the fine-scale recombination map for the region to be analyzed - in this case, we do not define this parameter, so a constant recombination rate is assumed. `--g` contains the phased target test files to be imputed and assumes an associated indexed file. `--r` specifies the target region/chromosome to be imputed, and we include our buffering regions here using `--buffer-region` to expand the regions defined in the `--r` parameter. The imputed file is then output according to the `--o` argument.

Future features for intermediate imputation include:
- Allowing the user to specify the `--m` parameter
- Allowing the user to perform X chromosome imputation

For users interested in including the `--m` parameter, which specifies the recombination rate, a specific subset of files must be supplied. 

Once chunked test samples have undergone the intermediate imputation step, they are then ligated back together using `bcftools concat`, as recommended by the IMPUTE5 authors. Notably, the files must be in correct order before ligating. The pipeline sorts and provides a file first within chromosome (i.e., all the imputed chunked regions in chromosome 25) to ligate, and does this until all individual chromosomes per sample have been ligated. Then, the pipeline sorts and provides a file per sample of all the combined chromosomes and concatenates the test sample back together, producing one imputed file per test sample.

Future testing: 
- Must make sure including X chromosome does not impact sorting (shouldn't if it gets the X at the name of the sample, but making sure)
- Make sure including only one chromosome does not impact second ligation step (should be good to go)

### Two-step Imputation of Test Samples to To-Sequence Reference Population



