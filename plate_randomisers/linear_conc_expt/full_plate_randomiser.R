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

row_layout_day_list <- list()

for (day in 1:nrow(allocation)) {

  treatment_vector <- c()

  for (i in 1:length(colnames(allocation))) {
  
    vector_index <- allocation [day, i]
  
    treatment <- colnames(allocation) [i]
  
    treatment_vector [vector_index] <- treatment 
  
  }
  
  rows <- seq(1, 8, by =1)
  
  well_contents <- rep(c(0,2,4,6,8,10), 2)
  
  row_layout <- tibble()
  
  for (row in 1:length(rows)) {
    
    wells_randomised <- sample(well_contents, 12, replace = FALSE)
    
    for (well in 1:length(wells_randomised)) {
      
      row_layout [rows [row], well] <- wells_randomised [well]
      
    }
    
  }
  
  colnames(row_layout) <- seq(1, 12, by = 1)
  
  rownames(row_layout) <- treatment_vector
  
  row_layout_day_list [[day]] <- row_layout

}

day_1 <- row_layout_day_list [[1]]

day_2 <- row_layout_day_list [[2]]

day_3 <- row_layout_day_list [[3]]

day_4 <- row_layout_day_list [[4]]

day_5 <- row_layout_day_list [[5]]