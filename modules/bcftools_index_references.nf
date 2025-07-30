/**
 * Process to run BCFtools to index VCF/BCF files.
 * 
 * Generates indexed files (.csi) for input VCF/BCF files.
 * @see https://samtools.github.io/bcftools/bcftools.html#index
 * 
 * @input A LinkedHashMap containing the name and path to VCF/BCF file that needs to be indexed.
 * @emit A map containing the name, path to the VCF/BCF(.gz) file, and associated index (.csi) file.
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
