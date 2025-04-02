#!/bin/bash

# Define the base URL for the Flask API
BASE_URL="http://localhost:5000/api"

# Flag to control whether to echo JSON output
ECHO_JSON=false

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
  case $1 in
    --echo-json) ECHO_JSON=true ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
  shift
done

###############################################
#
# Health checks
#
###############################################

# Function to check the health of the service
check_health() {
  echo "Checking health status..."
  curl -s -X GET "$BASE_URL/health" | grep -q '"status": "success"'
  if [ $? -eq 0 ]; then
    echo "Service is healthy."
  else
    echo "Health check failed."
    exit 1
  fi
}

# Function to check the database connection
check_db() {
  echo "Checking database connection..."
  curl -s -X GET "$BASE_URL/db-check" | grep -q '"status": "success"'
  if [ $? -eq 0 ]; then
    echo "Database connection is healthy."
  else
    echo "Database check failed."
    exit 1
  fi
}


create_boxer() {
    id = $1
    name=$2
    weight=$3
    height=$4
    reach=$5
    age=$6

    echo "Creating boxer with id: $id, name: $name, weight: $weight, height: $height, reach: $reach, age: $age"
    curl -s -X POST "$BASE_URL/boxers" \
        -H "Content-Type: application/json" \
        -d '{
            "id": "'"$id"'",
            "name": "'"$name"'",
            "weight": '"$weight"',
            "height": '"$height"',
            "reach": '"$reach"',
            "age": '"$age"'
        }' | grep -q '"status": "success"'

    if [ $? -eq 0 ]; then   
        echo "Boxer created successfully."
    else
        echo "Failed to create boxer."
        exit 1
    fi
}

delete_boxer() {
    boxer_id=$1

    echo "Deleting boxer with ID: $boxer_id"
    response=$(curl -s -X DELETE "$BASE_URL/boxers/$boxer_id")
    if echo "$response" | grep -q '"status": "success"'; then
        echo "Boxer deleted successfully."
    else
        echo "Failed to delete boxer."
        exit 1
    fi
}

get_leaderboard() {
    echo "Fetching leaderboard..."
    response=$(curl -s -X GET "$BASE_URL/leaderboard")
    if echo "$response" | grep -q '"status": "success"'; then
        if [ "$ECHO_JSON" = true ]; then
            echo "leaderboard JSON:"
            echo "$response"| jq .
        fi
    else
        echo "Failed to fetch leaderboard."
        exit 1
    fi
}

get_boxer_by_id() {
    boxer_id=$1

    echo "Fetching boxer with ID: $boxer_id"
    response=$(curl -s -X GET "$BASE_URL/boxers/$boxer_id")
    if echo "$response" | grep -q '"status": "success"'; then
        echo "Boxer retrieved successfully by ID ($boxer_id)."
        if [ "$ECHO_JSON" = true ]; then
            echo "Boxer JSON:"
            echo "$response"| jq .
        fi
    else
        echo "Failed to fetch boxer."
        exit 1
    fi
}

get_boxer_by_name() {
    boxer_name=$1

    echo "Fetching boxer with name: $boxer_name"
    response=$(curl -s -X GET "$BASE_URL/boxers?name=$boxer_name")
    if echo "$response" | grep -q '"status": "success"'; then
        echo "Boxer retrieved successfully by name ($boxer_name)."
        if [ "$ECHO_JSON" = true ]; then
            echo "Boxer JSON:"
            echo "$response"| jq .
        fi
    else
        echo "Failed to fetch boxer."
        exit 1
    fi
}

get_weight_class() {
    echo "Fetching weight class..."
    response=$(curl -s -X GET "$BASE_URL/get-weight-class")

    if echo "$response" | grep -q '"status": "success"'; then
        echo "Weight class retrieved successfully."
        if [ "$ECHO_JSON" = true ]; then
            echo "Weight class JSON:"
            echo "$response"| jq .
        fi
    else
        echo "Failed to fetch weight class."
        exit 1
    fi
}

fight() {
    boxer1_id=$1
    boxer2_id=$2

    echo "Starting fight between boxer $boxer1_id and boxer $boxer2_id..."
    response=$(curl -s -X POST "$BASE_URL/fight")

    if echo "$response" | grep -q '"status": "success"'; then
        echo "Fight completed successfully."
        if [ "$ECHO_JSON" = true ]; then
            echo "Fight JSON:"
            echo "$response"| jq .
        fi
    else
        echo "Failed to complete fight."
        exit 1
    fi
}

clear_ring() {
    echo "Clearing the ring..."
    response=$(curl -s -X POST "$BASE_URL/clear-ring")

    if echo "$response" | grep -q '"status": "success"'; then
        echo "Ring cleared successfully."
    else
        echo "Failed to clear the ring."
        exit 1
    fi
}

enter_ring() {
    boxer_id=$1

    echo "Entering ring with boxer ID: $boxer_id"
    response=$(curl -s -X POST "$BASE_URL/enter-ring/$boxer_id")

    if echo "$response" | grep -q '"status": "success"'; then
        echo "Boxer entered the ring successfully."
    else
        echo "Failed to enter the ring."
        exit 1
    fi
}

get_boxers() {
    echo "Fetching all boxers..."
    response=$(curl -s -X GET "$BASE_URL/boxers")
    if echo "$response" | grep -q '"status": "success"'; then
        echo "Boxers retrieved successfully."
        if [ "$ECHO_JSON" = true ]; then
            echo "Boxers JSON:"
            echo "$response"| jq .
        fi
    else
        echo "Failed to fetch boxers."
        exit 1
    fi
}


# Initialize the database
sqlite3 db/boxing.db < sql/init_db.sql

# Health checks
check_health
check_db


# Create boxers
create_boxer "Boxer 1" 180 75 10.0 25
create_boxer "Boxer 2" 175 70 9.5 30
create_boxer "Boxer 3" 185 80 11.0 28
create_boxer "Boxer 4" 170 65 8.5 22

delete_boxer 4

get_boxer_by_id 1
get_boxer_by_name "Boxer 2"

get_weight_class 130

enter_ring 1
enter_ring 2

get_boxers

fight

clear_ring
get_leaderboard


echo "All tests passed successfully."



