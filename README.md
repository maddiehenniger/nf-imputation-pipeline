# nf-imputation-pipeline

GitHub repository for an imputation pipeline implemented in Nextflow. This documentation and pipeline are actively undergoing construction and are not currently ready for use.

## Overview of nf-imputation-pipeline

* Workflow image coming soon *

The Rowan lab `nf-imputation-pipeline` aims to impute genotypes from array or low-pass whole genome sequencing datasets using either a one or two steps of imputation. Input samples are phased to the reference panel by default, but can optionally be phased to a pedigree file. By default, input samples undergo an intermediate imputation step and then a to-sequence imputation step, but can optionally undergo only one imputation step.

Please see "Modifying the Configuration File" for modifying defaults. 

## Quickstart

Under construction

## Preparing to Run the nf-imputation-pipeline

In order to run the pipeline, you must have the following inputs:

- Nextflow downloaded and/or configured
- Input sample(s) that require imputation
- Reference panel(s) for imputing
- Sample and reference metadata for downstream processes

Input samples that require imputation will be referred to as test samples throughout this documentation. The reference population that you are using to impute with will be referred to as the reference panel. You may optionally provide genetic maps for recombination rates used for phasing and imputation steps.

### Required Input Files

The following are the user-required files for the pipeline to work. Please note the required input file extensions, expected file format, and pipeline assumptions for each file type. IMPORTANT: The input files for this are assumed to be in BCF/VCF(.gz) format and have already been filtered for the analysis-appropriate quality, allele frequencies, missingness, etc. The user must be aware of how including low-quality base calls in the dataset may impact downstream imputation accuracies. 

The pipeline will automatically detect where your sample(s), reference(s), and optionally, your genetic map(s) are located using your user-provided metadata sheets that are specified in your `nextflow.config` file. For details on how to populate these, please see below sections.

#### Sample and Reference Files and Metadata

The test samples must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The test samples currently must have the AC/AN tags filled before supplying to the pipeline. The test samples have no input requirement for the number of individuals. The pipeline will impute test samples regardless of the input number of markers. The test samples are assumed to be unphased and there is currently no option to skip phasing. There should be one file per sample - specifically, each sample should not be split by chromosome.

The sample metadata should be a comma-delimited file (.CSV) containing two columns: sampleName, samplePath
- sampleName: [required] A string with no spaces containing the user-defined name of the sample with no file extensions (ex: sample_1)
- samplePath: [required] A string in the form of a file path to where the associated sample is located in your directory; this should end with the file extension (ex: /path/to/sample/sample_1.vcf.gz)

The reference panel(s) must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The reference panel should already be phased and there is no option currently to perform reference panel phasing. The reference panels must be provided on a by-chromosome basis. There are no marker or individual requirements for the reference panel(s). Users must be aware of how the number of markers and individuals may impact imputation performance.

The reference metadata should be a comma-delimited file (.CSV) containing three columns: referenceName, referencePath, imputationStep
- referenceName: [required] A string with no spaces contianing the user-defined name of the reference panel with no file extensions (ex: HD_panel)
- referencePath: [required] A string in the form of a file path to where the associated reference panel is located in your directory; this should end with the file extension BCF/VCF(.gz) (ex: /path/to/reference/HD_panel.bcf)
- chromosome: [required] An integer in the form of a numerical value to the associated chromosome for the reference panel; at this time, sex chromosome values are not accepted
- imputationStep: [required] A string containing one of the following: one or two; one corresponds to the intermediate imputation step, and two corresponds to sequence-level imputation
- geneticMapPath: [optional] A string in the form of a file path to where the associated genetic maps for the specific chromosome are located, ending with the file extension gmap; if the genetic map is not provided, then the default 1 cM/Mb recombination rate is used for downstream phasing and imputation 

The user may choose to optionally supply genetic maps containing recombination rates on a per-chromosome basis. The genetic maps are a tab-delimited file ending in `.gmap` that consists of 3 columns: pos / chr / cM:
- pos: The position in bases on the chromosome (must be in bases, not in mb, kb, etc.)
- chr: The chromosome number
- cM: Measure in centimorgans (cM) of how often recombination happens 
If the genetic maps provided are not in this format, the tools will be unable to conduct phasing and imputation using the genetic maps and will return error messages.

### The Configuration File

The `nextflow.config` file is where the workflow configurations are located. The configuration file is automatically detected by Nextflow, provided it is located within the project launch directory. The user must modify the configuration file to provide a project title, test sample metadata, and reference panel metadata. The configuration file is built for the intention of running on a SLURM-based system. 

Before running the pipeline, the user must modify the `nextflow.config` file. This file must be modified to supply the `projectTitle`, path to the `samplesheet`, and path to the `references` at a minimum. These inputs allows the pipeline to classify the pipeline by project, locate input test samples, and locate reference panels and which imputation step they will be used for.

### Modifying Function Parameters (Under Construction)

! TODO: Allow the user to modify arguments within modules via the arguments configuration file !

This is currently not available for the user.

Within the `/conf/args.config` file, the modules run throughout the pipeline will have their additional parameters available for the user to modify. 

## Detailed Walkthrough of the Workflow

Some steps will run simultaneously throughout this process.

### Optional: Data Simulation (Under Construction)

! TODO: Not currently available for this version of the pipeline !

The user may optionally designate that a dataset be simulated for the pipeline. This will generate an "artificial" dataset created by downsampling high-density input data to simulate low-density genetic information. In theory, this may include if the user is interested in downsampling their high-density sample to specific SNP array genotypes, in which the user will also be prompted to supply the positions genotyped on their target array. 

### Test Sample and Reference Validation (Under Construction)

The workflow will automatically identify the name and location of the test samples and validate their existence based on the user-specified metadata. The test samples will be assessed for the number of chromosomes.

By default, the workflow will identify the name and location of the reference panel(s) and validate their existence based on the user-specified metadata. If multiple reference panels are specified, the workflow detects which step of imputation each reference is used for based on user-supplied input in the metadata. The reference panel will be assessed for the number of chromosomes and whether or not the reference has been phased. These steps cannot currently be skipped to save time by the user configuration.

! Issue: NF pipeline does not wait to validate all reference/samples before storing chromosome values and moving on, so need to fix. !

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



