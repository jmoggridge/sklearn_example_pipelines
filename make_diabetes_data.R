library(tidyverse)
library(tidymodels)


diabetes <- read_csv('data-diabetes/diabetes_raw.csv')
glimpse(diabetes)

recip <- recipe(positive ~ ., data = diabetes) %>% 
  step_interact( ~ all_predictors()^2, id = 'interactions') %>% 
  step_poly(preg:age, degree = 2, options = list(raw=TRUE),
            id = 'quadratics') %>%
  step_normalize(all_predictors(), id = 'center+scaled') %>% 
  prep()

diabetes_extra <- juice(recip) %>% 
  relocate(cols = contains('poly_1'), .before = positive) %>% 
  rename_with( ~ str_remove(.x, '_poly_1'), cols = contains('poly_1')) %>% 
  rename_with( ~ str_replace(.x, '_poly_2', '_2'), cols = contains('poly_2')) %>% 
  relocate(-positive)

glimpse(diabetes_extra)

write_csv(diabetes_extra, './data-diabetes/diabetes_extra.csv')
