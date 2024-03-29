configfile: "config/samples.yaml"
configfile: "config/config.yaml" 


rule all:
	input:
		expand("results/mutect2/{tumor}/unfiltered_{tumor}.vcf.gz",tumor=config["base_file_name"]),
		expand("results/mutect2/{tumor}/unfiltered_{tumor}.vcf.gz.tbi",tumor=config["base_file_name"])

rule mutect2:
  input:
			tumor_filepath = lambda wildcards: config["base_file_name"][wildcards.tumor]
  output:
			vcf = "results/mutect2/{tumor}/unfiltered_{tumor}.vcf.gz",
			tbi = "results/mutect2/{tumor}/unfiltered_{tumor}.vcf.gz.tbi"
  params:
			reference_genome = config["reference_genome"],
			germline_resource = config["germline_resource"],
			gatk = config["gatk_path"],
			panel_of_normals = config["panel_of_normals"],
			normals = lambda wildcards: config["normals"][wildcards.tumor]
  log:
			"logs/mutect2/{tumor}_mutect2.txt"
  shell:
        		"""
#mkdir -p results/mutect2/{wildcards.tumor}/
touch {output.vcf}

({params.gatk} --java-options "-Xmx20G" Mutect2 \
-R {params.reference_genome} \
-I {input.tumor_filepath} \
-normal {params.normals} \
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
--genotype-germline-sites true \
--genotype-pon-sites true \
--interval-padding 100 \
--germline-resource {params.germline_resource} \
--panel-of-normals {params.panel_of_normals} \
-O {output.vcf}) 2> {log}"""

