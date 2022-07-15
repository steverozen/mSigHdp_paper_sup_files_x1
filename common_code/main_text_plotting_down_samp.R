
##This script contains source functions for /indel/code/9_plotting.R and /SBS/code/9_plotting.R 
##This script is not designed to run independently
require(ggplot2)
require(dplyr)
require(ggbeeswarm)
require(ggpubr)
require(data.table)


dot.sym <- 16

# A plotting function which accepts a data frame sliced
# form all_results.csv as input,
# and a ggplot object contains beeswarm plot for a variable as output.
#
# DF - Input data.frame object.
#
# var.name - Name of variable (as a character) to be plotted (y).
# This variable will be plotted against down-sampling threshold (x)
# and computational approaches (color and shape)
#
# var.title - The title to display on y axis.
#
# inputRange - Range of y axis for variable. Passed to limits argument of
# scale_y_continuous().

main_text_plot <- function(DF, var.name, var.title, inputRange){
  
  DF1 <- DF[!is.na(DF[[var.name]]),]
  
  ggObj <- ggplot2::ggplot(
    data = DF1,
    mapping = aes_string(x = "Down_samp_level",
                         y = var.name)) +
    # Add a dot plot
    # Dot plot is a better visualization
    # compared to boxplot or violin plot,
    # as there are only 20 points in each group
    ggbeeswarm::geom_beeswarm(
      mapping = aes(
        # Run from different computational approach
        # to have different color
        color = as.factor(Approach)),
      
      shape = dot.sym,
      # Keep the original size of dots.
      size = 1,
      # Make dots in each aesthetic group
      # dodge from one another.
      # dodge.width equals to the distance between
      # the leftmost and the rightmost point
      # in each group / the distance between two group
      # tick marks.
      dodge.width = 0.6,
      # The jitter is on the X axis rather than on
      # Y axis.
      # This can keep the value of composite measure.
      groupOnX = T) +
    # Order the groups by variable "ordered.names".
    ggplot2::scale_x_discrete(
      limits = DF$Down_samp_level %>% unique() %>% gtools::mixedsort()) +
    # Change the range for different scatterplots to be the same.
    ggplot2::scale_y_continuous(
      labels = function(x) format(x, scientific = FALSE),
      limits = inputRange) +
    # Scale color
    ggplot2::scale_color_brewer(palette = "Set2") +
    #ggplot2::scale_color_hue(h = c(180, 300)) +
    # Scale color by viridis
    #viridis::scale_color_viridis(
    #  # Forward direction
    #  direction = 1,
    #  # Alpha transparency
    #  # 1: atransparent
    #  alpha = 1,
    #  # Preventing the two extremities
    #  begin = 0.1,
    #  end = 0.9,
  #  discrete = T,
  #  # Palette version
  #  option = "H") +
  # Change axis and legend titles
  ggplot2::labs(x = "Threshold for down-sampling",
                y = var.title,
                color = "Computational Approach:") +
    # Rotate axis.text.x 90 degrees,
    # move axis.text.x right below the tick marks,
    # and remove legends.
    ggplot2::theme(
      # Change color of background rectangle to white 
      panel.background = ggplot2::element_rect(fill = "white",
                                               color = "black"),
      panel.grid = element_blank(),
      axis.text.x = ggplot2::element_text(
        # angle = 30,
        # move axis.text.x right below the tick marks
        # hjust = 1,vjust = 1
      ),
      axis.ticks.x = element_blank(),
      # Make font size of facet label smaller.
      strip.text = ggplot2::element_text(size = 10),
      # remove legends.
      legend.position = "top")  +
    # Add border lines across different data sets
    geom_vline(xintercept = c(1.5, 2.5), 
               color = "black", 
               size = 0.2)
  
  return(ggObj)
} # End main_text_plot



# Plot extraction measures -------------------------------------------------

# a. Import results of extraction measures.
file <- paste0(home_for_summary, "/all_results.csv")
DF <- read.csv(file, header = T)


# b. Data pre-processing.
#
# Plot for PPV, TPR, mean Cosine similarity,
# and Composite Measure equals to the sum of
# these 3 measures.
# Calculate composite measure
DF <- DF %>% mutate(Composite = PPV + TPR + aver_Sim_TP_only)

# Change Down_samp_level to ordered factor
fac <- factor(DF$Down_samp_level, ordered = T,
              levels = dataset_names)
