configfile: "config/samples_getpileup.yaml"
configfile: "config/config.yaml" 

rule all:
    input:
        expand("results/GetPileupSummaries/{tumor}/pileup_summaries_{chromosomes}.table",tumor=config["base_file_name"],chromosomes=config["chromosomes"])


rule GetPileupSummaries:
    input:
        filepaths = lambda wildcards: config["base_file_name"][wildcards.tumor]
    output:
        "results/GetPileupSummaries/{tumor}/pileup_summaries_{chromosomes}.table"
    params:
        reference_genome = config["reference_genome"],
        gatk = config["gatk_path"],
        variants_for_contamination = config["variants_for_contamination"]
    log:
        "logs/GetPileupSummaries/{tumor}_get_pileup_summaries_{chromosomes}.txt"
    shell:
        "({params.gatk} GetPileupSummaries \
        -R {params.reference_genome} \
        -I {input.filepaths} \
        -V {params.variants_for_contamination} \
        -L {wildcards.chromosomes} \
        -O {output}) 2> {log}"

#rule GatherGetPileupSummaries:
#    output:
rule MergeBamOuts:
    output:
        unsorted_output = "results/MergeBamOuts/{tumor}/unsorted.out.bam"
        bam_out = "results/MergeBamOuts/{tumor}/bamout.bam"
    params:
        reference_genome = config["reference_genome"],
        java = config["java"],
	picard_jar = config["picard_jar"]
    log:
        "logs/MergeBamOuts/{tumor}/MergeBamOuts.log"
    shell:
        """
	all_bamout_inputs=`for chrom in {params.chromosomes}; do
	printf -- "I=results/mutect2/{wildcards.base_file_name}/{wildcards.base_file_name}_{wildcards.chromosomes}_bamout.bam "; done`
	
	({params.java} -jar {params.picard_jar} GatherBamFiles \
        R={params.reference_genome} \
	$all_vcf_inputs \
	O={output.unsorted_output}

        {params.java} -jar {params.picard_jar} SortSam \
        I={output.unsorted_output}
        O={output.bam_out}
        SORT_ORDER=coordinate 
        VALIDATION_STRINGENCY=LENIENT

        {params.java} -jar {params.picard_jar} BuildBamIndex 
        I={output.bam_out}
        VALIDATION_STRINGENCY=LENIENT) 2> {log}
        """

    
