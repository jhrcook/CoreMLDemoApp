

# read in list of plants
plantList = list()
with open("plant_names.txt") as fin:
	for line in fin:
		plantList.append(line.rstrip())

numberOfImages = 100


# some notes




rule make_json:
	output:
		plant_json = "plant_jsons/{plant_name}.json"
	script:
		"make_plant_json.r"



rule download_images:
	input:
		plant_json = "plant_jsons/{plant_name}.json"
	output:
		directory("downloads/{plant_name}")
	shell:
		"googleimagesdownload --config_file {input.plant_json}"