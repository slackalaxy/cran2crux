# cran2crux: write CRUX ports for R modules from CRAN

## Description
The `cran2crux` script automatically generates port(s) for R modules available from [CRAN](https://cran.r-project.org/). The script
creates its output in the current directory: running `cran2crux Module` will produce a port named `r4-module` with release number set to 1. If the port already exists, `cran2crux` will overwrite it (!), so it is advisable to run it in an empty directory.

A port is available at [ppetrov/cran2crux](https://github.com/slackalaxy/crux-ports/tree/main/ppetrov/cran2crux). An example of a `cran2crux` generated repository can be found at [r4-modules](https://github.com/slackalaxy/crux-ports/tree/main/r4-modules).

## Configuration
You should modify `/etc/cran2crux.conf` to set a maintainer line and a [CRAN mirror](https://cran.r-project.org/mirrors.html). The `R` syntax is used, therefore settings look like this:
```R
maintainer.info <- c("Petar Petrov, slackalaxy at gmail dot com")
cranrepo.url <- "https://cloud.r-project.org"
```
## Options
* **Dependencies**
  * `-r`, `--recursive`: create ports for `Module`, its dependencies and their own dependencies, recursively.  
  * `-ro`, `--recursive-opt`: create port for `Module`, its dependencies, optional dependencies and their own dependencies recursively. This may require to set *dependencies depth* to a higher number (see below).  
* **Dependencies depth**. A positive integer, *after* the `-r` or `-ro` option. This defines how many iterations of dependencies searches will be performed. Set to a higher value (>10) if you expect the list is large. If none is provided, the default of 5 iterations is used.

## Dependencies listed in the port
`cran2crux` aims to add dependencies information from CRAN to the port, as follows:
* `# Depends on:` `r` itself, followed by R packages, listed in the **Depends**, **Imports**, and **LinkingTo** fields.
* `# Optional:` R packages listed in the **Suggests** field.

Some modules are already inbuild in R, such as `methods` from **Depends**, while others from the **Suggests** list may be available from elsewhere (e.g. [BioConductor](https://bioconductor.org/)). These cannot be retrieved from CRAN and are omitted from the port. Packages listed as **SystemRequirements** lie outside the R ecosystem and `cran2crux` is not meant to deal with them. It is up to the ports maintainer to find (by `finddeps`?) and add them to the port afterwards.

## Example usage
Create a new empty directory to call `cran2crux` there:
```BASH
mkdir r4-modules
cd r4-modules 
```
As an example, let's create a port for the [Seurat](https://cran.r-project.org/web/packages/Seurat/) module that provides a set of tools for single cell genomics ([Satija lab](https://satijalab.org/seurat/)). The following will create a single port, called `r4-seurat`:

    cran2crux Seurat

This is the port:
```BASH
# Description: R module Seurat
# URL: https://cran.r-project.org/web/packages/Seurat
# Maintainer: Petar Petrov, slackalaxy at gmail dot com
# Depends on: r r4-cluster r4-cowplot r4-fastdummies r4-fitdistrplus r4-future r4-future-apply r4-generics r4-ggplot2 r4-ggrepel r4-ggridges r4-httr r4-ica r4-igraph r4-irlba r4-jsonlite r4-kernsmooth r4-leiden r4-lifecycle r4-lmtest r4-mass r4-matrix r4-matrixstats r4-miniui r4-patchwork r4-pbapply r4-plotly r4-png r4-progressr r4-purrr r4-rann r4-rcolorbrewer r4-rcpp r4-rcppannoy r4-rcppeigen r4-rcpphnsw r4-rcppprogress r4-reticulate r4-rlang r4-rocr r4-rspectra r4-rtsne r4-scales r4-scattermore r4-sctransform r4-seuratobject r4-shiny r4-spatstat-explore r4-spatstat-geom r4-tibble r4-uwot
# Optional: r4-ape r4-data-table r4-enrichr r4-ggrastr r4-harmony r4-hdf5r r4-metap r4-mixtools r4-r-utils r4-rfast2 r4-rsvd r4-testthat r4-vgam

name=r4-seurat
version=5.0.1
release=1
source=(https://cran.rstudio.com/src/contrib/Seurat_${version}.tar.gz)

build() {
	cd Seurat
	mkdir -p $PKG/usr/lib/R/library
	R CMD INSTALL . -l $PKG/usr/lib/R/library
}
```
Although the dependencies rows are automatically filled, the corresponding ports are *not* created. Adding the `-r` option will create ports for `Seurat` and what it depends on, recursively:

    cran2crux Seurat -r
	
Parsing `-ro` will do as above, including what's *optional*. We set the `depth` value to 15, as this requires more searches:

	cran2crux Seurat -ro 15

## TODO
Extend `cran2crux` to work with [BioConductor](https://bioconductor.org/), as well.

## Links
* [R project](https://www.r-project.org/)
* [The Comprehensive R Archive Network](https://cran.r-project.org/)
* [CRAN Mirrors](https://cran.r-project.org/mirrors.html)
* [BioConductor](https://bioconductor.org/)
* [R package Guidelines at Arch Linux wiki](https://wiki.archlinux.org/title/R_package_guidelines)
