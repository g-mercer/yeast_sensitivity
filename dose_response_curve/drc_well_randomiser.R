concentrations <- c(0.0001, 0.001, 0.01, 0.1, 1)

rows <- 1:3

days <- 1:7 

day_layout <- list()

for (k in 1:length(days)) {
  
plate_layout <- matrix(0, nrow = 3, ncol = 5)

  for (i in 1:length(rows)) {
  
    concs_randomised <- sample(concentrations, 5, replace = FALSE)
  
    plate_layout [i, ] <- concs_randomised
  
  }

day_layout [[k]] <- plate_layout

} 

for (i in 1:length(day_layout)) {
  
  path <- paste0("day_", i, "_key.csv", sep = "")
  
  write.csv(day_layout[[i]], file = path, row.names = FALSE)
  
}


