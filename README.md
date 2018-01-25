# RNA splicing in reprogramming

Code for reproducing the data in (TODO: URL publication).

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

### Get genome resources

In this section, the following resources for human, mouse and chimpanzee are downloaded from 
[Ensembl](http://www.ensembl.org/index.html) (release 84), filtered/processed and indexed:
* genome
* gene annotations
* transcriptome

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
> This step uses Anduril/DRMAA-based execution on a HPC cluster!  
> This step requires several TB of storage space!
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

* Alexander Kanitz
* Afzal Pasha Syed
* Keisuke Kaji
* Mihaela Zavolan

All code not listed in the [Pre-requisites](#pre-requisites) section written by Alexander Kanitz. 
See *Authors' contributions* section in (TODO: URL publication) for further details.

## Acknowledgments

The authors would like to thank:
* [Zavolan lab](https://www.biozentrum.unibas.ch/research/groups-platforms/overview/unit/zavolan/), 
  [Biozentrum](https://www.biozentrum.unibas.ch/home/), [University of 
  Basel](https://www.unibas.ch/en.html), particularly
    * Christina J. Herrmann
    * Andreas J. Gruber
    * Maciej Bak
* [Kaji lab](http://www.crm.ed.ac.uk/research/group/biology-reprogramming), [MRC Centre for 
  Regenerative Medicine](http://www.crm.ed.ac.uk/), [University of 
  Edinburgh](https://www.ed.ac.uk/), particularly
    * Sergio Menendez
    * Tyson Ruetz
    * Sarah Brightwell
* [Single cell facility](https://www.bsse.ethz.ch/scf), [Department of Biosystems and 
  Engineering](https://www.bsse.ethz.ch/), [ETH Zurich](https://www.ethz.ch/en.html), particularly
    * Verena Jäggin
    * Telma Lopez
* [sciCORE Center for Scientific Computing](https://scicore.unibas.ch/)
* [Swiss Institute of Bioinformatics](https://www.sib.swiss/)
* [The Cancer Genome Atlas](https://cancergenome.nih.gov/)

See *Acknowledgements* section in (TODO: URL publication) for further details.

## Funding
* [ERC Starting Grant](https://erc.europa.eu/funding/starting-grants) to Mihaela Zavolan 
  (310510-WHYMIR)
* [MRC Senior Non-Clinical 
  Fellowship](https://www.mrc.ac.uk/skills-careers/fellowships/non-clinical-fellowships/senior-non-clinical-fellowship-sncf/) 
  to Keisuke Kaji (MR/N008715/1)

## License

Copyright 2018 Biozentrum, University of Basel

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the License should also be available in the file [LICENSE](LICENSE).
