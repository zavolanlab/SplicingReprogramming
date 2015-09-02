# AndurilWorkflowDevelopmentFunctions

## Synopsis

Templates and convenience functions for the use with the scientific workflow framework Anduril.

## Motivation

Anduril is a feature-rich open-source component-based workflow framework for scientific data analysis. The aim of this project is to provide templates, workflow examples and functions that provide data analysts who are interested in developing custom workflows with easy access to Anduril's core functions. Specifically, scripts are provided that simplify the process of adding custom components and running workflows either on local machines or, via DRMAA support, to Distributed Resource Management systems such as Univa Grid Engine.

## Requirements

Anduril, Python

## Installation

This project builds on the Anduril workflow framework. Download the tarball of the latest version (`anduril-1.2.23.tgz` at the time of writing) from http://csbl.fimm.fi/anduril/current/ to a suitable directory.

Extract the downloaded archive:

```bash
tar xzvf <ARCHIVE>
```

Add the `ANDURIL_HOME` variable to your environment. It should point to the root directory of the Anduril installation. For example on Bash, add the following to your `.bashrc`:

```bash
export ANDURIL_HOME=<ANDURIL_ROOT_PATH>
```

For convenience, it is recommended to further make the `anduril` binary available in your `PATH`. On Bash, add the following to your `.bashrc`:

```bash
export PATH=<ANDURIL_ROOT_PATH>/bin:$PATH
```

To use the functions provided as part of this project, clone the repository in a suitable directory:

```bash
git clone ssh://git@git.scicore.unibas.ch:2222/AnnotationPipelines/Anduril.git
```

## Usage notes

- Refer to 'http://www.anduril.org/' for documentation on Anduril, AndurilScript syntax, bundles, 
  components, AndurilScript syntax, etc.
- Refer to files 'component.xml' in each subdirectory of 'bundle/components/' to inspect the 
  available Anduril options available to each component.
- Refer to the manuals of each component for more detailed usage information.

A detailed manual will be provided together with the first versioned release.

## History

Currently unversioned.

## Credits

(c) 2015  Alexander Kanitz | Biozentrum, University of Basel | <alexander.kanitz@alumni.ethz.ch>

Anduril is developed by the Systems Biology Laboratory, University of Helsinki  
Email: <anduril-dev@helsinki.fi> | URL: http://www.anduril.org/

## License

This project is licensed under the terms of the MIT license. A file `LICENSE.txt` should be included in the root directory of this project, but in case it is not, the license is available at http://opensource.org/licenses/MIT.
