
library(tidyverse)
library(magrittr)
library(data.table) # Pre %like% operátor
library(caret) # Pre confusionMatrix
library(pROC)

getwd()
setwd("/Users/danielcok/xcok/4.semester/OZNAL/Zadanie") # Set the correct path to players_22.csv
data <- read_delim("NHL_Players_Statistics.csv", col_names = TRUE, num_threads = 4, delim = ';');
data
view(data)

colnames(data) # Pôvodné mená stĺpcov

new_colnames <- c("player_name", "date_of_birth", "season_year", "season", "team", "games_played", "goals", "assists", "points", "plus_minus_ratings", "penalty_minutes",
                  "shots_on_goal", "shooting_percentage", "power_play_goals", "power_play_assists", "short_goals", "short_assists", "game_winning_goals", "game_tying_goals",
                  "time_on_ice_per_game", "production", "number", "games_started", "wins", "losses", "ties", "overtime_losses", "goals_against", "goals_against_average", "shots_against", "saves",
                  "save_percentage", "shutouts", "position", "height", "weight", "bmi", "place_of_birth", "age", "experience")

colnames(data) <- new_colnames

colnames(data) # Nové mená stĺpcov

data %<>% separate("date_of_birth", into = c("Year", "Month", "Day"), sep = "-")



data %<>% separate("place_of_birth", into = c("city", "state"), sep = ",")

son <- gsub("'", "", data$season) # Funkcia gsub funguje podobne ako sub ale nahradí všetky výskyty

data$game_tying_goals[is.na(data$game_tying_goals)] <- 0
data$number[is.na(data$number)] <- 0

unique(data$position)

data %<>% mutate(
  role = case_when(
    position %like% "Right_wing|Left_wing|Center|Forward" ~ "offensive",
    position %like% "Defence" ~ "defensive",
    position %like% "Goaltender" ~ "goalie",
    .default = "goalie"
  )
)

view(data)

selected_data <- data %>% select(goals, shots_on_goal, shooting_percentage, power_play_goals, time_on_ice_per_game)
plot(selected_data)

filtered_data <- data %>% filter(role == "offensive")

sample <- sample(c(TRUE, FALSE), nrow(filtered_data), replace=TRUE, prob=c(0.7,0.3))
train <- filtered_data[sample, ]
test <- filtered_data[!sample, ]

# TODO: Popisat interpretaciu modelu, vypocitat RMSE atd. interpretovat, pouzit testovacie data, roc krivka
model <- lm(goals ~ shots_on_goal + shooting_percentage + power_play_goals, data = train)
summary(model)

# Vypočítať mediány pre štatistiky
median_goals <- median(data$goals, na.rm = TRUE)
median_assists <- median(data$assists, na.rm = TRUE)
median_points <- median(data$points, na.rm = TRUE)

# Vytvoriť binárnu cieľovú premennú 'Above_Average'
data <- data %>%
  mutate(Above_Average = ifelse(goals > median_goals & assists > median_assists & points > median_points, 1, 0))


# Najprv odstrániť riadky s chýbajúcimi hodnotami v stĺpci 'Above_Average'
data <- data %>% filter(!is.na(Above_Average))

# Rozdeliť dáta na trénovacie a testovacie množiny
set.seed(123)  # Nastaviť seed pre reprodukovateľnosť
training_index <- createDataPartition(data$Above_Average, p = 0.7, list = FALSE)
training_data <- data[training_index, ]
testing_data <- data[-training_index, ]

# Skontrolujte rozsah cieľovej premennej 'goals'
summary(training_data$goals)

# Môžete zvážiť obmedzenie rozsahu dát, ak sú extrémne hodnoty
# Napríklad, odstráňte extrémne hodnoty - tu je iba ilustratívny príklad, ako by to mohlo vyzerať
# Toto NIE JE bežná prax, iba pokus o vyriešenie upozornenia
quantiles <- quantile(training_data$goals, probs = c(0.05, 0.95))
training_data_reduced <- training_data %>% 
  filter(goals >= quantiles[1], goals <= quantiles[2])

# Fit the logistic regression model on the reduced data
simplified_model <- glm(Above_Average ~ goals, data = training_data_reduced, family = "binomial")

# Check for warnings after fitting the model
summary(simplified_model)

# Make predictions on the testing set, applying the same reduction to 'goals'
testing_data_reduced <- testing_data %>% 
  filter(goals >= quantiles[1], goals <= quantiles[2])

predictions <- predict(model, newdata = testing_data, type = "response")

# Convert predictions to binary class labels using the cutoff
predicted_classes <- ifelse(predictions > 0.5, 1, 0)

# Assuming that you have already checked and ensured that 'testing_data$Above_Average' exists
# Convert both actual and predicted classes to factors with explicit levels
testing_data$Above_Average <- factor(testing_data$Above_Average, levels = c("0", "1"))
predicted_classes <- factor(predicted_classes, levels = c("0", "1"))

# Now create the confusion matrix
conf_matrix <- confusionMatrix(predicted_classes, testing_data$Above_Average, positive = "1")
print(conf_matrix)



# Vypočítajte pravdepodobnosti pomocou modelu 
predicted_probabilities <- predict(simplified_model, newdata = testing_data_reduced, type = "response")

# Vytvorte ROC krivku
roc_curve <- roc(testing_data_reduced$Above_Average, predicted_probabilities)

# Vykreslenie ROC krivky
plot(roc_curve, main = "ROC Curve", col = "#1c61b6")
# Pridanie diagonálnej čiary predstavujúcej "náhodný výkon"
abline(0, 1, lty = 2, col = "red")

# Vypočet AUC
auc_value <- auc(roc_curve)
# Vytlačenie hodnoty AUC
print(auc_value)
