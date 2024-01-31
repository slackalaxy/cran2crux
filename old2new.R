#!/usr/bin/env Rscript

# get cranrepo and maintainer information
source("/etc/cran2crux.conf")

# set cran repo
options(repos = c(CRAN = cranrepo.url))

# Report modules with potential updates
show.old <- function(){
  if (!is.null(old.packages())) {
    old <- as.data.frame(suppressMessages(old.packages(repos = BiocManager::repositories())))
    display <- data.frame(Port = paste0("r4-", tolower(gsub("\\.", "-", old$Package))),
                          Module = old$Package,
                          Installed = old$Installed,
                          ReposVer = old$ReposVer,
                          Repository = old$Repository)
    
    return(print(display, row.names = F))
  }else{
    return(cat("All packages are up to date.\n"))
  }
  
}

show.old()
