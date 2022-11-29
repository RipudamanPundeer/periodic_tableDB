#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"
RANDOM_NUM=$(( $RANDOM % 1000 + 1 ))

NUMBER_GUESS()
{
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  GUESS_COUNT=1
  until [[ $GUESS -eq $RANDOM_NUM ]]
  do
    if [[ $GUESS =~ ^[0-9]+$ ]]
    then
      if [[ $GUESS -gt $RANDOM_NUM ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi
      read GUESS
      GUESS_COUNT=$(( $GUESS_COUNT + 1 ))
    else
      echo "That is not an integer, guess again:"
      read GUESS
    fi
  done
  echo  "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
  return $GUESS_COUNT
}

INSERT_GAME_DETAILS()
{
  if [[ -z $3 && -z $4 ]]
  then
    UPDATE_RESULT=$($PSQL "update guesses set games_played=1,best_game=$2 where username='$1'")
  else
    GAMES_PLAYED=$(( $3 + 1 ))
    BEST_GAME=$4
    if [[ $2 -lt $BEST_GAME ]]
    then
      BEST_GAME=$2
    fi
    UPDATE_RESULT=$($PSQL "update guesses set games_played=$GAMES_PLAYED,best_game=$BEST_GAME where username='$1'")
  fi
}

CHECK_USERNAME()
{
  USERNAME_RESULT=$($PSQL "select * from guesses where username='$1'")
  if [[ -z $USERNAME_RESULT ]]
  then
    INSERT_RESULT=$($PSQL "insert into guesses(username) values('$1')")
    echo "Welcome, $1! It looks like this is your first time here."
    NUMBER_GUESS
    GUESS_COUNT=$?
    INSERT_GAME_DETAILS $1 $GUESS_COUNT
  else
    USERNAME=$($PSQL "select username from guesses where username='$1'")
    GAMES_PLAYED=$($PSQL "select games_played from guesses where username='$1'")
    BEST_GAME=$($PSQL "select best_game from guesses where username='$1'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    NUMBER_GUESS
    GUESS_COUNT=$? 
    INSERT_GAME_DETAILS $USERNAME $GUESS_COUNT $GAMES_PLAYED $BEST_GAME
  fi 
}

echo "Enter your username:"
read USERNAME

CHECK_USERNAME $USERNAME