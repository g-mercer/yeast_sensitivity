wells <- data.frame(  
  letter  = rep(c("b", "c", "d", "e", "f", "g"), each = 10), 
                       number = rep(2:11, times = 6))
wells

# for the insecticide plots rotate clockwise for each replicate
wells$insecticides <- rep(c("sulfoxaflor", "control", "blank", "thiacloprid", "acetamiprid", "imidacloprid", "flupyradifurone", "clothianidin", "malathion", "chlorpyrifos", "cypermethrin", "tefluthrin"), each = 5)

concentrations <- c(0.001, 0.01, 0.1, 1, 5)

concentrations_for_table <- c()
for (i in 1:12) {
  concentrations_for_table <- append( concentrations_for_table, 
                                     sample( concentrations, size = 5))
}

wells$concentrations <- concentrations_for_table

wells

