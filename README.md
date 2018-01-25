# RNA splicing in reprogramming
Code for reproducing the data in (TODO: URL publication).

## Reproducing the data
TODO: Add links and add/check version numbers

> **Note:** Bash is the recommended shell for the execution of all commands in this section. 
> Commands may need to be modified if executed from another shell.

### Pre-requisites
This section lists the software requirements, as well as a description of the operating system and 
hardware used to run the original analysis. The indicated versions refer to those used in the study. 
Other versions may work, but have not been tested.

#### Required software
* Git 1.8.5.6
* Anduril 1.2.23
* SRA Toolkit 2.8.0
* cutadapt 1.8.3
* samtools 1.3.1
* kallisto 0.42.3
* STAR 2.4.1c
* SUPPA ...
* ...


#### Operating system
* CentOS 6.5 with
    * GNU bash 4.2.0(1)
    * GNU coreutils 8.9

#### Anduril, high-performance computing (HPC) cluster & distributed resource management (DRM)
This study features two resource-intensive processing workflows, each step of which is remotely 
executed on an HPC cluster whose resources are managed by a DRM application (e.g. [Univa Grid 
Engine](http://www.univa.com/products/grid-engine)). The [Anduril](http://anduril.org/site/) 
platform is used to manage their execution with the help of the following required components:
* the [DRM application API (DRMAA)](https://www.drmaa.org/)) library (to be set up on the HPC)
* a corresponding Python module (installed on the client)

We have used the following configuration:
* **HPC** - UGE 8.3.1p6 with libdrmaa.so.1.0
* **Client** - Python 2.7.5 with drmaa 0.7.6

Furthermore, the following environment variables have to be set/modified:
```bash
export DRMAA_LIBRARY_PATH="<PATH>"   # Set path according to your system
export PYTHONPATH="${root}/frameworksAuxiliary/anduril/lib:$PYTHONPATH"
```

> **NOTE:** The DRMAA library and variable definition as well as installation of the corresponding 
> Python package are not required if workflows are supposed to be executed on the local machine. However, 
 note that execution of the index generation and mapping/quantification pipelines will require up to 
 40Gb of available RAM for human or mouse samples and that workflows need to be manually 
 re-configured for local execution.

The script `kallisto_extract_output.R` required by the mapping/quantification pipeline is distributed as part of this repository and can be found in directory `"${projectRoot}/scriptsSoftware/anduril`. To make it available to Anduril, it has to be added to your `$PATH`:

Finally, you will have to ensure that the correct versions of the executables of all commands used by the pipeline are available in your `$PATH`. Specifically, these are:
* anduril
* fastq-dump
* cutadapt
* STAR
* kallisto
* samtools
* suppa.py

**NOTE:** See [Requirements](#requirements) section for version requirements.

For the BC2/sciCORE system, this can easily be achieved by adding the following to your `$PATH`:
```bash
export PATH="/scicore/home/zavolan/kanitz/soft/bin:$PATH"
module load anduril/1.2.23-goolf-1.4.10-Python-2.7.5
module load SAMtools/1.3.1-goolf-1.7.20
```

**NOTE:** Executing the `export` commands in the current shell instance will only affect the 
environment of that particular instance. To avoid having to execute these again in future instances, 
add the lines to your shell startup script (e.g. `.bashrc` for Bash).






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

TODO: Modify/add

The directory will contain the barebones directory structure with the following top-level content:
* `frameworksAuxiliary  `Contains the Anduril bundle including all required components
* `scriptsSoftware      `Contains scripts required for the pipeline and preparation

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
> **Note:** This step uses Anduril/DRMAA-based execution on a HPC cluster!
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

> **Note:** This step requires >500GB of storage space!
```sh
"${root}/documentation/sra_data/01.download_data.sh"
```

### Pre-process RNA-Seq data

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
> **Note:** This step uses Anduril/DRMAA-based execution on a HPC cluster!  
> **Note:** This step requires several TB of storage space!
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

6. **[Optional]** Calculate md5 hash sums for persistent output files:
```sh
"${root}/documentation/align_and_quantify/06.calculate_hash_sums.sh"
```

7. **[Optional]** Re-organize and archive Anduril log files:
```sh
"${root}/documentation/align_and_quantify/07.archive_log_files.sh"
```

8. **[Optional]** Remove temporary and intermediate Anduril data files:
```sh
"${root}/documentation/align_and_quantify/08.remove_temporary_files.sh"
```

## Credit

### Authors

* Alexander Kanitz
* Afzal Pasha Syed
* Keisuke Kaji
* Mihaela Zavolan

All code not listed in the [Pre-requisites](#pre-requisites) section written by Alexander Kanitz.  
See *Authors' contributions* section in (TODO: URL publication) for further details.

### Acknowledgments

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

### Funding
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
