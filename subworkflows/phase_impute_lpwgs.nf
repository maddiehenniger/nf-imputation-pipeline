include { glimpse2_phase  } from '../modules/glimpse2/glimpse2_phase.nf'
include { glimpse2_ligate } from '../modules/glimpse2/glimpse2_ligate.nf'
include { bcftools_index  } from '../modules/glimpse2/bcftools_index.nf'

/**
 * Workflow to phase and impute lcWGS data.
 *
 * 
 */

workflow Phase_Impute_Lpwgs {

    take:
        samples_one
        fastaReference

    main:

        // Group on a per-sample basis while looking at chromosomes
        // This probably could be way more elegant and less risky, so is an area to improve later
        ch_grouped = samples_one
            .groupTuple(by: 0)
            .map { chr, sampleMetadata, samplePath, sampleIndex, pedigree,
                   referenceMetadata, referencePath, referenceIndex,
                   geneticMap, chunkedRegions, referenceBins ->

                tuple(
                    chr,
                    sampleMetadata,                                   // per-sample list
                    samplePath,                                       // per-sample list
                    sampleIndex,                                      // per-sample list
                    pedigree.findAll { it }.unique(),                 // drop nulls, dedupe
                    referenceMetadata[0],                             // per-chr constant: take first
                    referencePath[0],                                 // per-chr constant: take first
                    referenceIndex[0],                                // per-chr constant: take first
                    geneticMap[0],                                    // per-chr constant: take first
                    chunkedRegions[0],                                // per-chr constant: take first
                    referenceBins.flatten().unique()                  // per-chunk list: dedupe N-fold repeats
                )
            }

        // Make one bam-list file per chromosome, even though all will be the same files across chromosomes
        // to make life easier so that we can provide the bam lists with chromosomes
        // Using .name to keep paths matching in the work dir (for staging purposes), and then we add in the 
        // chromosome key for downstream merging
        ch_bam_list = samples_one
            .map { chr, sampleMetadata, samplePath, sampleIndex, pedigree,
                   referenceMetadata, referencePath, referenceIndex,
                   geneticMap, chunkedRegions, referenceBins ->
                tuple(chr, samplePath.name)
            }
            .collectFile(newLine: true, sort: true) { chr, name ->
                [ "glimpse2_bamlist_${chr}.txt", name ]
            }
            .map { f -> tuple(f.name.replaceFirst(/^glimpse2_bamlist_/, '').replaceFirst(/\.txt$/, ''), f) }

        // Join the bam-list file to the chromosome key
        ch_for_glimpse = ch_grouped
            .join(ch_bam_list, by: 0)
            .map { chr, sampleMetadata, samplePath, sampleIndex, pedigree,
                   referenceMetadata, referencePath, referenceIndex,
                   geneticMap, chunkedRegions, referenceBins, bamlist ->
                tuple(chr, sampleMetadata, samplePath, sampleIndex, pedigree,
                      referenceMetadata, referencePath, referenceIndex,
                      geneticMap, chunkedRegions, referenceBins, bamlist)
            }

        // Phase and impute each chromosome's cohort using GLIMPSE2
        glimpse2_phase(
            ch_for_glimpse,
            fastaReference
        )
        ch_imputed_samples    = glimpse2_phase.out.imputedSamples
        ch_imputed_statistics = glimpse2_phase.out.imputedStatistics

        // Ligate imputed samples together on a per-chromosome basis
        glimpse2_ligate(
            ch_imputed_samples
        )
        ch_ligated_imputed_samples = glimpse2_ligate.out.ligatedImputedSamples

        // Index the imputed samples
        bcftools_index(
            ch_ligated_imputed_samples
        )
        ch_indexed_imputed_samples = bcftools_index.out.ligatedIndexedSamples


    emit:
        imputedSamples    = ch_indexed_imputed_samples
        imputedStatistics = ch_imputed_statistics
}