DF$Down_samp_level <- fac


# Change tool names to ordered factor
fac <- factor(DF$Approach, ordered = T,
              levels = c("mSigHdp", "SigProfilerExtractor"))
DF$Approach <- fac


# c. Plotting of 4 panels, and saving arranged plot.
#
# Plot 4 panels to Figure 1
var.names <- c("aver_Sim_TP_only","PPV","TPR")
axis.titles <- c("Composite" = "Composite measure",
                 "aver_Sim_TP_only" = "Mean cosine similarity",
                 "PPV" = "PPV",
                 "TPR" = "TPR")

figs <- list()
for(vn in c("Composite", var.names)){
  # Round range of to 1 decimal place.
  range.vals <- DF %>% select(all_of(vn)) %>%
    unlist() %>% range()
  if (vn != "aver_Sim_TP_only") {
    range.vals <-
      c(floor(10 * range.vals[1])/10, ceiling(10 * range.vals[2])/10)
  } else {
    range.vals <-
      c(floor(100 * range.vals[1])/100, ceiling(100 * range.vals[2])/100)
  }
  # Generate ggplot object
  figs[[vn]] <- main_text_plot(DF, vn, axis.titles[vn], range.vals)
  # For the first and second panel,
  # remove axis.text and axis.title
  # on the x axis.
  if (vn %in% c("Composite", "aver_Sim_TP_only")) {
    figs[[vn]] <- figs[[vn]] +
      ggplot2::theme(axis.text.x = element_blank(),
                     #axis.ticks.x = element_blank(),
                     axis.title.x = element_blank())
  }
}

# Arrange and save the plot
arr.figs <- ggpubr::ggarrange(plotlist = figs, common.legend = T)
# Temporarily, also add titles to plots to include meta-information:
#
arr.figs <- ggpubr::annotate_figure(
  arr.figs, 
  bottom  = text_grob(plot.meta.info, size = 6),
)

ggplot2::ggsave(
  filename = paste0(home_for_summary,"/extraction.accuracy.pdf"),
  plot = arr.figs,
  width = unit(9, "inch"),
  height = unit(6, "inch"))


# Temporarily disabled
if (FALSE) {
  # Plot running time only all down-sampling thresholds ---------------------
  #
  #
  # a. Import results of profiling measures.
  file <- paste0(home_for_summary, "/cpu_time.csv")
  DF <- read.csv(file,header = T)
  
  
  # b. Data pre-processing.
  DF <- DF %>% filter(Down_samp_level == "Realistic")
  
  # Change tool names to ordered factor
  fac <- factor(DF$Approach, ordered = T,
                levels = c("mSigHdp", "SigProfilerExtractor",
                           "SignatureAnalyzer", "signeR"))
  DF$Approach <- fac
  # Re-arrange DF
  DF <- DF %>% arrange(Approach,Down_samp_level,Run)
  
  # Change storage unit from bytes to MB.
  # Change time unit from secs to hours.
  DF <- DF %>% mutate(
    CPU_time = CPU_time / 3600
    #,
    # wall_clock_time = wall_clock_time / 3600,
    # peak_RAM = peak_RAM * 1e-06
  )
  
  
  figs <- list()
  var.names <- c("CPU_time")
  axis.titles <- c("CPU_time" = "CPU time (hours)")
  
  
  for(vn in var.names){
    
    # Round range of var to 1 decimal place.
    range.vals <- DF %>% select(starts_with(vn)) %>% na.omit() %>%
      unlist() %>% range()
    # Maximum values of all measures are more than 100, 
    # thus we round the upper-bound to the nearest hundreds.
    range.vals <- c(0, ceiling(100 * range.vals[2])/100)
    # Generate ggplot object
    figs[[vn]] <- main_text_plot(DF, vn, axis.titles[vn], range.vals)
  }
  
  # Arrange 4 panels into one ggplot object.
  arr.figs <- ggpubr::ggarrange(plotlist = figs, common.legend = T)
  # Temporarily, also add titles to plots to include meta-information:
  #
  
  arr.figs <- ggpubr::annotate_figure(
    arr.figs, 
    bottom  = text_grob(plot.meta.info, size = 6),
  )
  
  ggplot2::ggsave(
    filename = paste0(home_for_summary,"/cpu.profiling.pdf"),
    plot = arr.figs,
    width = unit(6.5, "inch"),
    height = unit(4.5, "inch"))
}

