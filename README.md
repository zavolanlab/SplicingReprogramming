# RNA splicing in reprogramming
Code for reproducing the data in [REF].

## Reproducing the data
> **Note:** Bash is the recommended shell for the execution of all commands in this section. 
> Commands may need to be modified if executed from another shell.

### Pre-requisites
This section lists the software requirements, as well as a description of the hardware/software 
setup that was used to execute resource-intensive processes.  

> **Note:** All indicated versions refer to those used in this study. Others may work, but have not been tested.

#### Required software
The following software is required:
* [Anduril](http://anduril.org/site/resources/anduril1/), 1.2.23 (`anduril`)
* [cutadapt](https://cutadapt.readthedocs.io/en/stable/), 1.8.3 (`cutadapt`)
* [Git](https://git-scm.com/), 1.8.5.6
* [Java SE Runtime Environment](http://www.oracle.com/technetwork/java/javase/overview/index.html), 
* [kallisto](https://pachterlab.github.io/kallisto/), 0.42.3 (`kallisto`)
* [Ontologizer](http://ontologizer.de/), 2.1 Build: 20160628-1269 (see note)
* [Python2](https://www.python.org/), 2.7.11 (`python`) with modules
    * drmaa
    * TODO
* [Python3](https://www.python.org/), 3.5.2 with modules
    * TODO
* [Samtools](http://www.htslib.org/), 1.3.1 (`samtools`)
* [SRA Toolkit](https://www.ncbi.nlm.nih.gov/sra/docs/toolkitsoft/), 2.8.0 (`fastq-dump`)
* [STAR](https://github.com/alexdobin/STAR), 2.4.1c (`STAR`)
* [SUPPA](https://github.com/comprna/SUPPA), 2.1 (`eventGenerator.py`, `psiCalculator.py`, 
  `significanceCalculator.py`; see note)
* [R](https://www.r-project.org/), 3.2.2 (`R`, `Rscript`) with packages
    * TODO
  1.7.0_80-b15 (`java`)

TODO: Check for completeness

> **Note:** Wherever followed by parentheses, the indicated executable names, when called from a 
> shell, have to link to the correct version of the specific software. You may need to modify your 
> `$PATH` to ensure this.  

> **Note:** The file [`Ontologizer.jar`](http://ontologizer.de/cmdline/Ontologizer.jar) needs to be 
> downloaded and copied/moved to the following location (after cloning this repository and setting 
> the `$root` variable): `${root}/scriptsSoftware/Ontologizer.jar`  

> **Note:** A *shebang* interpreter directive has to be added to each of the individual SUPPA 
> component scripts, consisting of an absolute path pointing to a Python interpreter (and **not** a 
> call to `env`!). In the case of `eventGenerator.py` and `psiCalculator.py` this has to be a 
> Python2 (tested with version 2.7.11) and for `significanceCalculator.py` a Python3 interpreter 
> (tested with version TODO).

#### Operating system
All analyses were performed on systems running:
* [CentOS Linux](https://www.centos.org/), 6.5 with
    * [GNU Bash](https://www.gnu.org/software/bash/), 4.2.0(1)
    * [GNU Coreutils](https://www.gnu.org/software/coreutils/coreutils.html), 8.9

#### Resource management
This study features two resource-intensive processing workflows, each step of which is remotely 
executed on a High Performance Computing (HPC) cluster whose resources are managed by a Distributed Resource Management (DRM) application (e.g. [Univa Grid Engine](http://www.univa.com/products/grid-engine)). The [Anduril](http://anduril.org/site/) platform is used to manage their execution with the help of the following required components:
* the [DRM application API (DRMAA)](https://www.drmaa.org/)) library (to be set up on the HPC)
* a corresponding Python module (installed on the client)

We have used the following configuration:
* **HPC** - UGE 8.3.1p6 with libdrmaa.so.1.0
* **Client** - Python 2.7.5 with drmaa 0.7.6

You will also need to ensure that the following environment variables are (correctly) set on your 
system:
* `$ANDURIL_HOME`
* `$DRMAA_LIBRARY_PATH`

> **Note:** The DRMAA library, as well as the corresponding Python module and environment variable 
> `$DRMAA_LIBRARY_PATH` are not required if Anduril workflows are to be executed locally. However, 
> note that execution of the index generation and mapping/quantification pipelines will require up 
> to 40Gb of available RAM for human/mouse samples and that workflows need to be manually 
> re-configured for local execution.

### Clone repository
Now it's time to clone this repository:
```sh
git clone TODO: Add URL
```
We can move into the new directory and set it as the root directory for the analysis:
```sh
cd SpliceFactorsReprogramming
root="$PWD"
```
Now that we have defined the `$root` variable, your `$PYTHONPATH` has to be set/modified to include 
a custom Anduril resource:
```bash
export PYTHONPATH="${root}/frameworksAuxiliary/anduril/lib:$PYTHONPATH"
```
> **Note:** Executing the `export` commands in the current shell instance will only affect the 
> environment of that particular instance. To avoid having to execute these again in future 
> instances, add the lines to your shell startup script (e.g. `.bashrc` for Bash).

### Description of files
TODO: Complete

Freshly cloned, the directory should have the following (top-level) content:
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

### Download data

In this section, RNA-Seq libraries and expression data from human tissues and cancers are downloaded 
from various public repositories.

1. Download RNA-Seq data [REF; Table 1] from the [Sequence Read 
   Archive](https://www.ncbi.nlm.nih.gov/sra):
> **Note:** This step requires >500GB of storage space!
```sh
"${root}/documentation/download_data/01.download_sra_data.sh"
```

2. Download human tissue expression data from [The Human Protein 
   Atlas](https://www.proteinatlas.org/) (release 16):
```sh
"${root}/documentation/download_data/02.download_thpa_data.sh"
```

3. Download tumor and control tissue expression data from [The Cancer Genome 
   Atlas](https://cancergenome.nih.gov/) via [FireBrowse](http://firebrowse.org/) (originally 
   downloaded November 30th, 2017):
```sh
"${root}/documentation/download_data/03.download_tcga_data.sh"
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

5. **[Optional]** Re-organize and archive Anduril log files:
```sh
"${root}/documentation/align_and_quantify/05.archive_log_files.sh"
```

### Summarize RNA-Seq, THPA and TCGA data

1. Aggregate data into various feature (rows) x sample (columns) matrices:
```sh
"${root}/documentation/summarize_data/01.summarize_sra_data.sh"
```

2. Aggregate data into feature (rows) x tissue (columns) log2 TPM matrix:
```sh
"${root}/documentation/summarize_data/02.summarize_thpa_data.sh"
```

3. Aggregate data into feature (rows) x cancer (columns) log2 fold change matrix:
```sh
"${root}/documentation/summarize_data/03.summarize_tcga_data.sh"
```

### Differential gene expression analyses

TODO: Run analysis & summarize results

### Differential splicing analyses

TODO: Run analysis & summarize results

### FIGURES....................

### Clean up

1. **[Optional]** Calculate md5 hash sums for all output files:
TODO: Adapt script to calculate hash sums for *all* files
```sh
"${root}/documentation/align_and_quantify/01.calculate_hash_sums.sh"
```

2. **[Optional]** Remove temporary files:
TODO: Adapt script to remove *all* temporary files
```sh
"${root}/documentation/align_and_quantify/02.remove_temporary_files.sh"
```

## Credit

### Authors

* Alexander Kanitz
* Afzal Pasha Syed
* Keisuke Kaji
* Mihaela Zavolan

All code not listed in the [Pre-requisites](#pre-requisites) section written by Alexander Kanitz.  
See *Authors' contributions* section in [REF] for further details.

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

See *Acknowledgements* section in [REF] for further details.

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
