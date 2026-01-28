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
        // references
    
    main:        
        // TODO: Index the samples if index files are not provided

        // Identify the chromosomes present in each sample
        bcftools_identify_chromosomes(
            samples
        )
        ch_chromosomes = bcftools_identify_chromosomes.out.chromosomes
            .readLines()
        
        // Split samples by chromosome
        bcftools_split_samples(
            samples,
            ch_chromosomes
        )

        ch_split_samples = bcftools_split_samples.out.splitSamples

        // Prepare indexed references
        


    emit:
        splitSamples = ch_split_samples
}