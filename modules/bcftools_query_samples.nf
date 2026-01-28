/**
 * Process to run bcftools view to extract unique chromosome ids within each input.
 * 
 * Generates a list of chromosome numbers present in sample files.
 * @see https://samtools.github.io/bcftools/bcftools.html#view
 * 
 * @input A map containing the test sample metadata, path to the test samples, and path to the indexed test samples.
 * @emit chromosomes - A text file containing the unique and sorted chromosome numbers from the test samples.
 */

 process bcftools_query_samples {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.chromosome_validation/",
        mode:    "symlink"
    )

    input:
        tuple val(metadata), path(sample), path(sampleIndex)

    output:
        tuple val(meta), path(samplePath), path(sampleIdx), stdout

    script:
        """
        view -H bisnps_autosomes_imputation_testing_samples_chr.bcf | cut -f1 | sort -n -u > wgs_chr_list.txt
        """
 }