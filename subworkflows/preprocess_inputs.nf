include { bcftools_index as bcftools_index_samples } from '../modules/bcftools_index.nf'

/**
 * Index and query the number of chromosomes present in the input VCF/BCF files provided in the user-provided samplesheet and reference(s) files.
 * 
 * Tuples the VCF/BCF file and associated index together for downs
 * Wrangles the input samples into the format of channels expected by downstream processes.
 *
 * @take samples, references - A LinkedHashMap containing the metadata, file path to VCF/BCF, and file path to the associated indexed VCF/BCF file. 
 * @emit chromosomes - chromosome numbers present in a respective file.
 **/

workflow Preprocess_Inputs {
    take:
        samples
        references
    
    main:        
        // Index sample and references

        bcftools_index_samples(
            samples
        )

        bcftools_index_references(
            references
        )
        
        // Split samples by chromosome

        // Prepare indexed references
        


    emit:
        samples_by_chr      = ch_samples_by_chr
        intermediate_by_chr = ch_intermediate_by_chr
        twostep_by_chr      = ch_twostep_by_chr
}