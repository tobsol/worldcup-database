#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Clear existing data
echo "$($PSQL "TRUNCATE TABLE games, teams;")"

# Insert data from CSV
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # skip header
  if [[ $YEAR != "year" ]]
  then
    # insert teams (unique)
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT (name) DO NOTHING;")"
    echo "$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT (name) DO NOTHING;")"

    # insert game with looked-up IDs
    echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
      VALUES(
        $YEAR,
        '$ROUND',
        (SELECT team_id FROM teams WHERE name='$WINNER'),
        (SELECT team_id FROM teams WHERE name='$OPPONENT'),
        $W_GOALS,
        $O_GOALS
      );")"
  fi
done

