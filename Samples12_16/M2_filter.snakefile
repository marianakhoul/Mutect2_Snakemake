configfile: "config/samples.yaml"
configfile: "config/config.yaml" 

import glob
import re
def getFullPathToFile(base, filepath):
	print(glob.glob(''.join([filepath, base, "/", base, ".table"])))
	return glob.glob(''.join([filepath, base, "/", base, ".table"]))


rule all:
	input:
		expand("results/GetPileupSummaries/{tumor}/pileup_summaries_{chromosomes}.table",tumor=config["base_file_name"],chromosomes=config["chromosomes"]),
    		expand("results/GatherPileupSummaries/{tumor}/{tumor}.table",tumor=config["base_file_name"]),
		expand("results/CalculateContamination/{tumor}/{tumor}_contamination.table",tumor=config["normals"]),
		expand("results/CalculateContamination/{tumor}/{tumor}.segments.table",tumor=config["normals"]),
		expand("results/FilterMutectCalls/{tumor}/filtered_all.vcf.gz",tumor=config["normals"]),
		expand("results/FilterMutectCalls/{tumor}/filtering_stats.tsv",tumor=config["normals"])

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

rule GatherPileupSummaries:
	output:
		"results/GatherPileupSummaries/{tumor}/{tumor}.table"
	params:
		reference_dict = config["reference_dict"],
		gatk = config["gatk_path"],
		chromosomes=config["chromosomes"]
	log:
		"logs/GatherPileupSummaries/{tumor}.log"
	shell:
		"""
		all_pileup_inputs=`for chrom in {params.chromosomes}; do
		printf -- "-I results/GetPileupSummaries/{wildcards.tumor}/pileup_summaries_${{chrom}}.table "; done`
		
		({params.gatk} GatherPileupSummaries \
		--sequence-dictionary {params.reference_dict} \
		$all_pileup_inputs \
		-O {output}) 2> {log}
		"""
	
rule CalculateContamination:
	input:
		tumor_pileup=lambda wildcards: getFullPathToFile(wildcards.tumor, "results/GatherPileupSummaries/"),
		normal_pileup=lambda wildcards: getFullPathToFile(config["normals"][wildcards.tumor], "results/GatherPileupSummaries/")
	output:
		contamination_table="results/GatherPileupSummaries/{tumor}/{tumor}_contamination.table",
		tumor_segmentation="results/GatherPileupSummaries/{tumor}/{tumor}.segments.table"
		
	params:
		gatk = config["gatk_path"]
	log:
		"logs/CalculateContamination/{tumor}/{tumor}_contamination.log"
	shell:
		"({params.gatk} CalculateContamination \
   		-I {input.tumor_pileup} \
   		-matched {input.normal_pileup} \
		--tumor-segmentation {output.tumor_segmentation} \
   		-O {output.contamination_table}) 2> {log}"

rule FilterMutectCalls:
	input:
		unfiltered_vcf = "results/GatherVcfs/{tumor}/gathered_unfiltered.vcf.gz",
		vcf_index = "results/GatherVcfs/{tumor}/gathered_unfiltered.vcf.gz.tbi",
		segments_table = "results/CalculateContamination/{tumor}/{tumor}.segments.table",
		contamination_table = "results/CalculateContamination/{tumor}/{tumor}_contamination.table",
		read_orientation_model = "results/LearnReadOrientationModel/{tumor}/read_orientation_model.tar.gz",
		mutect_stats = "results/MergeMutectStats/{tumor}/mutect_merged.stats"
	output:
		filtered_vcf = "results/FilterMutectCalls/{tumor}/filtered_all.vcf.gz",
		filtering_stats = "results/FilterMutectCalls/{tumor}/filtering_stats.tsv"
	params:
		gatk = config["gatk_path"],
		reference_genome = config["reference_genome"]
	log:
		"logs/FilterMutectCalls/{tumor}/{tumor}_filter_mutect_calls.txt"
	shell:
		"({params.gatk} FilterMutectCalls \
		-R {params.reference_genome} \
		-V {input.unfiltered_vcf} \
		--tumor-segmentation {input.segments_table} \
		--contamination-table {input.contamination_table} \
		--ob-priors {input.read_orientation_model} \
		--stats {input.mutect_stats} \
		--filtering-stats {output.filtering_stats} \
		-O {output.filtered_vcf}) 2> {log}"

rule SelectVariantsForFilterMutectCalls:
	input:
		filtered_all="results/FilterMutectCalls/{tumor}/filtered_all.vcf.gz"
	output:
		filtered_vcf="results/SelectVariantsForFilterMutectCalls/{tumor}/filtered.vcf.gz"
	params:
		gatk = config["gatk_path"],
		reference_genome = config["reference_genome"],
		interval_list = config["interval_list"]
	log:
		"logs/SelectVariantsForFilterMutectCalls/{tumor}/{tumor}_SelectVariantsForFilterMutectCalls.txt"
	shell:
		"({params.gatk} SelectVariants \
		-R {params.reference_genome} \
		-L  {params.interval_list}\
		-V {input.filtered_all} \
		-O {output.filtered_vcf} \
		--exclude-filtered 2> {log}"

