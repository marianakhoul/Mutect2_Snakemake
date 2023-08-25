configfile: "config/samples.yaml"
configfile: "config/config.yaml" 


rule all:
	input:
		"results/MergeVcfs/subsetnormalpanel.vcf.gz"


rule MergeVcfs:
	output:
		"results/MergeVcfs/subsetnormalpanel.vcf.gz"
	params:
		java = config["java"],
		picard_jar = config["picard_jar"],
		normals = expand("{tumor}",tumor=config["normals"])
	log:
		"logs/MergeVcfs/merge_mutect_calls_subset.txt"
	shell:
		"""
		all_vcf_inputs=`for tum in {params.normals}; do
		printf -- "I=results/mutect2/$tum/unfiltered_$tum.vcf.gz "; done`
	
		({params.java} -jar {params.picard_jar} MergeVcfs \
		$all_vcf_inputs \
		O={output}) 2> {log}"""
