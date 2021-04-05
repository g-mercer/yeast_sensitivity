setwd(dir = "~/Documents/phd/DEG_yeast_insecticide_expt/dose_response_curve/drc_2/")

concentrations <- c(0.01, 0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 1)

rows <- 1:7

columns <- 1:10

days <- 1:2 

day_layout <- list()

for (k in 1:length(days)) {
  
  plate_layout <- matrix(0, nrow = 8, ncol = 10)

  for (i in 1:length(columns)) {
    
    concs_randomised <- sample(concentrations, 8, replace = FALSE)
    
    plate_layout [, i] <- concs_randomised
    
  }
  
  day_layout [[k]] <- plate_layout
  
} 

for (i in 1:length(day_layout)) {
  
  colnames(day_layout [[i]]) <- seq(1:10)
  rownames (day_layout [[i]]) <- letters[seq( from = 1, to = 8 )]
  
}


for (i in 1:length(day_layout)) {
  
  path <- paste0("day_", i, "_key.csv", sep = "")
  
  write.csv(day_layout[[i]], file = path, row.names = TRUE)
  
}

