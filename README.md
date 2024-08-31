# cran2crux: write CRUX ports for R modules from CRAN

## Description
The cran2crux script automatically generates [CRUX](https://crux.nu/) port(s) for [R](https://www.r-project.org/) modules available from [CRAN](https://cran.r-project.org/) and [BioConductor](https://bioconductor.org/). Running `cran2crux Module` will produce a port named `r4-module`. Any dots in the name are replaced by a dashes and any dashes in the version are replaced by dots. The tool creates its output in the current directory; if the port already exists, cran2crux will overwrite it (!), so it is advisable to run it in an empty directory. 

![img](./cran2crux.png)

## Installation
cran2crux depends on R and [BiocManager](https://cran.r-project.org/web/packages/BiocManager/vignettes/BiocManager.html). I provide ports for [r4-biocmanager](https://github.com/slackalaxy/crux-ports/tree/main/r4-modules/r4-biocmanager) and [cran2crux](https://github.com/slackalaxy/crux-ports/tree/main/r4-modules/cran2crux). Or just do:

    httpup sync https://raw.githubusercontent.com/slackalaxy/crux-ports/main/r4-modules/#r4-biocmanager r4-biocmanager
    httpup sync https://raw.githubusercontent.com/slackalaxy/crux-ports/main/r4-modules/#cran2crux cran2crux


## Configuration
You should modify `/etc/cran2crux.conf` to fill in the maintainer line, specify a [CRAN mirror](https://cran.r-project.org/mirrors.html), and adjust the BioConductor version. The R syntax is used, therefore settings look like this:
```R
maintainer.info <- c("Petar Petrov, slackalaxy at gmail dot com")
cranrepo.url <- "https://cloud.r-project.org"
bioc.version <- "3.18"
```
## Options
* **Dependencies and dependencies depth**
  * `-r`, `--recursive`: create ports for `Module`, its dependencies and their own dependencies, recursively.  
  * `-ro`, `--recursive-opt`: create port for `Module`, its dependencies, optional dependencies and their own dependencies recursively. This may require to set *dependencies depth* to a higher number (see below).  
    * **Dependencies depth**. A positive integer, *after* the `-r` or `-ro` option. This defines how many iterations of dependencies searches will be performed. Set to a higher value (>10) if you expect the list is large. If none is provided, the default of 5 iterations is used. You will typically need this when generating ports for optional dependencies.
* **Updates**
  * `-so`, `--show-old`: check with CRAN or BioConductor for updates of modules that are already installed.
  * `-u`, `--update`: generate fresh ports for installed modules for which a newer version is available from upstream.

## Dependencies listed in the port
cran2crux adds dependencies information from CRAN to the port, as follows:
* `# Depends on:` `r` itself, followed by R packages, listed in the **Depends**, **Imports**, and **LinkingTo** fields.
* `# Optional:` R packages listed in the **Suggests** field.

Some modules are already inbuild in R, such as `methods` from **Depends**, while others listed as **SystemRequirements** lie outside the R ecosystem and cran2crux is not meant to deal with them. It is up to the ports maintainer to find (by `finddeps`?) and add them to the port afterwards.

## Example usage
Create a new empty directory to call cran2crux there:
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

To check which of the installed modules have a newer version upstream:

    cran2crux -so

The output reports the modules, versions differences, as well as the ports that build them:
```
       Module Installed ReposVer            Port
       future    1.33.0   1.33.1       r4-future
 future.apply    1.11.0   1.11.1 r4-future-apply
         mgcv     1.9-0    1.9-1         r4-mgcv
    segmented     2.0-0    2.0-1    r4-segmented
```
This will create updated ports for the four modules above:

    cran2crux -u

## r4-modules repository
My repository of ports for CRAN modules can be found [here](https://github.com/slackalaxy/crux-ports/tree/main/r4-modules).

## TODO
* Code cleanups.
* Make cran2crux skip making a port if it is already present in `pwd`.
* Expand the r4-modules repo and submit to portdb.

## Links
* [R project](https://www.r-project.org/)
* [The Comprehensive R Archive Network](https://cran.r-project.org/)
* [CRAN Mirrors](https://cran.r-project.org/mirrors.html)
* [BioConductor](https://bioconductor.org/)
* [R package Guidelines at Arch Linux wiki](https://wiki.archlinux.org/title/R_package_guidelines)
