#!/usr/bin/env Rscript

# Copyright (c) 2023 Petar Petrov, slackalaxy at gmail dot com
#   
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")

# set cran repo
options(repos = c(CRAN = cranrepo.url))

# input arguments order
args <- commandArgs(trailingOnly = TRUE)
module <- args[1]
cliopt <- args[2]
depth <- args[3]

# load the available packages database
#pkgsdb <- available.packages()
#biocdb <- available.packages(repos = BiocManager::repositories())
pkgsdb <- suppressMessages(available.packages(repos = BiocManager::repositories()))

# is a package on CRAN or BioC?
on.cran <- function(x) {
  result <- try(pkgsdb[x, "Package"], silent = T)
  if (inherits(result, 'try-error')) {
    cat(x, "is not on CRAN or BioC Skipping...", "\n")
    return(NULL)
  }
  return(result)
}

# stop already if input does not exist
if (is.null(on.cran(module))) {
  stop()
}

# leave only deps available on CRAN
cran.available <- function(x){
  y <- c()
  for (i in x) {
    j <- on.cran(i)
    y <- c(y, j)
  }
  return(y)
}

# prepare deps
names.only <- function(x){
  x <- gsub("[\r\n]", " ", x)
  x <- gsub(",", ", ", x)
  x <- strsplit(x, ", ")

  # remove within brackets
  y <- c()
  for (i in x[[1]]) {
    i <- gsub(" ", "", as.character(i))
    j <- gsub("\\s*\\([^\\)]+\\)","",as.character(i))
    y <- c(y, j)
  }
  
  # in case deps are just comma-separated (depa,depb)
  y <- strsplit(y, ",")
  return(y)
}

# Depends on
depends.on <- function(package = NULL,
                       pkgs.db = NULL){
  
  depends <- names.only(pkgs.db[package, "Depends"])
  imports <- names.only(pkgs.db[package, "Imports"])
  linking <- names.only(pkgs.db[package, "LinkingTo"])
  
  dependencies <- c(depends, imports, linking)
  y <- sort(unique(cran.available(dependencies)))
  
  return(y)
}

# Optional
optional <- function(package = NULL,
                     pkgs.db = NULL){

  optional <- names.only(pkgs.db[package, "Suggests"])
  y <- sort(cran.available(optional))
  
  return(y)
}

# This is able to retrieve deps of multiple packages
depsofdeps <- function(modules = NULL, pkgsdb = NULL, opts = NULL){
  deep <- c(modules)
  for (i in deep) {
    d <- depends.on(i, pkgsdb)
    if (isTRUE(opts)) {
      o <- optional(i, pkgsdb)
      d <- unique(c(d, o))
    }
    deep <- c(deep, d)
    deep <- sort(unique(deep))
  }
  return(deep)
}

# This runs depsofdeps recursively with a number of iterations, deep resolving deps
# TODO: make this more intelligent to stop automatically when all deps are resolved.
deepdeps <- function(package = NULL,
                     pkgs.db = NULL,
                     iterations = 5,
                     opts = NULL){
  
  # start with just the one
  deep <- depsofdeps(package, pkgsdb)
  
  for (n in 1:iterations) {
    deep <- depsofdeps(deep, pkgsdb = pkgsdb, opts)
    nam <- paste0("deep.", n)
    assign(nam, deep)
    deep <- depsofdeps(deep, pkgsdb = pkgsdb, opts)
  }
  return(deep)
}

# prepare for "Depends on" or "Optional" rows in the Pkgfile
pkgfile.style <- function(x){
  y <- c()
  for (i in x) {
    j <- paste0("r4-", tolower(i))
    y <- c(y, j)
  }
  return(y)
}

# try to get the url right
get.url <- function(x){
  if (x == paste0(bioc.url, bioc.version, "/bioc/src/contrib") |
      x == paste0(bioc.url, bioc.version, "/data/annotation/src/contrib") |
      x == paste0(bioc.url, bioc.version, "/data/experiment/src/contrib") |
      x == paste0(bioc.url, bioc.version, "/workflows/src/contrib") |
      x == paste0(bioc.url, bioc.version, "/books/src/contrib")) {
    module.url <- "https://bioconductor.org/packages/"
  }else{
    module.url <- "https://cran.r-project.org/web/packages/"
  }
  return(module.url)
}

# Write the Pkgfile
pkgfile.write <- function(module = NULL){
  
  maintainer <- maintainer.info
  
  # Preserve upper case, as well as original version format of the module
  modules.dep <- depends.on(module, pkgsdb)
  modules.opt <- optional(module, pkgsdb)
  modules.ver <- pkgsdb[module, "Version"]
  
  # polish for Pkgfile's fields
  pkgfile.dsc <- paste("R module", module)
  pkgfile.url <- paste0(get.url(pkgsdb[module, "Repository"]), module)
  pkgfile.mnt <- maintainer
  pkgfile.dep <- gsub(",", "", gsub("\\.", "-", toString(pkgfile.style(modules.dep))))
  pkgfile.opt <- gsub(",", "", gsub("\\.", "-", toString(pkgfile.style(modules.opt))))
  pkgfile.nam <- paste0("r4-", tolower(gsub("\\.", "-", module)))
  pkgfile.ver <- gsub("-", "\\.", modules.ver)
  
  if (modules.ver == pkgfile.ver) {
    modules.ver <- "${version}"
  }
  
  pkgfile.rel <- "1"
  pkgfile.src <- paste0(pkgsdb[module, "Repository"], "/", module, "_", modules.ver, ".tar.gz")
  
  pkgfile <- paste0("# Description: ", pkgfile.dsc, "\n",
                    "# URL: ", pkgfile.url, "\n",
                    "# Maintainer: ", pkgfile.mnt, "\n",
                    "# Depends on: r ", pkgfile.dep, "\n",
                    "# Optional: ", pkgfile.opt, "\n",
                    "\n",
                    "name=", pkgfile.nam, "\n",
                    "version=", pkgfile.ver, "\n",
                    "release=", pkgfile.rel, "\n",
                    "source=", "(", pkgfile.src, ")", "\n",
                    "\n",
                    "build() {", "\n",
                    "\t", "cd ", module, "\n",
                    "\t", "mkdir -p $PKG/usr/lib/R/library", "\n",
                    "\t", "R CMD INSTALL . -l $PKG/usr/lib/R/library", "\n",
                    "}")
  
  dir.create(pkgfile.nam)
  write(pkgfile, paste0(pkgfile.nam, "/", "Pkgfile"))
  cat("=======> Created port for", module, "in:", paste0(pkgfile.nam), "\n")
  #return(pkgfile)
}

# write the ports
if (cliopt == "-r" | cliopt == "--recursive") {
  modules.all <- deepdeps(module, pkgsdb, depth, opts = FALSE)
  for (d in modules.all){
    pkgfile.write(d)
  }
}else if(cliopt == "-ro" | cliopt == "--recursive-opt") {
  modules.all <- deepdeps(module, pkgsdb, depth, opts = TRUE)
  for (d in modules.all){
    pkgfile.write(d)
 }
}else{
  pkgfile.write(module)
}
