configfile: "config/samples_getpileup.yaml"
configfile: "config/config.yaml" 

rule all:
    input:
        expand("results/{tumor}/pileup_summaries.table",tumor=config["base_file_name"])
      
rule GetPileupSummaries:
    input:
        filepaths = lambda wildcards: config["base_file_name"][wildcards.tumor]
    output:
        "results/{tumor}/pileup_summaries.table"
    params:
        gatk = config["gatk_path"],
        variants_for_contamination = config["variants_for_contamination"]
    log:
        "logs/get_pileup_summaries/{tumors}_get_pileup_summaries.txt"
    shell:
        "({params.gatk} GetPileupSummaries \
        -I {input.filepaths} \
        -V {params.known_polymorphic_sites} \
        -L {params.known_polymorphic_sites} \
        -O {output}) 2> {log}"

