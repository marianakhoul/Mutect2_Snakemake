configfile: "config/samples_getpileup.yaml"
configfile: "config/config.yaml" 

rule all:
	input:
		expand("results/MergeBamOuts/{tumor}/unsorted.out.bam",tumor=config["normals"]),
		expand("results/MergeBamOuts/{tumor}/bamout.bam",tumor=config["normals"])
	

#rule GatherGetPileupSummaries:
#    output:
rule MergeBamOuts:
    output:
        unsorted_output = "results/MergeBamOuts/{tumor}/unsorted.out.bam",
        bam_out = "results/MergeBamOuts/{tumor}/bamout.bam"
    params:
        reference_genome = config["reference_genome"],
        java = config["java"],
	picard_jar = config["picard_jar"],
	chromosomes=config["chromosomes"]
    log:
        "logs/MergeBamOuts/{tumor}/MergeBamOuts.log"
    shell:
        """
	all_bamout_inputs=`for chrom in {params.chromosomes}; do
	printf -- "I=results/mutect2/{wildcards.tumor}/{wildcards.tumor}_${{chrom}}_bamout.bam "; done`
	
	({params.java} -jar {params.picard_jar} GatherBamFiles \
        R={params.reference_genome} \
	$all_bamout_inputs \
	O={output.unsorted_output}) 2> {log}
        """

    
