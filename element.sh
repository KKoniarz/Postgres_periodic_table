#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else

  # Check if called with number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    # Search element by atomic_number
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number = $1")
  else
    # Search element by symbol or name
    ELEMENT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE symbol='$1' OR name='$1'")
  fi

  # Check if element was found
  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS="|" read ATOMIC_NUMBER SYMBOL NAME <<< $ELEMENT
    # Get element properties
    PROPERTIES=$($PSQL "SELECT type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM
    properties LEFT JOIN types USING(type_id)
    WHERE atomic_number = $ATOMIC_NUMBER")
    IFS="|" read TYPE ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS <<< $PROPERTIES

    # Output message
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
fi