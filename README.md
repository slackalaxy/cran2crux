# cran2crux: write CRUX ports for R-packages
[![Badge](https://img.shields.io/badge/Origin-Slackalaxy-green)](https://github.com/slackalaxy/cran2crux)
[![Badge](https://img.shields.io/badge/Preprint-bioRxiv-red)](https://www.biorxiv.org/)

## Description
The cran2crux script automatically generates [CRUX](https://crux.nu/) port(s) for [R](https://www.r-project.org/)-packages available from [CRAN](https://cran.r-project.org/) and [BioConductor](https://bioconductor.org/). Simply running `cran2crux Foo` will produce a port named `r4-foo`. Any dots in the name are replaced by a dashes (e.g. foo.bar - > foo-bar) and any dashes in the version are replaced by dots (e.g. 1-2-3 -> 1.2.3). The tool creates its output in the current work directory, which must be **empty**.  

## Installation
cran2crux depends on R and [BiocManager](https://cran.r-project.org/web/packages/BiocManager/vignettes/BiocManager.html). I provide ports for [r4-biocmanager](https://github.com/slackalaxy/crux-ports/tree/main/r4/r4-biocmanager) and [cran2crux](https://github.com/slackalaxy/crux-ports/tree/main/r4/cran2crux). Or just do:

    httpup sync https://raw.githubusercontent.com/slackalaxy/crux-ports/main/r4/#r4-biocmanager r4-biocmanager
    httpup sync https://raw.githubusercontent.com/slackalaxy/crux-ports/main/r4/#cran2crux cran2crux

Note that if you want to just try cran2crux, you can run it **without installation**, directly from its downloaded and unarchived folder (see below "Example"), as long as you have BiocManager installed.

## Configuration
You should modify `/etc/cran2crux.conf` to fill in the maintainer line, specify a [CRAN mirror](https://cran.r-project.org/mirrors.html), and adjust the BioConductor version. The R syntax is used, therefore settings look like this:
```R
maintainer.info <- c("Petar Petrov, slackalaxy at gmail dot com")
cranrepo.url <- "https://cloud.r-project.org"
bioc.version <- "3.23"
```
## Quick start
* `cran2crux Foo`: Create a port for R-package "Foo"
* `cran2crux Foo -r`: Create ports for "Foo" and it's dependencies recursively
* `cran2crux Foo -ro 10`: Create ports for "Foo", it's dependencies and optional dependencies, recursively. The number (10) indicates the dependencies iterations search depth.  If none is provided, the default of 5 iterations is used. You will typically need to increase it when generating ports for optional dependencies.
* `cran2crux -so`: Show potential updates of installer R-packages
* `cran2crux -u`: Generate ports for installed R-packages  for which a newer version is available from upstream.

## Dependencies listed in the port
cran2crux adds dependencies information from CRAN to the port, as follows:
* `# Depends on:` `r` itself, followed by R packages, listed in the **Depends**, **Imports**, and **LinkingTo** fields.
* `# Optional:` R packages listed in the **Suggests** field.

Some dependencies are already inbuild in R, such as `methods` from **Depends**, while others listed as **SystemRequirements** lie outside the R ecosystem and cran2crux is not meant to deal with them. It is up to the ports maintainer to find (by `finddeps`?) and add them to the port afterwards.

## Example
Create a new empty directory to call cran2crux there:
```BASH
mkdir rports
cd rports 
```
Let's create a port for the [Seurat](https://cran.r-project.org/web/packages/Seurat/) R-package that provides a set of tools for single cell genomics ([Satija lab](https://satijalab.org/seurat/)). The following will create a single port, called `r4-seurat`:

```BASH
# for local download of cran2crux (no installation)
bash '/path/to/cran2crux' Seurat

# for system-wide installed cran2crux
cran2crux Seurat
```

This is the port:
```BASH
# Description: R-package Seurat
# URL: https://cran.r-project.org/web/packages/Seurat
# Maintainer: Petar Petrov, slackalaxy at gmail dot com
# Depends on: r r4-cluster r4-cowplot r4-fastdummies r4-fitdistrplus r4-future r4-future-apply r4-generics r4-ggplot2 r4-ggrepel r4-ggridges r4-httr r4-ica r4-igraph r4-irlba r4-jsonlite r4-kernsmooth r4-lifecycle r4-lmtest r4-mass r4-matrix r4-matrixstats r4-miniui r4-patchwork r4-pbapply r4-plotly r4-png r4-progressr r4-rann r4-rcolorbrewer r4-rcpp r4-rcppannoy r4-rcppeigen r4-rcpphnsw r4-rcppprogress r4-reticulate r4-rlang r4-rocr r4-rspectra r4-rtsne r4-scales r4-scattermore r4-sctransform r4-seuratobject r4-shiny r4-spatstat-explore r4-spatstat-geom r4-tibble r4-uwot
# Optional: r4-ape r4-arrow r4-base64enc r4-biobase r4-biocgenerics r4-data-table r4-delayedarray r4-deseq2 r4-enrichr r4-genomeinfodb r4-genomicranges r4-ggrastr r4-glmgampoi r4-harmony r4-hdf5r r4-iranges r4-leidenbase r4-limma r4-magrittr r4-mast r4-metap r4-mixtools r4-monocle r4-r-utils r4-rfast2 r4-rsvd r4-rtracklayer r4-s4vectors r4-sf r4-singlecellexperiment r4-sp r4-summarizedexperiment r4-testthat r4-vgam

name=r4-seurat
version=5.5.0
release=1
source=(https://cloud.r-project.org/src/contrib/Seurat_${version}.tar.gz)

build() {
	cd Seurat
	mkdir -p $PKG/usr/lib/R/library
	R CMD INSTALL . -l $PKG/usr/lib/R/library
}
```
Although the dependencies rows are automatically filled, the corresponding ports are *not* created. Adding the `-r` option will create ports for `Seurat` and what it depends on, recursively:
```BASH
cran2crux Seurat -r
```
Parsing `-ro` will do as above, including what's *optional*. We set the `depth` value to 15, as this requires more searches (WARNING: this is quite time-consuming):
```BASH
cran2crux Seurat -ro 15
```
To check which of the installed ports have a newer version upstream:
```BASH
cran2crux -so
```
The output reports the port, R-package name, versions differences, as well as the repository:
```
          Port  R_package Installed ReposVer Repositoty
 r4-assorthead assorthead     1.6.0    1.6.1       BioC
      r4-cpp11      cpp11     0.5.4    0.5.5       CRAN
 r4-data-table data.table  1.18.2.1   1.18.4       CRAN
      r4-limma      limma    3.68.0   3.68.2       BioC
   r4-nanonext   nanonext     1.8.2    1.9.0       CRAN
```
This will create updated ports for the five R-packages above:
```BASH
cran2crux -u
```
## r4 repository
My repository of ports for R-packages can be found [here](https://github.com/slackalaxy/crux-ports/tree/main/r4).

## TODO
Include information about system requirements.

## Links
* [R project](https://www.r-project.org/)
* [The Comprehensive R Archive Network](https://cran.r-project.org/)
* [CRAN Mirrors](https://cran.r-project.org/mirrors.html)
* [BioConductor](https://bioconductor.org/)
* [R package Guidelines at Arch Linux wiki](https://wiki.archlinux.org/title/R_package_guidelines)

![img](./cran2crux.png)
