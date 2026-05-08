#!/usr/bin/env Rscript

# input arguments order
args <- commandArgs(trailingOnly = TRUE)
rds_path <- args[1]
conf_file <- args[2]

# get cranrepo and maintainer information
#source("/etc/cran2crux.conf")
source(conf_file)

# set cran repo
options(repos = c(CRAN = cranrepo.url))

cat("... SYNC > CRAN and Bioconductor", "\n")

# check for old
old <- as.data.frame(suppressMessages(old.packages(repos = BiocManager::repositories())))
saveRDS(old, paste0(rds_path, "old.rds"))

# download all available
pkgsdb <- suppressMessages(available.packages(repos = BiocManager::repositories()))
saveRDS(pkgsdb, paste0(rds_path, "pkgsdb.rds"))

cat("... DONE > Saved to", rds_path, "\n")
