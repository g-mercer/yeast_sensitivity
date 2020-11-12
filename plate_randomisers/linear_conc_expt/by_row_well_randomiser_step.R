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

rownames(row_layout) <- seq(1:8)

# rownames(row_layout) <- c("A","B","C", "D","E", "F", "G", "H")
