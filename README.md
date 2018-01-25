# RNA splicing in reprogramming

Code for reproducing the data in [REF].

## Reproducing the data

### Pre-requisites
Add description (can partly take this from RNA-seq pipeline description)

Add links and version numbers
* Anduril
* STAR
* kallisto
* SUPPA
* ...

Add words on cluster

### Clone repository

Clone the repository:
```sh
git clone
```

Set root directory:
```sh
cd SplceFactorsReprogramming
root="$PWD"
```

### Description of files


### Get public resources


### Download RNA-Seq data

Download RNA-Seq data from SRA:
```sh
"${root}/documentation/sra_data/01.download_data.sh"
```

### Quantification & alignments

Generate evenly sized chunks of the sample table:
```sh
"${root}/documentation/align_and_quantify/01.split_sample_table.sh"
```

Generate Anduril network files for the processing of RNA-Seq data:
```sh
"${root}/documentation/align_and_quantify/02.generate_workflows.sh"
```

Build and execute Anduril commands:
```sh
"${root}/documentation/align_and_quantify/03.execute_workflows.sh"
```

Move and re-organize persistent output files:
```sh
"${root}/documentation/align_and_quantify/04.organize_output_files.sh"
```

Aggregate data into feature (rows) x sample (columns) matrices:
```sh
"${root}/documentation/align_and_quantify/05.summarize_data.sh"
```

[Optional] Calculate md5 hash sums for persistent output files:
```sh
"${root}/documentation/align_and_quantify/06.calculate_hash_sums.sh"
```

[Optional] Re-organize and archive Anduril log files:
```sh
"${root}/documentation/align_and_quantify/07.archive_log_files.sh"
```

[Optional] Remove temporary and intermediate Anduril data files:
```sh
"${root}/documentation/align_and_quantify/.sh"
```






## Authors

List the main authors and, if applicable, link to a separate file 'contributors' within the repository

## Acknowledgments

List all non-authors, organisations or whatever/whoever was instrumental in realizing the project

## License

Mention the license and link to local file [LICENSE.md](LICENSE.md) for details

