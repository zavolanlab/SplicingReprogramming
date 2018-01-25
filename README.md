# RNA splicing in reprogramming

Code for reproducing the data in TODO: REF.

## Reproducing the data

### Pre-requisites
TODO: Add description (can partly take this from RNA-seq pipeline description)

TODO: Add links and version numbers
* Anduril
* STAR
* kallisto
* SUPPA
* ...

TODO: Add words on cluster

### Clone repository

Clone the repository:
```sh
git clone TODO
```

Set root directory:
```sh
cd SpliceFactorsReprogramming
root="$PWD"
```

### Description of files

TODO

### Get public resources

In this section, genome resources for human, mouse and chimpanzee are downloaded, filtered, 
processed and indexed.

1. Downloads, filters and further processes genomes, gene annotations and transcriptomes:
```sh
# Human
"${root}/documentation/genome_resources/hsa.GRCh38_84/01.get_and_process_genome_resources.sh"
# Mouse
"${root}/documentation/genome_resources/mmu.GRCm38_84/01.get_and_process_genome_resources.sh"
# Chimpanzee
"${root}/documentation/genome_resources/ptr.CHIMP2.1.4_84/01.get_and_process_genome_resources.sh"
```

2. Generate transcript quantification and read mapping indices and compile AS events:
> This step uses Anduril/DRMAA-based execution on a HPC cluster!
```sh
# Human
"${root}/documentation/genome_resources/hsa.GRCh38_84/02.generate_indices_and_as_events.sh"
# Mouse
"${root}/documentation/genome_resources/mmu.GRCm38_84/02.generate_indices_and_as_events.sh"
# Chimpanzee
"${root}/documentation/genome_resources/ptr.CHIMP2.1.4_84/02.generate_indices_and_as_events.sh"
```

### Get RNA-Seq data

In this section, RNA-Seq libraries from several different studies (TODO: see Table 1 in publication) 
are downloaded from the [Sequence Read Archive](https://www.ncbi.nlm.nih.gov/sra).

1. Download data:  
> This step requires >500GB of storage space!  
```sh
"${root}/documentation/sra_data/01.download_data.sh"
```

### Quantification & alignments

In this section, the previously downloaded RNA-Seq libraries are uniformly processed. The following 
data are computed and summarized:
* Abundance of transcript isoforms
* Inclusion rates for alternative splicing (AS) events
* Read alignments

1. Generate evenly sized chunks of the sample table:
```sh
"${root}/documentation/align_and_quantify/01.split_sample_table.sh"
```

2. Generate Anduril network files for the processing of RNA-Seq data:
```sh
"${root}/documentation/align_and_quantify/02.generate_workflows.sh"
```

3. Build and execute Anduril commands:
> This step uses Anduril/DRMAA-based execution on a HPC cluster!  This step requires several TB of 
> storage space!
```sh
"${root}/documentation/align_and_quantify/03.execute_workflows.sh"
```

4. Move and re-organize persistent output files:
```sh
"${root}/documentation/align_and_quantify/04.organize_output_files.sh"
```

5. Aggregate data into feature (rows) x sample (columns) matrices:
```sh
"${root}/documentation/align_and_quantify/05.summarize_data.sh"
```

6. [Optional] Calculate md5 hash sums for persistent output files:
```sh
"${root}/documentation/align_and_quantify/06.calculate_hash_sums.sh"
```

7. [Optional] Re-organize and archive Anduril log files:
```sh
"${root}/documentation/align_and_quantify/07.archive_log_files.sh"
```

8. [Optional] Remove temporary and intermediate Anduril data files:
```sh
"${root}/documentation/align_and_quantify/08.remove_temporary_files.sh"
```



## Authors

List the main authors and, if applicable, link to a separate file 'contributors' within the repository

## Acknowledgments

List all non-authors, organisations or whatever/whoever was instrumental in realizing the project

## License

Mention the license and link to local file [LICENSE.md](LICENSE.md) for details

