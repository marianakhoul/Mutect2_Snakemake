


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
		printf -- "I=results/mutect2/{wildcards.base_file_name}/unfiltered_$chrom.vcf.gz "; done`
	
		({params.java} -jar {params.picard_jar} GatherVcfs \
		$all_vcf_inputs \
		O={output}) 2> {log}"""
