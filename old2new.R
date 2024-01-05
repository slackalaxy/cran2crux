#!/usr/bin/env Rscript

# Report modules with potential updates
show.old <- function(){
  old <- as.data.frame(old.packages())
  #row.names(old) <- NULL
  display <- data.frame(Module = old$Package,
                        Installed = old$Installed,
                        ReposVer = old$ReposVer,
                        Port = paste0("r4-", tolower(gsub("\\.", "-", old$Package))))
  
  return(display)
}

# show old
print(show.old(), row.names = F)
