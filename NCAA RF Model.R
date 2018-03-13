

## Load packages
library(tidyverse) 
library(randomForest)
library(stringr)

###########################################
########################################### Import Data tables provided by Kaggle website

## Set working directory where files are stored
setwd("C:/Users/dmiel/OneDrive/Documents/Kaggle/2018 NCAA Tournament Data")


## Read files into R
teams <- read.csv("Teams.csv", header = TRUE, stringsAsFactors = FALSE)
regSeason <- read.csv("RegularSeasonCompactResults.csv", header = TRUE, stringsAsFactors = FALSE)
seasons <- read.csv("Seasons.csv", header = TRUE, stringsAsFactors = FALSE)
tourneyRes <- read.csv("NCAATourneyCompactResults.csv", header = TRUE, stringsAsFactors = FALSE)
tourneyResDetail <- read.csv("NCAATourneyDetailedResults.csv", header = TRUE, stringsAsFactors = FALSE)


tourneySeeds <- read.csv("NCAATourneySeeds.csv", header = TRUE, stringsAsFactors = FALSE)
tourneySlots <- read.csv("NCAATourneySlots.csv", header = TRUE, stringsAsFactors = FALSE)
regSeasonDetail <- read.csv("RegularSeasonDetailedResults.csv", header = TRUE, stringsAsFactors = FALSE)



regSeason %>% filter(WTeamID == 1388 & Season == 2018)


###########################################
########################################### Create a training dataset


## Create "match-up" column 
games <- ifelse(test = tourneyRes$WTeamID < tourneyRes$LTeamID,
                yes = paste(tourneyRes$Season, "_", tourneyRes$WTeamID, "_", tourneyRes$LTeamID, sep = ""),
                no = paste(tourneyRes$Season, "_", tourneyRes$LTeamID, "_", tourneyRes$WTeamID, sep = ""))

## Identify Team A
teamA <-  ifelse(test = tourneyRes$WTeamID < tourneyRes$LTeamID,
                 yes = tourneyRes$WTeamID,
                 no = tourneyRes$LTeamID)

## Identify Team B
teamB <-  ifelse(test = tourneyRes$WTeamID < tourneyRes$LTeamID,
                 yes = tourneyRes$LTeamID,
                 no = tourneyRes$WTeamID)


outcome <- ifelse(test = tourneyRes$WTeamID < tourneyRes$LTeamID,
                  yes = 1,
                  no = 0)

## Create initial training dataset
trainData <- data.frame(Matchup = games, 
                        Win = outcome, 
                        Season=tourneyRes$Season,
                        TeamA = teamA, 
                        TeamB = teamB)



## Wins by teams during regular season
gamesWon <- as.data.frame(table(regSeason$WTeamID, regSeason$Season), stringsAsFactors = FALSE)
gamesLost <- as.data.frame(table(regSeason$LTeamID, regSeason$Season), stringsAsFactors = FALSE)

names(gamesWon) <- c("Team", "Season", "Wins")
names(gamesLost) <- c("Team", "Season", "Losses")
gamesWon$Season <- as.integer(gamesWon$Season)
gamesWon$Team <- as.integer(gamesWon$Team)

gamesLost$Season <- as.integer(gamesLost$Season)
gamesLost$Team <- as.integer(gamesLost$Team)






## Join games lost and games one into one table
tourneySeeds <- tourneySeeds  %>% 
  inner_join(gamesWon, by=c("TeamID" = "Team", "Season")) %>% 
  inner_join(gamesLost, by=c("TeamID" = "Team", "Season"))

## Identify Seed number
tourneySeeds <- tourneySeeds %>% 
  mutate(SeedValue = as.numeric(gsub(pattern = "[A-Z]",
                                     ignore.case = TRUE, 
                                     replacement = "",
                                     x = tourneySeeds$Seed)))

## Calculate regular season winning percentage
tourneySeeds <- tourneySeeds %>% 
  mutate(TotalWinPct = round(Wins/(Wins+Losses), 
                             digits = 3))


