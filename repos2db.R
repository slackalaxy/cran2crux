#!/usr/bin/env Rscript

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")

# get RDS path exported from the cran2crux bash script
rds_path <- Sys.getenv("RDS_PATH")

# set cran repo
options(repos = c(CRAN = cranrepo.url))

cat("... Downloading libraries database", "\n")

# check for old
old <- as.data.frame(suppressMessages(old.packages(repos = BiocManager::repositories())))
saveRDS(pkgsdb, paste0(rds_path, "/tmp/old.rds"))

# download all available
pkgsdb <- suppressMessages(available.packages(repos = BiocManager::repositories()))
saveRDS(pkgsdb, paste0(rds_path, "/tmp/pkgsdb.rds"))

cat("... Done! Saved as /tmp/pkgsdb.rds", "\n")
