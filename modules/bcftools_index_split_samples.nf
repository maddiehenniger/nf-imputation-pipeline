/**
 * Process to run BCFtools to index the by-chromosome BCF/VCF(.gz) test sample file(s).
 * 
 * Generates indexed files (.csi) for input VCF/BCF files.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input A map containing sample metadata, chromosome value, and path to the by-chromosome BCF/VCF(.gz) samples to be indexed.
 * @emit indexedSplitPair - A map containing the sample metadata, chromosome value, path to the by-chromosome BCF/VCF(.gz) file, and associated index (.csi) file.
 **/

process bcftools_index_split_samples {

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
        tuple val(chr), val(meta), path(sample)   

    output:
        tuple val(chr), val(meta), path(sample), path("*.csi"), emit: indexedSplitPair

    script: 
        """
        bcftools index \\
        ${sample}
        """
}