## Identify Wins by team
wins <- cbind(Season = regSeasonDetail$Season, 
              Team = regSeasonDetail$WTeamID,
              Opponent = regSeasonDetail$LTeamID,
              DayNum = regSeasonDetail$DayNum, 
              Location = regSeasonDetail$WLoc,
              Result = as.numeric(1), 
              TeamScore = regSeasonDetail$WScore,
              NumOT = regSeasonDetail$NumOT,
              TeamFGM = regSeasonDetail$WFGM,
              TeamFGA = regSeasonDetail$WFGA,
              TeamFGM3 = regSeasonDetail$WFGM3,
              TeamFGA3 = regSeasonDetail$WFGA3,
              TeamFTM = regSeasonDetail$WFTM,
              TeamFTA = regSeasonDetail$WFTA,
              TeamOR = regSeasonDetail$WOR,
              TeamDR = regSeasonDetail$WDR,
              TeamAst = regSeasonDetail$WAst,
              TeamTO = regSeasonDetail$WTO,
              TeamStl = regSeasonDetail$WStl,
              TeamBlk = regSeasonDetail$WBlk,
              ## Opponent Statistics	
              OppScore = regSeasonDetail$LScore,
              OppFGM = regSeasonDetail$LFGM,
              OppFGA = regSeasonDetail$LFGA,
              OppFGM3 = regSeasonDetail$LFGM3,
              OppFGA3 = regSeasonDetail$LFGA3,
              OppFTM = regSeasonDetail$LFTM,
              OppFTA = regSeasonDetail$LFTA,
              OppOR = regSeasonDetail$LOR,
              OppDR = regSeasonDetail$LDR,
              OppAst = regSeasonDetail$LAst,
              OppTO = regSeasonDetail$LTO,
              OppStl = regSeasonDetail$LStl,
              OppBlk = regSeasonDetail$LBlk,	
              ## Point Differential 
              PointDiff = regSeasonDetail$WScore -  regSeasonDetail$LScore)


## Identify losses by team
losses <- cbind(Season = regSeasonDetail$Season, 
                Team = regSeasonDetail$LTeamID,
                Opponent = regSeasonDetail$WTeamID,
                DayNum = regSeasonDetail$DayNum, 
                Location = ifelse(test = regSeasonDetail$WLoc == "H", 
                                  yes = "A", 
                                  no = "H"),
                Result = as.numeric(0), 
                TeamScore = regSeasonDetail$LScore,
                NumOT = regSeasonDetail$NumOT,
                TeamFGM = regSeasonDetail$LFGM,
                TeamFGA = regSeasonDetail$LFGA,
                TeamFGM3 = regSeasonDetail$LFGM3,
                TeamFGA3 = regSeasonDetail$LFGA3,
                TeamFTM = regSeasonDetail$LFTM,
                TeamFTA = regSeasonDetail$LFTA,
                TeamOR = regSeasonDetail$LOR,
                TeamDR = regSeasonDetail$LDR,
                TeamAst = regSeasonDetail$LAst,
                TeamTO = regSeasonDetail$LTO,
                TeamStl = regSeasonDetail$LStl,
                TeamBlk = regSeasonDetail$LBlk,
                ## Opponent Statistics	
                OppScore = regSeasonDetail$WScore,
                OppFGM = regSeasonDetail$WFGM,
                OppFGA = regSeasonDetail$WFGA,
                OppFGM3 = regSeasonDetail$WFGM3,
                OppFGA3 = regSeasonDetail$WFGA3,
                OppFTM = regSeasonDetail$WFTM,
                OppFTA = regSeasonDetail$WFTA,
                OppOR = regSeasonDetail$WOR,
                OppDR = regSeasonDetail$WDR,
                OppAst = regSeasonDetail$WAst,
                OppTO = regSeasonDetail$WTO,
                OppStl = regSeasonDetail$WStl,
                OppBlk = regSeasonDetail$WBlk,	
                ## Point Differential 
                PointDiff = regSeasonDetail$LScore -  regSeasonDetail$WScore)


