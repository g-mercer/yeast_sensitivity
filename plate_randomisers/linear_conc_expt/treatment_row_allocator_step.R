library(tidyverse)

allocation <- matrix(0, nrow = 5, ncol = 8)

for (row in 1:nrow(allocation)) {
  
  repeatchecker <- 1
  
  while (repeatchecker != 0) {
    
    repeatchecker <- 0
    
    well_row_positions <- sample(1:8)
    
    for (i in 1:length(well_row_positions)) {
      
      if (well_row_positions[i] %in% allocation[,i]) {
        
        repeatchecker <- repeatchecker + 1
      }
    }
  }
  
  allocation[row,] <- well_row_positions
  
}

treatments <- c("control", "solvent", "thiacloprid", "acetamiprid", "imidacloprid", 
                "clothianidin", "flupyradifurone", "blank")

colnames(allocation) <- treatments

allocation