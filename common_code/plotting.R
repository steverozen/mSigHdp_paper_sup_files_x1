
## This script contains source functions for /indel/code/9_plotting.R and /SBS/code/9_plotting.R 
## This script is not designed to run independently

# Import prerequisites --------------------------------------------------------

require(ggplot2)
require(dplyr)
require(ggbeeswarm)
require(ggpubr)
require(data.table)


# Constants -------------------------------------------------------------------

dot.sym <- 16

# Names of 4 signature extraction measures to be plotted to a Supp Figure
var_names_extr <- c("Composite", "aver_Sim_TP_only", "PPV", "TPR")

# The full names of 4 signature extraction measures.
# To be displayed as y-axis titles.
y_axis_titles_extr <- 
  c("Composite" = "Composite measure",
    "aver_Sim_TP_only" = "Mean cosine similarity",
    "PPV" = "PPV",
    "TPR" = "TPR")

# Function for main text plots ------------------------------------------------

# A plotting function aims for generating ONE panel for main text figures.
#
# It accepts a data frame sliced form all_results.csv as input,
# and a ggplot object contains beeswarm plot for a variable as output.
# 
# The x-axis tick labels are names of PROGRAMS, because the main text
# figure only shows result summaries on data set "Realistic".
#
# The results of different programs are distinguished by point color,
# but no color guide or legend will be printed.
#
# DF - Input data.frame object.
#
# var.name - Name of variable (as a character) to be plotted (y).
# This variable will be plotted against noise level (x)
# and computational approaches (color and shape)
#
# var.title - The title to display on y axis.
#
# inputRange - Range of y axis for variable. Passed to limits argument of
# scale_y_continuous().

