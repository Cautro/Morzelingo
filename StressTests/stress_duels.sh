#!/bin/bash

BASE="http://localhost:8080/api"
DUELS=2147483647
PARALLEL=2147483647

echo "Starting duel stress test"
echo "Duels: $DUELS"
echo "Parallel: $PARALLEL"

create_user() {
  USER=$1

  curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$BASE/register" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"email\":\"$USER@test.com\",\"password\":\"123456\"}"
}

login_user() {
  USER=$1

  curl -s \
  -X POST "$BASE/login" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER\",\"password\":\"123456\"}" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

create_duel() {
  TOKEN=$1

  curl -s \
  -X POST "$BASE/duel/create" \
  -H "Authorization: Bearer $TOKEN" \
  | sed -n 's/.*"id":"\([^"]*\)".*/\1/p'
}

join_duel() {
  TOKEN=$1
  DUEL=$2

  curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$BASE/duel/join/$DUEL" \
  -H "Authorization: Bearer $TOKEN"
}

get_tasks() {
  TOKEN=$1
  DUEL=$2

  curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$BASE/duels/get-tasks/$DUEL?lang=en" \
  -H "Authorization: Bearer $TOKEN"
}

send_score() {
  TOKEN=$1
  DUEL=$2

  SCORE=$((RANDOM % 200))

  curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$BASE/duels/get-score/$DUEL" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"score\":$SCORE}"
}

finish_duel() {
  TOKEN=$1
  DUEL=$2

  curl -s -o /dev/null -w "%{http_code}" \
  -X POST "$BASE/duels/finish/$DUEL" \
  -H "Authorization: Bearer $TOKEN"
}

run_duel() {

  ID=$1

  U1="stress_user_$((ID*2))"
  U2="stress_user_$((ID*2+1))"

  echo "[$ID] creating users"

  create_user $U1 > /dev/null
  create_user $U2 > /dev/null

  T1=$(login_user $U1)
  T2=$(login_user $U2)

  if [ -z "$T1" ] || [ -z "$T2" ]; then
    echo "[$ID] login failed"
    exit
  fi

  DUEL=$(create_duel $T1)

  if [ -z "$DUEL" ]; then
    echo "[$ID] duel create failed"
    exit
  fi

  join_duel $T2 $DUEL > /dev/null

  get_tasks $T1 $DUEL > /dev/null
  get_tasks $T2 $DUEL > /dev/null

  send_score $T1 $DUEL > /dev/null
  send_score $T2 $DUEL > /dev/null

  finish_duel $T1 $DUEL > /dev/null
  finish_duel $T2 $DUEL > /dev/null

  echo "[$ID] duel finished"
}

export -f create_user
export -f login_user
export -f create_duel
export -f join_duel
export -f get_tasks
export -f send_score
export -f finish_duel
export -f run_duel
export BASE

seq 1 $DUELS | xargs -P $PARALLEL -I {} bash -c 'run_duel "$@"' _ {}

echo "Stress test finished"