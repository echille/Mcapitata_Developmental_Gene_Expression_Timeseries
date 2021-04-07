### Table output for daily measurements summary
library(plyr)
library(dplyr)
library(Rmisc)
library(FSA)

data <- read.csv("Sample_Info/SWChem/Daily_Temp_pH_Sal.csv") %>%
  subset(Treatment == "Ambient") %>% na.omit()
data$Date <- as.character(data$Date)

data <- data %>%
  #dplyr::group_by(Date) %>% 
  mutate(Temp.M = mean(Temperature),
         Temp.SE = se(Temperature),
         pH.M = mean(pH.MV),
         pH.SE = se(pH.MV),
         Sal.M = mean(Salinity),
         Sal.SE = se(Salinity)) %>%
  select(Date, Temp.M, Temp.SE, pH.M, pH.SE, Sal.M, Sal.SE) %>% distinct() %>%
  subset(Date == "20180613" | Date == "20180614" | Date == "20180615" | Date == "20180622")

print(data)

summary <- data.frame(Temp.M = mean(data$Temperature),
                         Temp.SE = se(data$Temperature),
                         pH.M = mean(data$pH.MV),
                         pH.SE = se(data$pH.MV),
                         Sal.M = mean(data$Salinity),
                         Sal.SE = se(data$Salinity))
