#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Empty rows in the tables form worldcup database
echo $($PSQL "TRUNCATE TABLE games, teams;")

#Row counter
ROW_COUNTER=0

# Insert data from games.csv to tables: teams and games in my worldcup db
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # Insert information into the teams table of my worldcup db
  # Retreive all team names from the winner column in games.csv
  # Avoid the title from being saved in the table
  if [[ $WINNER != winner ]]
  then
    # Get team_id in case it has already been inserted into the teams table (avoid duplicates)
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")

    # If not found
    if [[ -z $TEAM_ID ]]
    then
      # Insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $WINNER"
      fi

      # Get new team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    fi

  fi

  # Retreive all remaining team names from the opponent column in games.csv
  if [[ $OPPONENT != opponent ]]
  then
    # Get team_id in case it has already been inserted into the teams table (avoid duplicates)
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    # If not found
    if [[ -z $TEAM_ID ]]
    then
      # Insert team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")

      if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
      then
        echo "Inserted into teams, $OPPONENT"
      fi

      # Get new team_id
      TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    fi

  fi

  # Insert information into the games table in my worldcup db
  if [[ $YEAR != year ]]
  then
    #Retreive winner_id and opponent_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
    
    #Insert game information
    INSERT_GAME_INFORMATION=$($PSQL "INSERT INTO games(
      year,
      round,
      winner_goals,
      opponent_goals,
      winner_id,
      opponent_id
    ) VALUES(
      '$YEAR',
      '$ROUND',
      '$WINNER_GOALS',
      '$OPPONENT_GOALS',
      '$WINNER_ID',
      '$OPPONENT_ID'
    );")

    if [[ $INSERT_GAME_INFORMATION == 'INSERT 0 1' ]]
      then
        #Increment row counter
        ((ROW_COUNTER++))
        echo "Inserted row $ROW_COUNTER into games"
      fi
  fi
  
done