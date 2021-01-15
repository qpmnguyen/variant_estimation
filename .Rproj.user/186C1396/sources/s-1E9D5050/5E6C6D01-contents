library(tidyverse)
library(lubridate)
library(zoo)

jhu_cases <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv")
jhu_deaths <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv")

jhu_cases <- jhu_cases %>% select(-c(Lat, Long)) %>% pivot_longer(-c(`Province/State`, `Country/Region`), names_to = "date", values_to = "case_counts") %>% 
    mutate(date = as_date(strptime(date, "%m/%d/%y", tz = "UTC"))) %>% 
    group_by(date, `Country/Region`) %>% summarise(case_counts = sum(case_counts)) %>% 
    rename("country" = "Country/Region") %>% filter(country == "United Kingdom") %>% ungroup() %>%
    mutate(new_cases = case_counts - lag(case_counts, order_by = date)) %>%
    filter(date >= as_date("2020-09-24")) %>% select(date, new_cases)

jhu_deaths <- jhu_deaths %>% select(-c(Lat, Long)) %>% pivot_longer(-c(`Province/State`, `Country/Region`), names_to = "date", values_to = "death_counts") %>% 
    mutate(date = as_date(strptime(date, "%m/%d/%y", tz = "UTC"))) %>% 
    group_by(date, `Country/Region`) %>% summarise(death_counts = sum(death_counts)) %>% 
    rename("country" = "Country/Region") %>% filter(country == "United Kingdom") %>% ungroup() %>%
    mutate(new_deaths = death_counts - lag(death_counts, order_by = date)) %>%
    filter(date >= as_date("2020-09-24")) %>% select(date, new_deaths)

#%>% mutate(wd = floor_date(as_date(date), "week", week_start = 7)) %>%
#    group_by(wd) %>% summarise(avg_cases = mean(new_cases, na.rm = T))


data <- read_csv(file = "https://cog-uk.s3.climb.ac.uk/phylogenetics/latest/cog_metadata.csv")

data <- data %>% separate(sequence_name, c("region", NA, NA)) %>% 
    select(region, sample_date, epi_week, lineage) %>% 
    filter(sample_date >= as_date("2020-10-01")) %>%
    mutate(month = month(sample_date, label = TRUE), week = epi_week, 
           md = floor_date(as_date(sample_date), "month"),
           wd = floor_date(as_date(sample_date), "week", week_start = 7)) %>% 
    dplyr::select(-epi_week)
total_counts <- data %>% group_by(region, sample_date) %>% count()
strain_counts <- data %>% group_by(region, sample_date) %>% 
    summarise(count = sum(lineage == "B.1.1.7", na.rm = TRUE))
counts <- inner_join(strain_counts, total_counts)
counts <- counts %>% rename("strain_detect" = "count", "tot_samples" = "n")
counts <- counts %>% group_by(sample_date) %>% summarise(strain_detect = sum(strain_detect), tot_samples = sum(tot_samples)) %>%
    mutate(prop = strain_detect/tot_samples) %>% rename("date" ="sample_date")
#counts <- counts %>% group_by(wd) %>% summarise(strain_counts = sum(count), tot_samples = sum(n)) %>% 
#    mutate(prop = strain_counts/tot_samples)

jhu <- inner_join(jhu_cases, jhu_deaths)

jhu <- jhu %>% mutate(roll_cases = rollapplyr(new_cases, 7, mean, fill = NA)) %>% 
    mutate(roll_deaths = rollapply(new_deaths, 7, mean, fill = NA)) %>% 
    filter(date >= as_date("2020-10-01"))

proc <- inner_join(counts, jhu)
write_csv(proc, file = "data/processed.csv")
