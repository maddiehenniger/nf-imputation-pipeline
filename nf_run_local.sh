#!/bin/bash
#SBATCH --job-name=nf_imputation_pipeline
#SBATCH --cpus-per-task=1
#SBATCH --mem=3GB
#SBATCH --time=02:00:00
#SBATCH --error=sbatch_logs/%j_-_%x.err
#SBATCH --output=sbatch_logs/%j_-_%x.out
#SBATCH --account=ACF-UTK0171
#SBATCH --partition=condo-trowan1
#SBATCH --qos=condo
#SBATCH --mail-user=mhennige@vols.utk.edu
#SBATCH --mail-type=BEGIN,END,FAIL

module load nextflow/23.10.0

nextflow run main.nf -profile condo_trowan1 -plugins nf-schema@2.1.0 -qs 5