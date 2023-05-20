configfile: "config/samples_getpileup.yaml"
configfile: "config/config.yaml" 

rule all:
    input:
      
rule GetPileupSummaries:
    input:
    output:
        
    params:
        gatk = config["gatk_path"],
        variants_for_contamination = config["variants_for_contamination"]
    log:
        "logs/get_pileup_summaries/{tumors}_get_pileup_summaries.txt"
    shell:
