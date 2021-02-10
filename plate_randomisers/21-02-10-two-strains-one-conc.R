# create treatments 
treatments <- c("thiacloprid", "acetamiprid", "imidacloprid", "flupyradifurone", "clothianidin", "malathion", 
                "chlorpyrifos", "tefluthrin", "control-neg", "control-pos", "control-no-solv")

# create number of days
days <- seq(1:10)

# create empty list
plate_layouts_by_day <- list()

for (day in 1:length(days)) {
  
  # create empty matrix
  plate_layout <- matrix(0, nrow = 6, ncol = 11)
  
  colnames(plate_layout) <- seq(1:11)
  
  # each day swap the strain rows
  if (day %% 2) rownames(plate_layout) <- rep(c("BY", "PD"), each = 3) else rownames(plate_layout) <- rep(c("PD", "BY"), each = 3)
  
  # randomly assign wells a treatment for each row
  for (row in 1:nrow(plate_layout)) {
  
    treatments_randomised <- sample(treatments, 11, replace = FALSE)
  
    plate_layout [row, ] <- treatments_randomised
  
  } 
  
  plate_layouts_by_day [[day]] <- plate_layout
  
}

list_names <- c()

# label list by day
for (i in seq(1:10)) {
  
  day_name <- paste0("day", i)
  
  list_names [i] <- day_name
  
}

names(plate_layouts_by_day) <- list_names

day_10 <- plate_layouts_by_day [[10]]