losses <- as.data.frame(losses)

wins <- as.data.frame(wins)


names(losses) == names(wins)
## Union wins and losses into one dataframe
allGames <- as.data.frame(rbind(wins, losses),stringsAsFactors = FALSE)

## Create copy of table to save time later
allGamesCopy <- allGames


## Convert all columns of table to numeric 
allGames <- as.data.frame(apply(X = allGames,
                                MARGIN = 2,
                                FUN = function(y) as.numeric(as.character(y))))



table(allGames$Season)

## Replace location and result variables with character replacements (from copy)
allGames$Location = allGamesCopy$Location
allGames$Result = allGamesCopy$Result

## Remove copy of table from memory
rm(allGamesCopy) 

## Sort Column by season, team, and daynum
allGames <- allGames[with(allGames, order(Season, Team, DayNum)), ]




## Split dataframe into lists by season & team
## Each season-team combination is now in its own dataframe in a large list 
TeamSeasons <- split(x = allGames, f = list(allGames$Season, allGames$Team))
TeamSeasons <- lapply(X = TeamSeasons,FUN = transform, cumulativeWins = cumsum(Result==1)) ## haven't used yet. 
TeamSeasons <- lapply(X = TeamSeasons,FUN = transform, cumulativeLosses = cumsum(Result==0))  ## haven't used yet



###########################################
###########################################
## The next steps loop over seasons and teams in TeamSeasons list to create summary variables by season and team


## Identify the number of wins in the last six games for team each season
LastSix <- lapply(X = TeamSeasons,FUN = tail)
LastSix <- lapply(X = LastSix,FUN = function(y) sum(y$Result==1))
LastSix <- data.frame(WinsLastSix = unlist(LastSix, recursive = TRUE, use.names = TRUE))
LastSix$Season <- as.integer(as.character(substr(x = rownames(LastSix),start = 1, stop = 4)))
LastSix$Team <- as.integer(as.character(substr(x = rownames(LastSix), start = 6, stop = 9)))


## Average points for team each season
TeamPointsAvg <- lapply(X = TeamSeasons,FUN = function(y) mean(y$TeamScore))
TeamPointsAvg <- data.frame(TeamPointsAvg = unlist(TeamPointsAvg, recursive = TRUE, use.names = TRUE))
TeamPointsAvg$Season <- as.integer(as.character(substr(x = rownames(TeamPointsAvg),start = 1, stop = 4)))
TeamPointsAvg$Team <- as.integer(as.character(substr(x = rownames(TeamPointsAvg), start = 6, stop = 9)))



## Average points against team each season
OppPointsAvg <- lapply(X = TeamSeasons,FUN = function(y) mean(y$OppScore))
OppPointsAvg <- data.frame(OppPointsAvg = unlist(OppPointsAvg, recursive = TRUE, use.names = TRUE))
OppPointsAvg$Season <- as.integer(as.character(substr(x = rownames(OppPointsAvg),start = 1, stop = 4)))
OppPointsAvg$Team <- as.integer(as.character(substr(x = rownames(OppPointsAvg), start = 6, stop = 9)))


## Average points for team each season
TeamAvgFgPercentage <- lapply(X = TeamSeasons,FUN = function(y) mean((y$TeamFGM/y$TeamFGA)))
TeamAvgFgPercentage <- data.frame(TeamAvgFgPercentage = unlist(TeamAvgFgPercentage, recursive = TRUE, use.names = TRUE))
TeamAvgFgPercentage$Season <- as.integer(as.character(substr(x = rownames(TeamAvgFgPercentage),start = 1, stop = 4)))
TeamAvgFgPercentage$Team <- as.integer(as.character(substr(x = rownames(TeamAvgFgPercentage), start = 6, stop = 9)))



## Average field goal percentage against team each season
OppAvgFgPercentage <- lapply(X = TeamSeasons,FUN = function(y) mean((y$OppFGM/y$OppFGA)))
OppAvgFgPercentage <- data.frame(OppAvgFgPercentage = unlist(OppAvgFgPercentage, recursive = TRUE, use.names = TRUE))
OppAvgFgPercentage$Season <- as.integer(as.character(substr(x = rownames(OppAvgFgPercentage),start = 1, stop = 4)))
OppAvgFgPercentage$Team <- as.integer(as.character(substr(x = rownames(OppAvgFgPercentage), start = 6, stop = 9)))


## Average turnover differential by team each season
TeamAvgTODiff <- lapply(X = TeamSeasons,FUN = function(y) mean(y$TeamTO-y$OppTO))
TeamAvgTODiff <- data.frame(TeamAvgTODiff = unlist(TeamAvgTODiff, recursive = TRUE, use.names = TRUE))
TeamAvgTODiff$Season <- as.integer(as.character(substr(x = rownames(TeamAvgTODiff),start = 1, stop = 4)))
TeamAvgTODiff$Team <- as.integer(as.character(substr(x = rownames(TeamAvgTODiff), start = 6, stop = 9)))


## Count of games for team each season
GamesCount <- lapply(X = TeamSeasons,FUN = function(y) length(y$Team))
GamesCount <- data.frame(GamesCount = unlist(GamesCount, recursive = TRUE, use.names = TRUE))
GamesCount$Season <- as.integer(as.character(substr(x = rownames(GamesCount),start = 1, stop = 4)))
GamesCount$Team <- as.integer(as.character(substr(x = rownames(GamesCount), start = 6, stop = 9)))


## Count of close wins for team each season (games within 10 points)
CloseGamesCount <- allGames %>%
  filter(Result == 1, PointDiff < 10) %>% 
  group_by(Season, Team) %>%
  summarise(NumCloseGames = n())

# 
# 
# CloseGamesCount <- data.frame(CloseGamesCount = unlist(CloseGamesCount, recursive = TRUE, use.names = TRUE))
# CloseGamesCount$Season <- as.integer(as.character(substr(x = rownames(CloseGamesCount),start = 1, stop = 4)))
# CloseGamesCount$Team <- as.integer(as.character(substr(x = rownames(CloseGamesCount), start = 6, stop = 9)))


## Count of close wins for team each season (games within 10 points)
## Average turnover differential by team each season
FreeThrowsPercent <- lapply(X = TeamSeasons,FUN = function(y) mean(y$TeamFTM/y$TeamFTA,na.rm = TRUE))
FreeThrowsPercent <- data.frame(FreeThrowsPercent = unlist(FreeThrowsPercent, recursive = TRUE, use.names = TRUE))
FreeThrowsPercent$Season <- as.integer(as.character(substr(x = rownames(FreeThrowsPercent),start = 1, stop = 4)))
FreeThrowsPercent$Team <- as.integer(as.character(substr(x = rownames(FreeThrowsPercent), start = 6, stop = 9)))

OffensiveReboundsAvg <- lapply(X = TeamSeasons,FUN = function(y) mean(y$TeamOR))
OffensiveReboundsAvg <- data.frame(OffensiveReboundsAvg = unlist(OffensiveReboundsAvg, recursive = TRUE, use.names = TRUE))
OffensiveReboundsAvg$Season <- as.integer(as.character(substr(x = rownames(OffensiveReboundsAvg),start = 1, stop = 4)))
OffensiveReboundsAvg$Team <- as.integer(as.character(substr(x = rownames(OffensiveReboundsAvg), start = 6, stop = 9)))


# table(tourneySeeds$Season)
# 
# tourneySeeds %>% filter(TeamID == 1388) & Season == 2018)
# teams %>% filter(TeamID == 1388)


## Join statistics to tourney seeds table
AllTeamStats <- tourneySeeds %>% 
  inner_join(teams,by=c("TeamID")) %>%		
  inner_join(LastSix, by=c("TeamID" = "Team", "Season")) %>% 
  inner_join(TeamPointsAvg, by=c("TeamID" = "Team", "Season")) %>% 
  inner_join(OppPointsAvg, by=c("TeamID" = "Team", "Season")) %>%
  inner_join(TeamAvgFgPercentage, by=c("TeamID" = "Team", "Season")) %>%
  inner_join(OppAvgFgPercentage, by=c("TeamID" = "Team", "Season")) %>%
  inner_join(TeamAvgTODiff, by=c("TeamID" = "Team", "Season")) %>% 
  inner_join(GamesCount, by=c("TeamID" = "Team", "Season")) %>% 
  inner_join(CloseGamesCount, by=c("TeamID" = "Team", "Season")) %>%
  inner_join(FreeThrowsPercent, by=c("TeamID" = "Team", "Season")) %>%
  inner_join(OffensiveReboundsAvg, by=c("TeamID" = "Team", "Season")) 




AllTeamStats$CloseGamesPercent <- AllTeamStats$NumCloseGames/AllTeamStats$GamesCount

################################################################ 
################################################################ 
################################################################ 
## Remove unneccessary Data
# rm(tourneySeeds, teams,regSeason, seasons, tourneyRes, tourneyResDetail, tourneySlots, 
#    regSeasonDetail, games, teamA, teamB, outcome, gamesWon, gamesLost, wins, 
#    losses, allGames, LastSix, TeamPointsAvg, OppPointsAvg, TeamAvgFgPercentage, 
#    OppAvgFgPercentage, TeamAvgTODiff, GamesCount, CloseGamesCount, FreeThrowsPercent, OffensiveReboundsAvg)

################################################################ 
################################################################ 
################################################################ 

## Create a table with TeamA names


names(AllTeamStats)
names(AllTeamStatsA) <- c("Season", "SeedA", "TeamA", "WinsA", "LossesA", "SeedValueA", 
                          "TotalWinPctA", "Team_NameA", "FirstD1SeasonA", "LastD1SeasonA", 
                          "WinsLastSixA", "TeamPointsAvgA", 
                          "OppPointsAvgA", "TeamAvgFgPercentageA","OppAvgFgPercentageA", 
                          "TeamAvgTODiffA","GamesCountA", "CloseGamesCountA", 
                          "CloseGamesPercentA","FreeThrowsPercentA", "OffensiveReboundsAvgA")


## Create a table with TeamB names
AllTeamStatsB <- AllTeamStats
names(AllTeamStatsB) <- c("Season", "SeedB", "TeamB", "WinsB", "LossesB", "SeedValueB", 
                          "TotalWinPctB", "Team_NameB", "FirstD1SeasonB", "LastD1SeasonB", 
                          "WinsLastSixB", "TeamPointsAvgB", 
                          "OppPointsAvgB", "TeamAvgFgPercentageB", "OppAvgFgPercentageB", 
                          "TeamAvgTODiffB", "GamesCountB", "CloseGamesCountB", 
                          "CloseGamesPercentB","FreeThrowsPercentB", "OffensiveReboundsAvgB")



################################################################ 
################################################################ 
################################################################ 
## STOPPED UPDATING HERE

trainData$TeamA <- as.integer(trainData$TeamA)
trainData$TeamB <- as.integer(trainData$TeamB)


str(AllTeamStatsA)
AllTeamStatsA$TeamA <- as.integer(AllTeamStatsA$TeamA)
AllTeamStatsA$Season <- as.integer(AllTeamStatsA$Season)


AllTeamStatsB$TeamB <- as.integer(AllTeamStatsB$TeamB)
AllTeamStatsB$Season <- as.integer(AllTeamStatsB$Season)




## Join trainData to table with TeamA data and table with TeamB data
trainDataFull <- trainData %>% 
  inner_join(AllTeamStatsA,by = c("TeamA" = "TeamA", "Season"))  %>% 
  inner_join(AllTeamStatsB,by = c("TeamB" = "TeamB", "Season"))

trainDataFull$Win <- as.factor(trainDataFull$Win)

#tourneySeeds <- tourneySeeds[,c(1:3,8,4:7,9:16)]

unique(trainDataFull$Season)


#########################################
#########################################
######################################### Create first model for predictions

trainDataSubset <- trainDataFull[trainDataFull$Season <= 2014,]
testDataSubset <- trainDataFull[trainDataFull$Season >2014,]

## First attempt: create a random forest decision tree model to predict game outcomes
train_randomForest <- randomForest(formula = Win ~ 
                                     TotalWinPctA + TotalWinPctB + 
                                     SeedValueA + SeedValueB + 
                                     WinsLastSixA + WinsLastSixB +
                                     TeamPointsAvgA + TeamPointsAvgB + 
                                     OppPointsAvgA + OppPointsAvgB + 
                                     TeamAvgFgPercentageA + TeamAvgFgPercentageB +
                                     OppAvgFgPercentageA + OppAvgFgPercentageB + 
                                     TeamAvgTODiffA + TeamAvgTODiffB + 
                                     CloseGamesPercentA + CloseGamesPercentB + 
                                     FreeThrowsPercentA + FreeThrowsPercentB +
                                     OffensiveReboundsAvgA + OffensiveReboundsAvgA,
                                   data = trainDataFull, 
                                   ntree = 500)

## View summary of random forest model
train_randomForest


## Use model to predict on test data
testDataSubset$Predprob <- predict(object = train_randomForest,
                                   newdata = testDataSubset,type = "prob")[,2]
testDataSubset$Predwin <- predict(object = train_randomForest,
                                  newdata = testDataSubset,type = "response")



view_testDataSubset <- testDataSubset[,c("Matchup","Team_NameA","Team_NameB","SeedValueA","SeedValueB","Win","Predwin","Predprob")]
View(view_testDataSubset)



## View Accuracy Table
table(actual = view_testDataSubset$Win, 
      pred = view_testDataSubset$Predwin)


## Create submission file
sampleSubmission <- read.csv("SampleSubmissionStage2.csv", header = TRUE, stringsAsFactors = FALSE)


sampleSubmission$Season <- as.integer(substring(text = sampleSubmission$ID,first = 0,last = 4))
sampleSubmission$TeamA <- as.integer(substring(text = sampleSubmission$ID,first = 6,last = 9))
sampleSubmission$TeamB <- as.integer(substring(text = sampleSubmission$ID,first = 11,last = 14))



sampleSubmission <- sampleSubmission %>% 
 left_join(AllTeamStatsA,by = c("TeamA", "Season"))  %>% 
  inner_join(AllTeamStatsB,by = c("TeamB", "Season")) 


## Add predicted values to submission file
sampleSubmission$Pred <- predict(train_randomForest,
                                 newdata = sampleSubmission,
                                 type = "prob")[,2]

1-0.368

sampleSubmission %>% filter(Team_NameA =="Purdue"& Team_NameB =="Villanova")

Submission <- data.frame(id = sampleSubmission$ID, 
                         pred = sampleSubmission$Pred)
                         # ,
                         # teama = sampleSubmission$Team_NameA,
                         # teamb = sampleSubmission$Team_NameB)
                         # ,
                         # seeda = sampleSubmission$SeedValueA,
                         # seedb = sampleSubmission$SeedValueB)

write.csv(x = Submission, 
          file = "sample_submission7.csv",
          row.names = FALSE)


##############################################################
##############################################################


###### Other variables to consider
## NCAA conference
## Wins against top 25 teams
## conference champion
## stength of victory
## strength of schedule
## avg game statistics
## avg game statistics last 6 games
## past season playoff success (legacy)
# Away Wins Winning Percentage
# Wins by margin less than 2
# Losses by margin less than 2
# Wins by margin greater than 7
# Losses by margin greater than 7
# Win Percentage in last 4 weeks
# Win Percentage against playoff teams
# Wins in Tournament