main_text_plot <- function(DF, var.name, var.title, inputRange) {
  
  DF1 <- DF[!is.na(DF[[var.name]]),]
  
  ggObj <- ggplot2::ggplot(
    data = DF1,
    mapping = aes_string(x = "Approach",
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
      limits = DF$Approach %>% unique() %>% gtools::mixedsort()) +
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
  ggplot2::labs(x = "Computational Approach",
                y = var.title) +
    # Rotate axis.text.x 60 degrees,
    # move axis.text.x right below the tick marks,
    # and remove legends.
    ggplot2::theme(
      # Change color of background rectangle to white 
      panel.background = ggplot2::element_rect(fill = "white",
                                               color = "black"),
      panel.grid = element_blank(),
      # Remove excessive margins between panels
      panel.spacing = unit(0.25, "lines"),
      axis.text.x = ggplot2::element_text(
        angle = 60,
        # move axis.text.x right below the tick marks
        hjust = 1,
        # font size
        size = 8),
      axis.ticks.x = element_blank(),
      # Make font size of facet label smaller.
      strip.text = ggplot2::element_text(size = 10),
      # remove legends.
      legend.position = "none")
  # Add border lines across different programs
  #
  # If the results are on 3 data sets 
  # (e.g. Noiseless, Moderate, Realistic)
  # then we only need to draw only one line.
  #
  # Similarly, if there are 2/5 data sets,
  # we only need to draw 1/4 lines.
  #
  # Each categorical group corresponds to an
  # INTEGER COORDINATE on the x axis (e.g. 1, 2, ...)
  #
  # Thus the lines should have x-coords:
  # 1.5, 2.5, ...
  num_approaches <- length(unique(DF$Approach))
  if (num_approaches > 1) {
    x_coords <- seq(1.5, num_approaches-0.5, 1)
    ggObj <- ggObj + 
      geom_vline(xintercept = x_coords, 
                 color = "black", 
                 size = 0.2)
  }
  
  return(ggObj)
} # End main_text_plot




# Function for supplementary plots --------------------------------------------

# A plotting function aims for generating ONE panel of supplementary figures.
#
# It accepts a data frame sliced form all_results.csv as input,
# and a ggplot object contains beeswarm plot for a variable as output.
# 
# The x-axis tick labels are names of DATA SETS, because there are 
# results of multiple data sets shown in supp figures.
#
# The results of different programs are distinguished by point color.
# The color guide will be printed on the BOTTOM on the plot.
#
# DF - Input data.frame object.
#
# var.name - Name of variable (as a character) to be plotted (y).
# This variable will be plotted against noise level (x)
# and computational approaches (color and shape)
#
# var.title - The title to display on y axis.
#
# inputRange - Range of y axis for variable. Passed to limits argument of
# scale_y_continuous().

supp_plot <- function(DF, var.name, var.title, inputRange) {
  
  DF1 <- DF[!is.na(DF[[var.name]]),]
  
  ggObj <- ggplot2::ggplot(
    data = DF1,
    mapping = aes_string(x = "Noise_level",
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
      limits = DF$Noise_level %>% unique() %>% gtools::mixedsort()) +
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
  ggplot2::labs(x = "Data set",
                y = var.title,
                color = "Computational Approach:") +
    # Make sure that no more than 3 tools 
    # can be drawn on a line of legend
    ggplot2::guides(
      color = ggplot2::guide_legend(
        nrow = ceiling(length(tool_names)/3), 
        byrow = TRUE)
    ) +
    # Move ggplot2::theme() after ggplot2::guides()
    #
    # This is because the latter function can override the former.
    ggplot2::theme(
      # Change color of background rectangle to white 
      panel.background = ggplot2::element_rect(fill = "white",
                                               color = "black"),
      panel.grid = element_blank(),
      # Remove excessive margins between panels
      panel.spacing = unit(0.25, "lines"),
      axis.ticks.x = element_blank(),
      # Make font size of facet label smaller.
      strip.text = ggplot2::element_text(size = 10),
      # Add legends on the bottom.
      legend.position = "bottom")
  # Add border lines across different data sets
  #
  # If the results are on 3 data sets 
  # (e.g. Noiseless, Moderate, Realistic)
  # then we only need to draw only one line.
  #
  # Similarly, if there are 2/5 data sets,
  # we only need to draw 1/4 lines.
  #
  # Each categorical group corresponds to an
  # INTEGER COORDINATE on the x axis (e.g. 1, 2, ...)
  #
  # Thus the lines should have x-coords:
  # 1.5, 2.5, ...
  num_data_sets <- length(unique(DF$Noise_level))
  if (num_data_sets > 1) {
    x_coords <- seq(1.5, num_data_sets-0.5, 1)
    ggObj <- ggObj + 
      geom_vline(xintercept = x_coords, 
                 color = "black", 
                 size = 0.2)
  }
  
  return(ggObj)
} # End supp_plot

# A function which arranges 4 panels to a single ggplot file ------------------
#
# This function can arrange 4 panels for main text plot, 
# or 4 panels for supplementary plot.
#
# The former is a main figure only contains results on "Realistic" data set,
# the latter is a supp figure contains results on ALL data sets.
#
# DF - Input data.frame object.
#
# file_name - Name of the plotting output file in PDF format.
#
#
# legend_pos - passed to ggpubr::ggarrange() - position of legend.
#
# width_inch, height_inch - passed to ggplot2::ggsave(), 
# canvas size for the output PDF file
#
fig_arr <- function(DF, file_name, 
                    plot_func = main_text_plot,
                    var.names = var_names_extr,
                    axis.titles = y_axis_titles_extr,
                    legend_pos  = "bottom",
                    width_inch = 9,
                    height_inch = 6) {
  
  # c. Plotting of 4 panels, and saving arranged figure 
  # with signature extraction measures
  # on all data sets as a figure.
  figs <- list()
  for(vn in var.names) {
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
    figs[[vn]] <- plot_func(DF, vn, axis.titles[vn], range.vals)
    # For the top two panels, 
    # remove axis.text and axis.title on the x axis.
    #
    # Also remove excessive white spaces between the top two
    # and the lower two panels
    if (vn %in% c("Composite", "aver_Sim_TP_only")) {
      figs[[vn]] <- figs[[vn]] +
        ggplot2::theme(axis.text.x = element_blank(),
                       axis.title.x = element_blank(),
                       axis.ticks.x = element_blank(),
                       plot.margin = unit(c(0.5,0.5,0.5,0.5), "lines"))
    }
  }
  
  # Arrange and save the plot
  #
  # align = "h" guarantees the grid regions (canvas surrounded by 
  # a rectangle) of the 4 facets to have the same height.
  #
  # align = "v" Makes the reference lines of the grid region (canvas region)
  # align together. This guarantees the 4 grid regions to have the same area,
  # despite the number of digits on the y-axis vary.
  arr.figs <- ggpubr::ggarrange(plotlist = figs, 
                                align = "hv",
                                legend = legend_pos,
                                common.legend = T)
  # Temporarily, also add titles to plots to include meta-information:
  #
  arr.figs <- ggpubr::annotate_figure(
    arr.figs, 
    bottom  = text_grob(plot.meta.info, size = 6)
  )
  
  ggplot2::ggsave(
    filename = file_name,
    plot = arr.figs,
    width = unit(width_inch, "inch"),
    height = unit(height_inch, "inch"))
}



# Plot extraction measures -------------------------------------------------
# a. Import results of extraction measures.
file <- paste0(home_for_summary, "/all_results.csv")
DF <- read.csv(file, header = T)


# b. Plotting all extraction accuracy measures to a SUPP figure.
#
# Plot for PPV, TPR, mean Cosine similarity,
# and Composite Measure equals to the sum of
# these 3 measures on ALL data sets.
#
# b1. Data processing
DF$Noise_level[DF$Noise_level == "Noiseless"] <- "None"
# Change Noise_level to ordered factor
factor_levels <- unique(DF$Noise_level)
fac <- factor(DF$Noise_level, ordered = T,
              levels = factor_levels)
DF$Noise_level <- fac
# Change tool names to ordered factor
fac <- factor(DF$Approach, ordered = T,
              levels = tool_names)
DF$Approach <- fac

# b2. Call function fig_arr() to generate supp figure with 4 panels,
#
# here, each panel corresponds to an extraction accuracy measure,
# and measures for different DATA SETS are aligned on the x-axis.
fig_arr(
  DF = DF,
  file_name = paste0(home_for_summary,"/extraction.accuracy.supp.pdf"),
  plot_func = supp_plot
)


# c. Plotting extraction accuracy measures on "Realistic" data set
# to a MAIN figure with 4 panels.
#
# Here, each panel corresponds to an extraction accuracy measure,
# and measures for different PROGRAMS are aligned on the x-axis.
#
# Plot for PPV, TPR, mean Cosine similarity,
# and Composite Measure equals to the sum of
# these 3 measures on "Realistic" data set.
DF_Realistic <- DF %>% dplyr::filter(Noise_level == "Realistic")
fac <- factor(DF_Realistic$Noise_level, ordered = T,
              levels = c("Realistic"))
DF_Realistic$Noise_level <- fac
fig_arr(
  DF = DF_Realistic,
  file_name = paste0(home_for_summary,"/extraction.accuracy.pdf"),
  plot_func = main_text_plot,
  width_inch = 9,
  height_inch = 9,
  legend_pos = "none")
  
  
  

# Plot running time only for Realistic noise level ----------------------------
#
#
# a. Import results of profiling measures.
file <- paste0(home_for_summary, "/cpu_time.csv")
DF_time <- read.csv(file, header = T)


# b. Data pre-processing.
DF_time <- DF_time %>% filter(Noise_level == "Realistic")

# Change tool names to ordered factor
fac <- factor(DF_time$Approach, ordered = T,
              levels = tool_names)
DF_time$Approach <- fac
# Re-arrange DF_time
DF_time <- DF_time %>% arrange(Approach, Noise_level, Run)

# Change storage unit from bytes to MB.
# Change time unit from secs to hours.
DF_time <- DF_time %>% mutate(
  CPU_time = CPU_time / 3600
  #,
  # wall_clock_time = wall_clock_time / 3600,
  # peak_RAM = peak_RAM * 1e-06
)


figs <- list()
var.names <- c("CPU_time")
axis.titles <- c("CPU_time" = "CPU time (hours)")


for(vn in var.names) {
  # Round range of var to 1 decimal place.
  range.vals <- DF_time %>% select(starts_with(vn)) %>% na.omit() %>%
    unlist() %>% range()
  # Maximum values of all measures are more than 100, 
  # thus we round the upper-bound to the nearest hundreds.
  range.vals <- c(0, ceiling(100 * range.vals[2])/100)
  # Generate ggplot object
  figs[[vn]] <- main_text_plot(DF_time, vn, axis.titles[vn], range.vals)
}


# Temporarily, also add titles to plots to include meta-information:
#

ann_fig <- ggpubr::annotate_figure(
  figs$CPU_time, 
  bottom  = text_grob(plot.meta.info, size = 6),
)

ggplot2::ggsave(
  filename = paste0(home_for_summary,"/cpu.profiling.pdf"),
  plot = ann_fig,
  width = unit(6.5, "inch"),
  height = unit(4.5, "inch"))


