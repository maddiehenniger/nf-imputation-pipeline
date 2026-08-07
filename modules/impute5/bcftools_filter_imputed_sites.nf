/**
 * Process to run bcftools view to subset low-quality imputed sites.
 * 
 * Generates an indexed file for the combined BCF file from the output imputation step for each input sample.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input 
 * @emit 
 */

 process bcftools_filter_imputed_sites {

    tag "${sMetadata.sampleID}"

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/final_imputed_samples/",
        pattern: "*filtered.ligated.${chromosome}.*",
        mode:    "copy"
    )

    input:
        tuple val(chromosome), val(sMetadata), path(imputedSample), path(imputedIndex), path(pedigree)

    output:
        tuple val(chromosome), val(sMetadata), path("*.bcf"), path("*.bcf.csi"), path(pedigree), emit: filteredImputed

    script:
        """
        bcftools +setGT \\
        ${imputedSample} \\
        -Ob \\
        --write-index \\
        -o ${sMetadata.sampleID}.filtered.ligated.${chromosome}.bcf -- -t q -n . -e'FORMAT/GP>=0.90'
        """
 }