#!/usr/bin/env Rscript

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")
pkgsdb <- suppressMessages(available.packages(repos = BiocManager::repositories()))
saveRDS(pkgsdb, "/tmp/pkgsdb.rds")
