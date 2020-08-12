one_graph_combined <- function(time_cond_OD, y_label) {
  
  one_graph <- ggplot(data = time_cond_OD, aes(x=time, y=OD)) + 
    geom_line(aes(colour=condition), alpha=0.4) +
    ggtitle("") +
    xlab(expression(Time)) +
    ylab(y_label) +
    theme(panel.background = element_rect(fill = "white"), plot.margin = margin(1, 1, 1, 1, "cm"),
          axis.line = element_line(), plot.background = element_rect(
            fill = "grey90",
            colour = "black",
            size = 1
          )
    )
  
  one_graph
  
}

y_label <- "ln(OD[t]/OD[0])"

treatments_on_one_graph <- one_graph_combined(meanOD_all_treatments_divt0, y_label)

treatments_on_one_graph