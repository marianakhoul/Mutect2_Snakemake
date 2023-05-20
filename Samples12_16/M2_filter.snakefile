configfile: "config/samples_getpileup.yaml"
configfile: "config/config.yaml" 

rule all:
    input:
        expand("results/GetPileupSummaries/{tumor}/pileup_summaries.table",tumor=config["base_file_name"])


rule GetPileupSummaries:
    input:
        filepaths = lambda wildcards: config["base_file_name"][wildcards.tumor]
    output:
        "results/GetPileupSummaries/{tumor}/pileup_summaries.table"
    params:
        reference_genome = config["reference_genome"],
        gatk = config["gatk_path"],
        variants_for_contamination = config["variants_for_contamination"]
    log:
        "logs/GetPileupSummaries/{tumor}_get_pileup_summaries.txt"
    shell:
        "({params.gatk} GetPileupSummaries \
        -R {params.reference_genome} \
        -I {input.filepaths} \
        -V {params.variants_for_contamination} \
        -L {params.variants_for_contamination} \
        -O {output}) 2> {log}"

