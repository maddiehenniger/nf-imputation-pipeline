/**
 * Process to run BCFtools to index BCF/VCF(.gz) files.
 * 
 * Generates indexed files (.csi) for input VCF/BCF files.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input A map containing metadata and path to the BCF/VCF(.gz) samples to be indexed.
 * @emit indexedPair - A map containing the name, path to the BCF/VCF(.gz) file, and associated index (.csi) file.
 **/

process bcftools_index_samples {

    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/.file_inputs/",
        mode:    "${params.publishMode}",
        pattern: '*.{bcf,bcf.csi,vcf,vcf.csi}'              // Output files may be BCF/VCF format with their associated CSI index file
    )

    input: 
        tuple val(meta), path(sample)   

    output:
        tuple val(meta), path(sample), path("*.csi"), emit: indexedPair

    script: 
        """
        bcftools index \
        ${sample}
        """
}
