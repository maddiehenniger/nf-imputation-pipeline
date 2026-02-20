/**
 * Process to run BCFtools to index BCF/VCF(.gz) files.
 * 
 * Generates indexed files (.csi) for input VCF/BCF files.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input A map containing the reference panel metadata, path to BCF/VCF(.gz) reference panel that needs to be indexed, and path to the genetic map if provided.
 * @emit indexedPair - A map containing the reference panel metadata, path to the BCF/VCF(.gz) file, associated index (.csi) file, and path to the genetic map if provided.
 **/

process bcftools_index_references {

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
        tuple val(meta), path(ref), path(maps)   

    output:
        tuple val(meta), path(ref), path("*.csi"), path(maps), emit: indexedPair

    script: 
        """
        bcftools index \
        ${ref}
        """
}
