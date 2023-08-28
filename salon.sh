#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

APPOINTMENT() {
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME_FORMATTED?"
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id, time) VALUES('$CUSTOMER_ID',$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  }

LIST_OF_SERVICES() {
  LIST=$($PSQL "SELECT service_id, name FROM services")
  echo "$LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME" 
  done  
  }

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  LIST_OF_SERVICES

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_AVAILABLE ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?" 
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      ALREADY_A_CUSTOMER=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $ALREADY_A_CUSTOMER ]]
      then 
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //')
        INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME_FORMATTED')")
        APPOINTMENT
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
        CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/ //')
        APPOINTMENT
      fi     
    fi
  fi
}
MAIN_MENU
