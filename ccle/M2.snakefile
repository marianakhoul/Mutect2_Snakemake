configfile: "config/samples.yaml"
configfile: "config/config.yaml" 

m2_extra_args=config["m2_extra_args"]
	
rule all:
    input:
