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

## Documentation

### Creating components

As Anduril is component-based, it is not possible to include new programs or scripts in workflows straight away. Components reside in `bundle/components`, each in their separate subdirectories. Anduril expects each component subdirectory to contain an XML descriptor file named `component.xml`. This file describes all input and output ports, as well as any command-line parameters. To make use of the features of this project, an additional Python script file named `component.py` is required. It basically contains a generic command template (in a markup format) built based on the XML descriptor file. Depending on the parameters set in the Anduril workflow file, the command is then rendered accordingly during execution.

To facilitate the process of creating components, there is a spreadsheet template available at:  
https://docs.google.com/spreadsheets/d/1ZuXL0vaDIoYBYI6OeTU9Quy7DPZ1Nil_vWWBr8zS8ek

Download this template:  
"File" -> "Download as" -> Microsoft Excel (.xlsx)

After opening the file in your spreadsheet editor, you can add a new component by adding a new tab (name it according to the program/script that you want to add) and copying the contents of tab 'TEMPLATE' to the new tab. Have a look at the 'EXAMPLE' tab and fill out the fields for your component accordingly. It is possible to add more than one component per spreadsheet file. When done, the XML and Python wrapper files can be added automatically. To do this, execute:

```bash
pythonLibs/createComponent.py <SPREADSHEET> bundle/components
```

### Adding test cases

[TODO: FILL IN LATER]


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
