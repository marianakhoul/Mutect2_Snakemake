import os

configfile: "config/samples.yaml"
configfile: "config/config.yaml" 

rule all:
	input:
		expand("results/MergeMutectStats/{base_file_name}/mutect_merged.stats",base_file_name=config["base_file_name"])

rule MergeMutectStats:
	output:
		"results/MergeMutectStats/{base_file_name}/mutect_merged.stats"
	params:
		gatk = config["gatk_path"]
	log:
		"logs/MergeMutectStats/{base_file_name}_merge_mutect_stats.txt"
	shell:
		"""
		all_stat_inputs=`for chromosome in {chromosomes}; do
		printf -- "-stats results/{base_file_name}/unfiltered_${chromosome}.vcf.gz.stats "; done`
		
		({params.gatk} MergeMutectStats \
		$all_stat_inputs \
		-O {output}) 2> {log}"""

 
