#!/usr/bin/env Rscript

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")

# set cran repo
#options(repos = c(CRAN = cranrepo.url))

# input arguments order
args <- commandArgs(trailingOnly = TRUE)
rds_path <- args[1]

# This must be generated in advance by repos2db.R
old <- readRDS(paste0(rds_path, "old.rds"))

# Upstream repo better name
upstream <- function(up = NULL){
  
  upstream <- unlist(strsplit(up, "\\/"))[3]
  
  if(upstream == "cloud.r-project.org"){
    u <- "CRAN"
  }else if(upstream == "bioconductor.org"){
    u <- "BioC"
  } else {
    u <- "UNKNOWN"
  }
  return(u)
}

# Report modules with potential updates
show.old <- function(){
  #cat("... Checking for updates of installed packages", "\n")
  #old <- as.data.frame(suppressMessages(old.packages(repos = BiocManager::repositories())))
  if (nrow(old) > 0) {
    display <- data.frame(Port = paste0("r4-", tolower(gsub("\\.", "-", old$Package))),
                          Module = old$Package,
                          Installed = old$Installed,
                          ReposVer = old$ReposVer,
                          Repositoty = upstream(old$Repository))
    
    return(print(display, row.names = F))
  } else {
    return(cat("All packages are up to date.\n"))
  }
}

show.old()
