#!/usr/bin/env Rscript
library("tools")
library("pkgsearch")

pkg.maintainer <- "Petar Petrov, slackalaxy at gmail dot com"

args <- commandArgs(trailingOnly = TRUE)
pkg <- args[1]

pkg <- "MDEI"
print(pkg)

chooseCRANmirror(graphics = F, ind = 71)

pkg.name <- cran_package(pkg.name)$Package
pkg.depends <- package_dependencies(packages = pkg.name)
pkg.description <- cran_package(pkg.name)$Title
#pkg.url <- cran_package(pkg)
pkg.version <- cran_package(pkg.name)$Version
pkg.source <- paste0("https://cran.r-project.org/src/contrib/", pkg.name, "_", pkg.version, ".tar.gz")

print(pkg.name)
print(pkg.description)
print(pkg.depends)
print(pkg.url)
print(pkg.version)
print(pkg.source)

dep <- c()
for (d in pkg.depends) {
  dep <- c(dep, d)
}
dep <- toString(tolower(dep))
dep

description <- paste0("# Description: ", pkg.description)
url <- paste0("# URL: ")
maintainer <- paste0("# Maintainer: ", pkg.maintainer)
depends_on <- paste0("# Depends on: ", gsub(',','', dep))
name <- paste0("name=", tolower(pkg.name))
ver <- paste0("version=", pkg.version)
release <- paste0("release=", 1)
souce <- paste0("source=", "(", pkg.source, ")")
souce


####### resolve deps

pack <- available.packages()
dp <- pack["Seurat","Depends"]
im <- pack["Seurat", "Imports"]
lt <- pack["Seurat", "LinkingTo"]

c(dp, im, lt)

sg <- pack["Seurat", "Suggests"]




im <- pack["Seurat", "Imports"]
im <- gsub("[\r\n]", " ", im)
im <- strsplit(im, ", ")
im

imp <- c()
for (i in im[[1]]) {
  j <- gsub("\\s*\\([^\\)]+\\)","",as.character(i))
  imp <- c(imp, j)
}


gsub("\\s*\\([^\\)]+\\)","",as.character(im))

################################################################################
# Load the available packages database
#pkgs.db <- available.packages()

module <- "Seurat"

# remove anything with or within brackets
names.only <- function(x){
  x <- gsub("[\r\n]", " ", x)
  x <- strsplit(x, ", ")

  y <- c()
  for (i in x[[1]]) {
    j <- gsub("\\s*\\([^\\)]+\\)","",as.character(i))
    y <- c(y, j)
  }
  
  return(y)
}

# Depends on
depends.on <- function(package = NULL,
                       pkgs.db = NULL){
  
  depends <- names.only(pkgs.db[package, "Depends"])
  imports <- names.only(pkgs.db[package, "Imports"])
  linking <- names.only(pkgs.db[package, "LinkingTo"])
  
  do <- c(depends, imports, linking)
  
  return(do)
}

# Optional
optional <- function(package = NULL,
                     pkgs.db = NULL){

  optional <- names.only(pkgs.db[package, "Suggests"])
  
  return(optional)
}

# deal with inbuilt packages (skip)
skip.inbuild <- function(x) {
  result <- try(available.packages()[x, "Package"], silent = T)
  if (inherits(result, 'try-error')) {
    cat("Skipping", x, "\n")
    return(NULL)
  }
  return(result)
}

# leave only deps available on CRAN
cran.available <- function(x){
  y <- c()
  for (i in x) {
    j <- skip.inbuild(i)
    y <- c(y, j)
  }
  return(y)
}


# prepare for "Depends on" and "Optional" rows in the Pkgfile
pkgfile.style <- function(x){
  y <- c()
  for (i in x) {
    j <- paste0("r-", tolower(i))
    y <- c(y, j)
  }
  return(y)
}



maintainer <- c("Petar Petrov, slackalaxy at gmail dot com")

# Preserve upper case, as well as original version format of the module
modules.dep <- depends.on(module, available.packages())
modules.opt <- optional(module, available.packages())
modules.ver <- available.packages()[module, "Version"]

# polish for Pkgfile's fields
pkgfile.dsc <- paste("R module", module)
pkgfile.url <- paste0("https://cran.r-project.org/web/packages/", module)
pkgfile.mnt <- maintainer
pkgfile.dep <- gsub("\\.", "-", toString(pkgfile.style(modules.dep)))
pkgfile.opt <- gsub("\\.", "-", toString(pkgfile.style(modules.opt)))
pkgfile.nam <- paste0("r-", tolower(gsub("\\.", "-", module)))
pkgfile.ver <- gsub("-", "\\.", modules.ver)

if (modules.ver == modules.ver) {
  modules.ver <- "${version}"
}



pkgfile.rel <- "1"
pkgfile.src <- paste0(available.packages()[module, "Repository"], "/", module, "_", modules.ver, ".tar.gz")

pkgfile <- paste0("# Description: ", pkgfile.dsc, "\n",
                  "# URL: ", pkgfile.url, "\n",
                  "# Maintainer: ", pkgfile.mnt, "\n",
                  "# Depends on: ", pkgfile.dep, "\n",
                  "# Optional: ", pkgfile.opt, "\n",
                  "\n",
                  "name=", pkgfile.nam, "\n",
                  "version=", pkgfile.ver, "\n",
                  "release=", pkgfile.rel, "\n",
                  "source=", "(", pkgfile.src, ")", "\n",
                  "\n",
                  "build=() {", "\n",
                  "\t", "cd ", module, "\n",
                  "\t", "mkdir -p $PKG/usr/lib/R/library", "\n",
                  "\t", "R CMD INSTALL . -l $PKG/usr/lib/R/library", "\n",
                  "}")

dir.create(pkgfile.nam)
write(pkgfile, paste0(pkgfile.nam, "/", "Pkgfile"))
