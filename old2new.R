#!/usr/bin/env Rscript

# input arguments order
args <- commandArgs(trailingOnly = TRUE)
rds_path <- args[1]
conf_file <- args[2]

# get cranrepo and maintainer information; don't hard code it
source(paste0(conf_file))

# This must be generated in advance by repos2db.R
old <- readRDS(paste0(rds_path, "old.rds"))

# Upstream repo better name
upstream <- function(up = NULL){
  l <- c()
  for (i in 1:length(old$Repository)) {
    upstream <- strsplit(old$Repository[i], "\\/")[[1]][[3]]
    if(upstream == "cloud.r-project.org"){
      u <- "CRAN"
    }else if(upstream == "bioconductor.org"){
      u <- "BioC"
    } else {
      u <- "UNKNOWN"
    }
    l <- c(l, u)
  }
  return(l)
}

# Report modules with potential updates
show.old <- function(){
  if (nrow(old) > 0) {
    display <- data.frame(Port = paste0("r4-", tolower(gsub("\\.", "-", old$Package))),
                          R_package = old$Package,
                          Installed = old$Installed,
                          ReposVer = old$ReposVer,
                          Repositoty = upstream(old$Repository))
    
    return(print(display, row.names = F))
  } else {
    return(cat("All packages are up to date.\n"))
  }
}

show.old()
