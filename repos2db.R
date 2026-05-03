#!/usr/bin/env Rscript

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")

# set cran repo
options(repos = c(CRAN = cranrepo.url))

# input arguments order
args <- commandArgs(trailingOnly = TRUE)
rds_path <- args[1]

cat("... Downloading libraries database", "\n")

# check for old
old <- as.data.frame(suppressMessages(old.packages(repos = BiocManager::repositories())))
saveRDS(pkgsdb, paste0(rds_path, "old.rds"))

# download all available
pkgsdb <- suppressMessages(available.packages(repos = BiocManager::repositories()))
saveRDS(pkgsdb, paste0(rds_path, "pkgsdb.rds"))

cat("... Done! Saved as /tmp/pkgsdb.rds", "\n")
