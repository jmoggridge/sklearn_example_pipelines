library(tidyverse)
abalone <- read_csv("./results/kfold_abalone.csv", skip = 1L) %>% 
  mutate(data = "Abalone")

cancer <- read_csv("./results/kfold_cancer.csv") %>% 
  mutate(data = "Cancer")

diabetes <- read_csv("./results/kfold_diabetes.csv") %>% 
  mutate(data = "Diabetes")

# combine all data to work with
df <- bind_rows(abalone, cancer, diabetes) %>%
  mutate(algorithm = ifelse(algorithm== "Logistic regression", 
                            "LogReg", algorithm)) %>% 
  pivot_longer(precision:f1, names_to = 'metric', values_to = 'value')
rm(abalone, cancer, diabetes)

# compute performance metric means for each (algorithm, dataset) pair
summary_df <- df %>% 
  group_by(algorithm, data, metric) %>% 
  summarize(values = list(value),
            mean = mean(value), 
            sd = sd(value))
# view(summary_df)

paired_t_test <- function(x,y) 
  t.test(as.vector(x), as.vector(y), paired=T)

# pivot data such that each row has (data, metric, values_SVC, values_LogReg)
pairs_df <- summary_df %>% 
  mutate(id = row_number()) %>% 
  pivot_wider(id_cols = c(data, metric), 
              names_from = algorithm, 
              values_from = c(values, mean, sd)) %>% 
  # do a paired t-test for each dataset & metric
  mutate(t_test = map2(values_LogReg, values_SVC, paired_t_test)) %>% 
  mutate(p_value = map_dbl(t_test, "p.value"),
         mean_diff = map_dbl(t_test, "estimate")) %>% 
  select(everything(), t_test, -contains("values_"))

# none are significant
pairs_df %>% 
  select(data, metric, contains('LogReg'), contains('SVC'), p_value) %>% 
  pander::pander()


library(ggbeeswarm)
ggplot() +
 geom_quasirandom(data=df, aes(x = algorithm, y = value), 
                               width = 0.15,
                               color = 'gray', method = 'quasirandom') +
  geom_point(data=summary_df, aes(x = algorithm, y = mean),
             color = 'red', alpha = 0.76) +
  facet_grid(metric~data) +
  theme_bw()
  
summary_df


df %>% 
  group_by(algorithm, data, metric) %>% 
  summarise()