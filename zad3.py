import pandas as pd
import numpy as np
from pgmpy.models import BayesianModel
from pgmpy.estimators import MaximumLikelihoodEstimator

data = pd.read_csv('/Users/danielcok/xcok/4.semester/OZNAL/Zadanie/NHL_Players_Statistics.csv', delimiter=';')

print("Columns from CSV:", data.columns.tolist())

data.rename(columns={
    'Name': 'name',
    'Date_of_birth': 'date_of_birth',
    'SEASON_year': 'season_year',
    'SEASON': 'season',
    'TEAM': 'team',
    'Games_Played': 'games_played',
    'Goals': 'goals',
    'Assists': 'assists',
    'Points': 'points',
    'PlusMinus_Ratings': 'plus_minus_ratings',
    'Penalty_Minutes': 'penalty_minutes',
    'Shots_on_Goal': 'shots_on_goal',
    'Shooting_Percentage': 'shooting_percentage',
    'PowerPlay_Goals': 'power_play_goals',
    'PowerPlay_Assists': 'power_play_assists',
    'Short_Goals': 'short_goals',
    'Short_Assists': 'short_assists',
    'Game_Winning_Goals': 'game_winning_goals',
    'Game_Tying_Goals': 'game_tying_goals',
    'Time_on_Ice_per_Game': 'time_on_ice_per_game',
    'Production': 'production',
    'Number': 'number',
    'Games_Started': 'games_started',
    'Wins': 'wins',
    'Losses': 'losses',
    'Ties': 'ties',
    'Overtime_Losses': 'overtime_losses',
    'Goals_Against': 'goals_against',
    'Goals_Against_Average': 'goals_against_average',
    'Shots_Against': 'shots_against',
    'Saves': 'saves',
    'Save_Percentage': 'save_percentage',
    'Shutouts': 'shutouts',
    'Position': 'position',
    'Height': 'height',
    'Weight': 'weight',
    'Body_mass_index': 'bmi',
    'Place_of_birth': 'place_of_birth',
    'Age': 'age',
    'Experience': 'experience'
}, inplace=True)

data['role'] = np.where(data['position'].str.contains('Right_wing|Left_wing|Center|Forward'), 'offensive', 'defensive')

data['shooter_type'] = np.where(data['goals'] >= 15, 'good_shooter', 'weak_shooter')

data['assist_type'] = np.where(data['assists'] >= 25, 'good_assister', 'weak_assister')

data['age_type'] = np.where(data['age'] < 30, 'young', 'old')

data['height_type'] = np.where(data['height'] < 185, 'short', 'tall')

data['weight_type'] = np.where(data['weight'] < 90, 'light', 'heavy')

data['experience_type'] = np.where(data['experience'] < 10, 'rookie', 'veteran')

model = BayesianModel([
    ('role', 'age_type'),
    ('role', 'shooter_type'),
    ('role', 'height_type'),
    ('role', 'weight_type'),
    ('height_type', 'weight_type'),
    ('age_type', 'experience_type'),
    ('experience_type', 'assist_type')
])

print("Nodes:", model.nodes())
print("Edges:", model.edges())

data['role'] = pd.Categorical(data['role'])
data['age_type'] = pd.Categorical(data['age_type'], categories=['young', 'old'])
data['shooter_type'] = pd.Categorical(data['shooter_type'], categories=['weak_shooter', 'good_shooter'])
data['height_type'] = pd.Categorical(data['height_type'], categories=['short', 'tall'])
data['weight_type'] = pd.Categorical(data['weight_type'], categories=['light', 'heavy'])
data['experience_type'] = pd.Categorical(data['experience_type'], categories=['rookie', 'veteran'])
data['assist_type'] = pd.Categorical(data['assist_type'], categories=['weak_assister', 'good_assister'])

model.fit(data, estimator=MaximumLikelihoodEstimator)

for node in model.nodes():
    print(f"CPT for {node}:")
    cpt = model.get_cpds(node=node)
    print(cpt)
