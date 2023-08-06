#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ Salon ~~"

MAIN_MENU() {
  
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  echo Welcome to the salon. How can we help you?

  SERVICES=$($PSQL "SELECT * FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done 

  read SERVICE_ID_SELECTED
  
  SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SELECTED_SERVICE_NAME ]]
  then
    MAIN_MENU "Please select a valid service id."
  else
    echo Please enter your phone number
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]] 
    then
      echo "Phone number not found in database. What's your name?"
      read CUSTOMER_NAME
      INSERT_NAME_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    else 
      echo "Hi, $CUSTOMER_NAME."
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    echo "What time would you like your $SELECTED_SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo $INSERT_APPOINTMENT_RESULT
    echo "I have put you down for a $(echo $SELECTED_SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}



MAIN_MENU