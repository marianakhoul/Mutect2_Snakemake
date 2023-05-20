configfile: "config/samples_getpileup.yaml"
configfile: "config/config.yaml" 

rule all:
    input:
        expand("results/GetPileupSummaries/{tumor}/pileup_summaries.table",tumor=config["base_file_name"])
      
rule GetPileupSummaries:
    input:
        filepaths = lambda wildcards: config["base_file_name"][wildcards.tumor]
    output:
        expand("results/GetPileupSummaries/{tumor}/pileup_summaries.table",tumor=config["base_file_name"])
    params:
        gatk = config["gatk_path"],
        variants_for_contamination = config["variants_for_contamination"]
    log:
        expand("logs/GetPileupSummaries/{tumor}_get_pileup_summaries.txt",tumor=config["base_file_name"])
    shell:
        "({params.gatk} GetPileupSummaries \
        -I {input.filepaths} \
        -V {params.known_polymorphic_sites} \
        -L {params.known_polymorphic_sites} \
        -O {output}) 2> {log}"

