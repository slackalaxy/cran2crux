#!/usr/bin/env Rscript

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")

# get RDS path exported from the cran2crux bash script
rds_path <- Sys.getenv("RDS_PATH")

if (RDS_PATH == "") {
  stop("Error: RDS_PATH environment variable is not set!")
}

# set cran repo
#options(repos = c(CRAN = cranrepo.url))

# This must be generated in advance by repos2db.R
old <- readRDS(paste0(rds_path, "old.rds"))

# Report modules with potential updates
show.old <- function(){
  cat("... Checking for updates of installed packages", "\n")
  #old <- as.data.frame(suppressMessages(old.packages(repos = BiocManager::repositories())))
  if (nrow(old) > 0) {
    display <- data.frame(Port = paste0("r4-", tolower(gsub("\\.", "-", old$Package))),
                          Module = old$Package,
                          Installed = old$Installed,
                          ReposVer = old$ReposVer)
    
    return(print(display, row.names = F))
  } else {
    return(cat("All packages are up to date.\n"))
  }
}

show.old()
