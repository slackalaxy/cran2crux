# cran2crux 
Write CRUX ports for CRAN R modules

## Description
The `cran2crux` script automatically generates ready to use port(s) for R
modules available from [CRAN](https://cran.r-project.org/). The script
creates ports in the current directory. The name of each port is `r4-module`
(lowercase) and the release number is set to 1. If the port already exists,
`cran2crux` will overwrite it, so it is advisable to run it in an empty directory.

## Options
`-r`, `--recursive`: Create port for module and create ports for its dependencies and their own dependencies, recursively.  
`-ro`, `--recursive-opt`: Create port for module and create ports for its dependencies, as well as, optional dependencies, recursively. This may require to set *dependencies depth* to a higher number (see below).  
`<dependencies depth>`: A positive integer. This defines how many iterations of recursive searches for dependencies cran2crux will perform. Set higher to a higher value (>10) if dependencies list is large.

## Configuration
You can configure `/etc/cran2crux.conf` to set a maintainer line and a CRAN mirror. The R syntax is used, because it is sourced by the main script, therefore settings go like this:

    maintainer.info <- c("Petar Petrov, slackalaxy at gmail dot com")
    cranrepo.url <- "https://cloud.r-project.org"

## Example usage
Call `cran2crux`` in a newly created, empty directory:

    mkdir r4-modules
    cd r4-modules 

Let's create a port for the [Seurat](https://cran.r-project.org/web/packages/Seurat/) set of tools for single cell genomics, by [Satija lab](https://satijalab.org/seurat/):

    cran2crux Seurat

This will create a port for Seurat and its dependencies recursively:

    cran2crux Seurat -r
	
This will create a port for Seurat, its dependencies and optional 
dependencies, recursively. This may require more intensive dependencies
searches, therefore we increase the depth value to 15:

	cran2crux Seurat -ro 15

An example of cran2crux generated repository of modules ports can be found [here](https://github.com/slackalaxy/crux-ports/r4-modules).
