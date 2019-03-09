# Set working directory
setwd("~/Documents/Data/R Studio Files/Gender Pay Gap")

# Ensure the following libraries are installed: dbplyr, magrittr, tidyr, plotly, ggplot2, ggalt
library("magrittr")
library(dplyr)
library(tidyr)
library(plotly)
packageVersion('plotly')
library(ggplot2)
library(ggalt)

# Read, then view, in the 2017-2018 gender pay gap data that's been downloaded from https://gender-pay-gap.service.gov.uk/viewing/download
lastyear <- read.csv("UK Gender Pay Gap Data - 2017 to 2018.csv", header = TRUE, sep = ",")
View(lastyear)

# Create a subset of the data containing only the following columns: CurrentName, MaleBonusPercent, FemaleBonusPercent
lastyearbonus <- select(lastyear, MaleBonusPercent, FemaleBonusPercent, CurrentName)
View(lastyearbonus)

# Add a new column containing the female bonus minus the male bonus
lastyearbonus$diff <- lastyearbonus$FemaleBonusPercent - lastyearbonus$MaleBonusPercent

# Sort the bonus data so that the worst performers are at the top and copy the top 50 into a new data set containing the 50 worst companies (from  female perspective)
lastyearbonus <- lastyearbonus[order(lastyearbonus$diff),]
worstByBonus <- lastyearbonus[1:50,]
View(worstByBonus)

# order factor levels by men's bonus (plot_ly() will pick up on this ordering)
#  Does this make the sorting done above redundant?
worstByBonus$CurrentName <- factor(worstByBonus$CurrentName, levels = worstByBonus$CurrentName[order(worstByBonus$MaleBonusPercent)])

# Create a dumbbell chart using plotly
p <- plot_ly(worstByBonus, color = I("gray80")) %>%
  add_segments(x = ~FemaleBonusPercent, xend = ~MaleBonusPercent, y = ~CurrentName, yend = ~CurrentName, showlegend = FALSE) %>%
  add_markers(x = ~FemaleBonusPercent, y = ~CurrentName, name = "Women", color = I("#ef2f7c")) %>%
  add_markers(x = ~MaleBonusPercent, y = ~CurrentName, name = "Men", color = I("#39c8e5")) %>%
  layout(
    title = "UK Gender Bonus Disparity (2017-2018) - Worst 50 Companies From a Female Perspective",
    xaxis = list(title = "Percentage of Gender That Received a Bonus"),
    yaxis = list(title = ""),
    margin = list(l = 65)
  )

p

# Create the same dumbbell chart using ggplot. This version is the basic black and white chart.
ggplot(worstByBonus, aes(y=CurrentName, x=FemaleBonusPercent, xend=MaleBonusPercent)) + geom_dumbbell()

# Create the same dumbbell chart as in the line above but set the size and colours of the points.
ggplot(worstByBonus, aes(y=CurrentName, x=FemaleBonusPercent, xend=MaleBonusPercent)) +
  geom_dumbbell(color="grey", size=1, colour_x="#ef2f7c", colour_xend = "#39c8e5") +
  ggtitle("UK Gender Bonus Disparity (2017-2018) - Top 50 Worst Companies From a Female Perspective") +
  theme(axis.title.y=element_text(size=9)) + ylab("") + xlab("% of Gender Receiving a Bonus") 

