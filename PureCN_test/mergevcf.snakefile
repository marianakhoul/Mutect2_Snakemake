configfile: "config/samples.yaml"
configfile: "config/config.yaml" 


rule all:
	input:
		"results/MergeVcfs/allnormalpanel.vcf.gz"


rule MergeVcfs:
	output:
		"results/MergeVcfs/allnormalpanel.vcf.gz"
	params:
		java = config["java"],
		picard_jar = config["picard_jar"]
	log:
		"logs/MergeVcfs/merge_mutect_calls_all_normals.txt"
	shell:
		"""
		all_vcf_inputs=`for tum in {wildcards.tumor}; do
		printf -- "I=results/mutect2/{wildcards.tumor}/unfiltered_$tum.vcf.gz "; done`
	
		({params.java} -jar {params.picard_jar} MergeVcfs \
		$all_vcf_inputs \
		O={output}) 2> {log}"""
