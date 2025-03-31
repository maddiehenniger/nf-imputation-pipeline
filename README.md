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

Input samples that require imputation will be referred to as test samples throughout this documentation. The reference population that you are using to impute with will be referred to as the reference panel. You may optionally also include a pedigree file and must specify this in the configuration file. 

### Required Input Files

The following are the user-required files for the pipeline to work. Please note the required input file extensions, expected file format, and pipeline assumptions for each file type. IMPORTANT: The input files for this are assumed to be in VCF/BCF(.gz) format and have already been filtered for the analysis-appropriate quality, allele frequencies, missingness, etc. The user must be aware of how including low-quality base calls in the dataset may impact downstream imputation accuracies. 

Note: The below paragraph is currently not implemented in this version of the pipeline and only supports hard copying. Future implementations of the pipeline will provide the below features.

The pipeline will automatically detect where your sample(s), reference(s), and optionally, your pre-indexed file(s) are located. IMPORTANT: (Feature) If you do not have your samples and references pre-indexed and in the same directory defined in your samplesheet, the pipeline will check if the files exist in `${PROJECTDIR}/data/samples/` and `${PROJECTDIR}/data/references/` directories and perform indexing - if they do not exist in the defined directories, the pipeline is set to hard copy these files to these directories to perform downstream analysis, which can impact your processing time and available storage. Therefore, to avoid unneccessary duplication of files, we recommend either preemptively creating these directories and populating them with the correct files, and, optionally, pre-indexing your files. 

#### Sample and Reference Files and Metadata

! Undergoing Construction: For the current implementation of the pipeline, you MUST supply the path to the reference database AND the indexed file for testing. Making the indexing optional is a future priority implementation !

The test samples must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The test samples have no input requirement for the number of individuals. The pipeline will impute test samples regardless of the input number of markers. The test samples are assumed to be unphased and there is currently no option to skip phasing.

The reference panel(s) must be in a BCF/VCF file format and can optionally be gzipped (ending in .gz). The reference panel should already be phased and there is no option currently to perform reference panel phasing. There are no marker or individual requirements for the reference panel(s). Users must be aware of how the number of markers and individuals may impact imputation performance.

The sample metadata should be a comma-delimited file (.CSV) containing two columns: sampleName, samplePath
- sampleName: A string with no spaces containing the user-defined name of the sample with no file extensions (ex: sample_1)
- samplePath: A string in the form of a file path to where the associated sample is located in your directory; this should end with the file extension (ex: /path/to/sample/sample_1.vcf.gz)
- sampleIndexPath (OPTIONAL, RECOMMENDED): A string in the form of a file path to where the associated sample index is located in your directory; this should end with the file extension (ex: /path/to/sample/sample_1.vcf.gz.csi)

Please note that the `sampleIndexPath` must be in the same directory as the supplied sample file, and in the current version, only supports `.csi` index file format. If no indexed files have been generated for a sample, you may leave this column blank. Be aware that if the test samples do not exist under `${PROJECTDIR}/data/samples`, they will be hard copied to the project directory where the Nextflow script is ran. If the samples already exist in this directory, and simply need to be indexed, the copying step will be skipped and only indexing will be performed. Hard copying of sample files can reduce available storage within the project directory and increase processing time depending on sample size.

The reference metadata should be a comma-delimited file (.CSV) containing three columns: referenceName, referencePath, imputationStep
- referenceName: A string with no spaces contianing the user-defined name of the reference panel with no file extensions (ex: HD_panel)
- referencePath: A string in the form of a file path to where the associated reference panel is located in your directory; this should end with the file extension (ex: /path/to/reference/HD_panel.bcf)
- referenceIndexPath (OPTIONAL, RECOMMENDED): A string in the form of a file path to where the associated reference panel index file are located in your directory; this should end with the file extension (ex: /path/to/reference/HD_panel.bcf.csi)
- imputationStep: A string containing one of the following: one or two; one corresponds to the intermediate imputation step, and two corresponds to sequence-level imputation

