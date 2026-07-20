# cran2crux: write CRUX ports for R-packages
[![Badge](https://img.shields.io/badge/Origin-Slackalaxy-green)](https://github.com/slackalaxy/cran2crux)
[![Badge](https://img.shields.io/badge/Preprint-bioRxiv-red)](https://www.biorxiv.org/content/10.64898/2026.05.09.723963)
[![CRAN](https://img.shields.io/badge/CRAN-blue?logo=r&logoColor=white)](https://cran.r-project.org/)
[![Bioconductor](https://img.shields.io/badge/Bioconductor-9B5DE5?logo=bioconductor&logoColor=white)](https://bioconductor.org/)
[![CRUX](https://img.shields.io/badge/Linux-CRUX-orange)](https://crux.nu/)
[![r4 Ports](https://img.shields.io/badge/Ports-r4-orange)](https://crux.nu/portdb/?a=repo&q=r4)

## Description
`cran2crux` automatically generates [CRUX](https://crux.nu/) port(s) for [R](https://www.r-project.org/)-packages available from [CRAN](https://cran.r-project.org/) and [Bioconductor](https://bioconductor.org/). It also supports recursive dependency resolution and potential updates check.

## Requirements
* BASH
* R
* BiocManager

## Usage at-a-glance
```sh
# Single R-package
cran2crux Seurat

# R-package + dependencies (recursive)
cran2crux Seurat -r

# R-package + dependencies + optional dependencies (deeper recursion)
cran2crux Seurat -ro 15

# Check for updates
cran2crux -so

# Generate updated ports for outdated R-packages
cran2crux -u
```

## Run without installing
```r
# In R, install BiocManager:
install.packages("BiocManager")
```
Quick example:
```sh
# Get cran2crux and navigate to an empty directory
git clone https://github.com/izzilab/cran2crux
cd cran2crux
mkdir rports
cd rports

# Generate a port for Seurat and dependencies
bash ../cran2crux Seurat -r
```

## Installation on CRUX
R is available in *contrib*, so make sure you have the repository enabled ([Point 5.7.2 in the Handbook](https://crux.nu/Main/Handbook3-8#ntoc44)). Ports for [r4-biocmanager](https://github.com/slackalaxy/crux-ports/tree/main/r4/r4-biocmanager) and [cran2crux](https://github.com/slackalaxy/crux-ports/tree/main/r4/cran2crux) are available in the [r4](https://crux.nu/portdb/?a=search&q=r4) repository:
```sh
prt-get depinst r

httpup sync https://raw.githubusercontent.com/slackalaxy/crux-ports/main/r4/#r4-biocmanager r4-biocmanager
cd r4-biocmanager
pkgmk -i

httpup sync https://raw.githubusercontent.com/slackalaxy/crux-ports/main/r4/#cran2crux cran2crux
cd cran2crux
pkgmk -i
```

## Configuration
Once installed, modify `/etc/cran2crux.conf` to set your maintainer information. Also, you may specify a different [CRAN mirror](https://cran.r-project.org/mirrors.html) (if desired), and adjust the Bioconductor version (if needed). The file uses R syntax:
```r
maintainer.info <- c("Firstname Lastname, firstname.lastname at email dot com")
cranrepo.url <- "https://cloud.r-project.org"
bioc.version <- "3.23"
```

## Generated Ports

**Naming and version handling**  
Ports are automatically named with an `r4-` prefix, all letters in lowercase, and dots replaced by dashes. Dashes in the upstream version are replaced by dots. Examples:
- R-package: `SeuratObject` → Port: `r4-seuratobject`
- Version: `1.2-3` → Port: `1.2.3`

**Inserting dependencies information**  
Metadata from CRAN/Bioconductor is added, as follows:

* `# Depends on:` `r` followed by packages listed in *Depends*, *Imports*, and *LinkingTo*.
* `# Optional:` packages listed in *Suggests*.

Built-in R packages (e.g. `methods`, `utils`) are omitted. **Note**: `cran2crux` does not handle system-level dependencies from the *SystemRequirements* field, since they are outside the R ecosystem. You will need to add them manually using `finddeps`.

## Example
The tool creates its output in the current working directory, which **must be empty**:
```sh
mkdir rports
cd rports
```

Let's create a port for the [Seurat](https://cran.r-project.org/web/packages/Seurat/) R-package that provides a set of tools for single cell genomics ([Satija lab](https://satijalab.org/seurat/)). The following will create a single port, called `r4-seurat`:

```sh
cran2crux Seurat
```

This is the generated port:
```sh
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
Although the dependencies rows are automatically filled, the corresponding ports are *not* created. Adding the `-r` (`--recursive`) option will create ports for `Seurat` and what it depends on, recursively (make sure working directory is **empty**):
```sh
cran2crux Seurat -r
```
Processing Seurat and its dependencies recursively yields a total of 142 ports in about 11 seconds on an Intel i7-9700KF @3.6GHz, as reported by `time` (see Table 1, Benchmarks). Parsing `-ro` (`--recursive-opt`) will do as above, including what's optional. We set the `depth` value to 15 (default is 5, but here we want deeper recursion), as this requires more searches (WARNING: this is quite time-consuming):
```sh
cran2crux Seurat -ro 15
```
To check which of the installed ports have a newer version upstream, pass the `-so` (`--show-old`) option:
```sh
cran2crux -so
```
The output reports the port, R-package name, versions differences, as well as the repository:
```
          Port  R_package Installed ReposVer Repository
 r4-assorthead assorthead     1.6.0    1.6.1       BioC
      r4-cpp11      cpp11     0.5.4    0.5.5       CRAN
 r4-data-table data.table  1.18.2.1   1.18.4       CRAN
      r4-limma      limma    3.68.0   3.68.2       BioC
   r4-nanonext   nanonext     1.8.2    1.9.0       CRAN
```
This will create updated ports for the five R-packages above, by simply passing `-u` (`--update`):
```sh
cran2crux -u
```
## r4: ports repository for R packages
A ports repository for R-packages can be found [here](https://github.com/slackalaxy/crux-ports/tree/main/r4).

## Benchmarks
|condition|time (s)|run 1|run 2|run 3|mean|stdev
-|-|-|-|-|-|-
default|real|10.599|10.656|10.298|10.518|0.192
default|user|8.833|8.598|8.719|8.717|0.118
default|sys|0.801|0.853|0.805|0.820|0.029
|||||
depth 2|real|7.105|7.197|7.248|7.183|0.072
depth 2|user|5.717|5.837|5.757|5.770|0.061
depth 2|sys|0.482|0.457|0.453|0.464|0.016
|||||
no download|real|6.728|6.665|6.694|6.696|0.032
no download|user|5.965|5.905|5.896|5.922|0.038
no download|sys|0.765|0.762|0.800|0.776|0.021
|||||
no download, depth 2|real|3.468|3.446|3.440|3.451|0.015
no download, depth 2|user|3.059|3.050|3.069|3.059|0.010
no download, depth 2|sys|0.410|0.399|0.373|0.394|0.019

> **Table 1. Performance of cran2crux.** Generating Seurat and dependencies ports was timed in 3 independent runs, under the following conditions: *default* (sync with upstream + depth 5 of recursive dependencies searches), *depth 2* (sync with upstream + depth 2 of recursive dependencies searches), *no download* (upstream pre-synced + depth 5 of recursive dependencies searches), *no download, depth 2* (upstream pre-synced + depth 2 of recursive dependencies searches). Time of each run (1-3) is given in seconds: *real* (total elapsed time), *user* (time in user-space code) and *sys* (time in kernel/system calls). Mean and stdev values were calculated in Gnumeric 

## TODO
Include information about system requirements.

## Links
* [R project](https://www.r-project.org/)
* [The Comprehensive R Archive Network](https://cran.r-project.org/)
* [CRAN Mirrors](https://cran.r-project.org/mirrors.html)
* [Bioconductor](https://bioconductor.org/)
* [CRUX](https://crux.nu/)
* [R package Guidelines at Arch Linux wiki](https://wiki.archlinux.org/title/R_package_guidelines)

![img](./cran2crux.png)
