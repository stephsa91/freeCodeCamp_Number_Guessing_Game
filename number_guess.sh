#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

# get player from database
USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE username = '$USERNAME'")

# if player does not exist in database
if [[ -z $USERNAME_ID ]]
then
  # print welcome message to new player
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  # insert new player info into database
  INSERTED_TO_USERS=$($PSQL "INSERT INTO usernames(username) VALUES('$USERNAME')")
  # get username_id from database
  USERNAME_ID=$($PSQL "SELECT username_id FROM usernames WHERE username = '$USERNAME'")
else
  # if player exist, get games played
  GAMES_PLAYED=$($PSQL "SELECT count(username_id) FROM games_played WHERE username_id = '$USERNAME_ID'")
  # get best game (game with least players)
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games_played WHERE username_id = '$USERNAME_ID'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GUESSING_GAME() {
# generate secret number
SECRET_NUMBER=$(( RANDOM % 1001 ))
GUESSED=0
GUESSES=0

echo $SECRET_NUMBER #(for tests)
echo -e "\nGuess the secret number between 1 and 1000:\n"

while [[ $GUESSED = 0 ]]
do
  read PLAYER_GUESS

  # if guess is not a number
  if [[ ! $PLAYER_GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  # if the guess is correct
  elif [[ $PLAYER_GUESS = $SECRET_NUMBER ]]
  then
    GUESSES=$(($GUESSES + 1))
    echo -e "\nYou guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    # insert game and guess into database
    INSERT_INTO_GAMES_PLAYED=$($PSQL "INSERT INTO games_played(username_id, guesses) VALUES($USERNAME_ID, $GUESSES)")
    GUESSED=1
  # if guess is lower than secret number
  elif [[ $PLAYER_GUESS -lt $SECRET_NUMBER  ]]
  then
    GUESSES=$(($GUESSES + 1))
    echo -e "\nIt's greater than that, guess again:"
  # if guess is greater than secret number
  else
    GUESSES=$(($GUESSES + 1))
    echo -e "\nIt's lower than that, guess again:"
  fi
done
}

GUESSING_GAME
