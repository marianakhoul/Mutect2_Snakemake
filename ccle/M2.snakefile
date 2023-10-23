configfile: "config/samples.yaml"
configfile: "config/config.yaml" 

rule all:
	input:
		expand("results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait.vcf.gz",tumor=config["normals"]),
		expand("results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait.vcf.gz.tbi",tumor=config["normals"]),
		expand("results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait_f1r2.tar.gz",tumor=config["normals"]),
		expand("results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait.vcf.gz.stats",tumor=config["normals"]),
		expand("results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait_bamout.bam",tumor=config["normals"]),
		expand("results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait_bamout.bai",tumor=config["normals"])

rule mutect2:
	input:
		tumor_filepath = lambda wildcards: config["base_file_name"][wildcards.tumor]
	output:
		vcf = "results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait.vcf.gz",
		tbi = "results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait.vcf.gz.tbi",
		tar = "results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait_f1r2.tar.gz",
		stats = "results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait.vcf.gz.stats",
		bam = "results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait_bamout.bam",
		bai = "results/mutect2/{tumor}/{tumor}_unfiltered_ccle_params_with_bait_bamout.bai"
	params:
		reference_genome = config["reference_genome"],
		germline_resource = config["germline_resource"],
		gatk = config["gatk_path"],
		panel_of_normals = config["panel_of_normals"],
		normals = lambda wildcards: config["normals"][wildcards.tumor],
		intervals = config["interval_list"]
	log:
		"logs/mutect2/{tumor}_mutect2.txt"
	shell:
		"({params.gatk} Mutect2 \
		-reference {params.reference_genome} \
		-input {input.tumor_filepath} \
		-tumor {params.normals} \
		-intervals {params.intervals} \
		--interval-padding 100 \
		--germline-resource {params.germline_resource} \
		--genotype-germline-sites true \
		--genotype-pon-sites true \
		--f1r2-tar-gz {output.tar} \
		--panel-of-normals {params.panel_of_normals} \
		--read-filter PassesVendorQualityCheckReadFilter \
		--read-filter HasReadGroupReadFilter \
		--read-filter NotDuplicateReadFilter \
		--read-filter MappingQualityAvailableReadFilter \
		--read-filter MappingQualityReadFilter \
		--minimum-mapping-quality 30 \
		--read-filter OverclippedReadFilter \
		--filter-too-short 25 \
		--read-filter GoodCigarReadFilter \
		--read-filter AmbiguousBaseReadFilter \
		--native-pair-hmm-threads 2 \
		--seconds-between-progress-updates 100 \
		--downsampling-stride 20 \
		--max-reads-per-alignment-start 6 \
		--max-suspicious-reads-per-alignment-start 6 \
		--bam-output {output.bam} \
		-output {output.vcf}) 2> {log}"

