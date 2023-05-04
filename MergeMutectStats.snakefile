import os

configfile: "config/samples.yaml"
configfile: "config/config.yaml" 

CHRS = [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,'Y']	

rule all:
	input:
		expand("results/MergeMutectStats/{base_file_name}/mutect_merged.stats",base_file_name=config["base_file_name"])

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

 
