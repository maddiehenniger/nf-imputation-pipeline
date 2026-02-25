/**
 * Process to run bcftools +fill-tags to fill AC and AN tags in by-chromosome split and phased (by SHAPEIT4) test samples
 * 
 * Produces a BCF file with the AC/AN INFO field calculated.
 * @see https://samtools.github.io/bcftools/bcftools.html#plugin
 * 
 * @input samplesheet - metadata map to the sample input information, including [ meta, [ samplePath ], [ sampleIndex ], [ wgsPath ], [ wgsIndex ] ]
 * @emit phasedSamples - metadata map to the sample input information, now with AC/AN tags, including an updated [ meta, [ samplePath+TAGS ], [ sampleIndex+TAGS ], [ wgsPath ], [ wgsIndex ], referenceMeta, [ referencePath ], [ referenceIndex ], [ geneticMap ] ]
 */

 process bcftools_fill_tags_phasing {
    
    label 'bcftools'

    label 'def_cpu'
    label 'lil_mem'
    label 'lil_time'

    publishDir(
        path:    "${params.publishDirData}/phased_samples/",
        mode:    "symlink"
    )

    input:
        tuple val(chromosomes), val(sMetadata), path(sample), path(sampleIndex), path(wgs), path(wgsIndex), val(rMetadata), path(referencePath), path(referenceIndices), path(geneticMap)

    output:
        tuple val(metadata), val(chromosomes), path("${metadata.sampleID}.${chromosomes}.phased.tags.bcf"), path("${metadata.sampleID}.${chromosomes}.phased.tags.bcf.csi"), path(wgs), path(wgsIndex), val(rMetadata), path(referencePath), path(referenceIndices), path(geneticMap), emit: phasedSamples

    script:
        """
        bcftools +fill-tags ${sample} \\
        -Ob \\
        --write-index \\
        -o ${metadata.sampleID}.${chromosomes}.phased.tags.bcf -- -t AN,AC
        """
 }