Please note that the `referenceIndexPath` must be in the same directory as the supplied reference file, and in the current version, only supports `.csi` index file format. If no indexed files have been generated for a reference panel, you may leave this column blank. Be aware that if the reference(s) do not exist under `${PROJECTDIR}/data/references`, they will be hard copied to the project directory where the Nextflow script is ran. If the reference panel(s) already exist in this directory, and simply need to be indexed, the copying step will be skipped and only indexing will be performed. Hard copying of reference files can reduce available storage within the project directory and increase processing time depending on reference size.

Please note the `imputationStep` column is required regardless of whether you are performing two-step imputation or not (in this case, the user will just put 'one'). Please also note that at this time, there cannot be more than two reference datasets (i.e., only one for imputationStep value one, only one for imputationStep value two), even if you intend to test different intermediate or sequence-level imputation reference panels. Hopefully, this will be a feature in future implementations to allow for more savvy testing of multiple reference panels, but is not a priority feature.

#### Optional: Pedigree File

Please note: This is currently undergoing construction is not an available feature.

If you already know you'd like to phase your test samples to a pedigree file, you must also supply an additional input file. You must provide the pedigree file in a tab-delimited format containing one line per sample having parent(s) in the data and three columns (kidID fatherID and motherID). Use NAs for unknown parents (in the case of duos).

You must also modify the configuration file to specify that phasing must occur to the pedigree file and the location of the pedigree file. The test sample population must be larger than 25 individuals for pedigree-based phasing, which is a restriction implemented by the phasing tool and not pipeline developers.

### The Configuration File

The `nextflow.config` file is where the workflow configurations are located. This file is automatically detected by Nextflow, provided it is located within the launch directory. The user must modify the configuration file with project-specific details for Nextflow to detect where test samples, reference panels, and associated files are located. The configuration file is built for the intention of running on a SLURM-based system. 

Before running the pipeline, the user must modify the `nextflow.config` file. This file must be modified to supply the `projectTitle`, `samplesheet`, and `referencesheet` at a minimum. These inputs allows the pipeline to classify the pipeline by project; locate input samples; and locate references and which imputation step they will be used for, if applicable. 

## Detailed Walkthrough of the Workflow

Some steps will run simultaneously throughout this process. 

### Test Sample and Reference Validation

The workflow will automatically identify the name and location of the test samples and validate their existence based on the user-specified metadata. The test samples will be assessed for the number of chromosomes.

By default, the workflow will identify the name and location of the reference panel(s) and validate their existence based on the user-specified metadata. If multiple reference panels are specified, the workflow detects which step of imputation each reference is used for based on user-supplied input in the metadata. The reference panel will be assessed for the number of chromosomes and whether or not the reference has been phased. These steps cannot currently be skipped to save time by the user configuration.

### Phasing Test Samples to the Reference Population

Once the number of chromosomes are validated, the test samples then undergo phasing to the intermediate reference population using `SHAPEIT5`. In most cases, the pipeline is ran using the `phase_common`, which takes an `--input` of test samples and `--reference` of the reference panel used for the intermediate imputation step (specified as 'one' in the metadata). As an input, `phase_common` requires an unphased file (with AC and AN tags filled up) and automatically sub-sets the file to the desired MAF (`--filter-maf 0.001`, which is MAF >= 0.1%). `phase_common` performs phasing in regions, or chromosome chunks. Once phasing is complete, the output file is a phased BCF. 

Future features for phasing include: 
- Chunking files for phasing WGS data, which will improve processing time, and then remerging
- Allowing the user to select their `--filter-maf` value for phasing 
- Allowing the user to phase by pedigree if they meet a minimum number of test samples (at least >= 25 per `SHAPEIT5`)
- Allowing the user to run `phase_rare` in the case of >=2000 test samples

