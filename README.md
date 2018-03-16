# NCAA March Madness Machine Learning Competition
This repository includes the scripts and files used to predict the outcomes of the NCAA Tournament as part of the [Kaggle compeition here](https://www.kaggle.com/c/march-machine-learning-mania-2017).

Below are the blog posts to the winners from the last 3 March Machine Learning Mania competitions hosted by [Kaggle](https://www.kaggle.com/). Each of the previous winners used a different approach for the competition, which could suggest flaws in existing methodlogies to predict game outcomes. This partially demonstrates the *madness* in the NCAA Tournament. 

* [2014 Winner](https://statsbylopez.com/2014/12/04/building-an-ncaa-mens-basketball-prediction-model/)

* [2015 Winner](http://blog.kaggle.com/2015/04/17/predicting-march-madness-1st-place-finisher-zach-bradshaw/)

* [2016 Winner](http://blog.kaggle.com/2016/05/10/march-machine-learning-mania-2016-winners-interview-1st-place-miguel-alomar/)


## Random Forest Model
The RandomForest_Predictions.R file was my first attempt at formatting the data and creating a random forest model to predict the outcome of the tournament games. The methodology relies on the hypothesis that regular season performance is indicative of tournament success. Therefore, the model uses aggregated game statistics for each team to predict the team’s performance against its tournament opponents. This is summarized by the following simplified equation:

**Probability of Team A defeating Team B** = **Function**(*Team A’s and Team B’s Season Statistics*)

The table below lists the features created/used in the predictive model.
				  
Variable | Variable Description
------------ | -------------
Win | Indicator variable for game outcome (1 = Team A wins, 0 = Team B Wins)
TotalWinPctA | Team A's regular season winning percentage
SeedValueA | Team A's tournament seed value
WinsLastSixA | Team A's number of wins in the last 6 games
TeamPointsAvgA | Team A's average points per regular season game
OppPointsAvgA | Team A's average points given up per regular season game
TeamAvgFgPercentageA | Team A's average field goal percentage in regular season games
OppAvgFgPercentageA | Team A's opponent's average field goal percentage
TeamAvgTODiffA | Team A's average tournover differential per regular season game
CloseGamesPercentA | Percentage of games won by fewer than 10 points by Team A
FreeThrowsPercentA | Team A's average free throw percentage during the regular season
OffensiveReboundsAvgA | Team A's average number of offensive repounds per regular season game
TotalWinPctB | Team B's regular season winning percentage
SeedValueB | Team B's tournament seed value
WinsLastSixB | Team B's number of wins in the last 6 games
TeamPointsAvgB | Team B's average points per regular season game
OppPointsAvgB | Team B's average points given up per regular season game
TeamAvgFgPercentageB | Team B's average field goal percentage in regular season games
OppAvgFgPercentageB | Team B's opponent's average field goal percentage
TeamAvgTODiffB | Team B's average tournover differential per regular season game
CloseGamesPercentB | Percentage of games won by fewer than 10 points by Team B
FreeThrowsPercentB | Team B's average free throw percentage during the regular season
OffensiveReboundsAvgB | Team B's average number of offensive repounds per regular season game


## Seed and Elo Benchmarks
There are a couple useful script available on [Kaggle](https://www.kaggle.com/) that compute predictions based on [tournament seeds](https://www.kaggle.com/wacaxx/march-machine-learning-mania-2016/seed-benchmark-data-table-in-r/code) and [team Elo ratings](https://www.kaggle.com/wacaxx/march-machine-learning-mania-2016/elo-benchmark-playerratings-in-r). These scripts might be useful to generate comparison predictions for the final model. 
