configfile: "config/samples_getpileup.yaml"
configfile: "config/config.yaml" 

rule all:
	input:
		expand("results/GatherPileupSummaries/{tumor}/{tumor}.table",tumor=config["base_file_name"])

rule GatherPileupSummaries:
	output:
		"results/GatherPileupSummaries/{tumor}/{tumor}.table"
	params:
		reference_dict = config["reference_dict"],
		gatk = config["gatk_path"]
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
		
	

    
