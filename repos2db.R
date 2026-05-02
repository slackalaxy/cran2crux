#!/usr/bin/env Rscript

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")
cat("... Downloading libraries database", "\n")
pkgsdb <- suppressMessages(available.packages(repos = BiocManager::repositories()))
saveRDS(pkgsdb, "/tmp/pkgsdb.rds")
cat("... Done! Saved as /tmp/pkgsdb.rds", "\n")
