import os

configfile: "config/samples.yaml"
configfile: "config/config.yaml" 


rule all:
	input:
		expand("results/MergeMutectStats/{base_file_name}/mutect_merged.stats",base_file_name=config["base_file_name"]),
		expand("results/GatherVcfs/{base_file_name}/gathered_unfiltered.vcf.gz",base_file_name=config["base_file_name"]),
		expand("results/LearnReadOrientationModel/{base_file_name}/read_orientation_model.tar.gz", base_file_name = config["base_file_name"])

rule MergeMutectStats:
	output:
		"results/MergeMutectStats/{base_file_name}/mutect_merged.stats"
	params:
		gatk = config["gatk_path"],
		chromosomes=config["chromosomes"]
	log:
		"logs/MergeMutectStats/{base_file_name}_merge_mutect_stats.txt"
	shell:
		"""
		all_stat_inputs=`for chrom in {params.chromosomes}; do
		printf -- "-stats results/{wildcards.base_file_name}/unfiltered_$chrom.vcf.gz.stats "; done`
		
		({params.gatk} MergeMutectStats \
		$all_stat_inputs \
		-O {output}) 2> {log}"""

rule GatherVcfs:
	output:
		"results/GatherVcfs/{base_file_name}/gathered_unfiltered.vcf.gz"
	params:
		java = config["java"],
		picard_jar = config["picard_jar"],
		chromosomes=config["chromosomes"]
	log:
		"logs/GatherVcfs/{base_file_name}_gather_mutect_calls.txt"
	shell:
		"""
		all_vcf_inputs=`for chrom in {params.chromosomes}; do
		printf -- "I=results/{wildcards.base_file_name}/unfiltered_$chrom.vcf.gz "; done`
	
		({params.java} -jar {params.picard_jar} GatherVcfs \
		$all_vcf_inputs \
		O={output}) 2> {log}"""

rule LearnReadOrientationModel:
	output:
		"results/LearnReadOrientationModel/{base_file_name}/read_orientation_model.tar.gz"
	params:
		gatk = config["gatk_path"],
		chromosomes=config["chromosomes"]
	log:
		"logs/LearnReadOrientationModel/{base_file_name}_learn_read_orientation_model.txt"
	shell:
		"""
		all_f1r2_inputs=`for chrom in {params.chromosomes}; do
		printf -- "-I results/{wildcards.base_file_name}/unfiltered_$chrom_f1r2.tar.gz \\"; done`
	
		({params.gatk} LearnReadOrientationModel \
		$all_f1r2_inputs \
		-O {output}) 2> {log}"""
