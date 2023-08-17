configfile: "config/samples.yaml"
configfile: "config/config.yaml" 


rule all:
	input:

rule mutect2:
  input:
			tumor_filepath = lambda wildcards: config["base_file_name"][wildcards.tumor]
  output:
			vcf = temp("results/mutect2/{tumor}/unfiltered_{chromosomes}.vcf.gz"),
			tbi = temp("results/mutect2/{tumor}/unfiltered_{chromosomes}.vcf.gz.tbi"),
			tar = temp("results/mutect2/{tumor}/unfiltered_{chromosomes}_f1r2.tar.gz"),
			stats = temp("results/mutect2/{tumor}/unfiltered_{chromosomes}.vcf.gz.stats"),
  params:
			reference_genome = config["reference_genome"],
			germline_resource = config["germline_resource"],
			gatk = config["gatk_path"],
			panel_of_normals = config["panel_of_normals"],
			normals = lambda wildcards: config["normals"][wildcards.tumor]
  log:
			"logs/mutect2/{tumor}_{chromosomes}_mutect2.txt"
  shell:
        		"({params.gatk} Mutect2 \
			      -reference {params.reference_genome} \
			      -input {input.tumor_filepath} \
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
            --read-filter AmbiguousBaseReadFilter 
            --native-pair-hmm-threads 2 \
            --seconds-between-progress-updates 100
            --genotype-germline-sites true \
            --genotype-pon-sites true \
            --interval-padding 100 \
			      --germline-resource {params.germline_resource} \
			      --panel-of-normals {params.panel_of_normals} \
			      -output {output.vcf}) 2> {log}"
