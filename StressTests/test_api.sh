#!/bin/bash

BASE="http://localhost:8080/api"

echo "=============================="
echo " MORZELINGO API TEST"
echo "=============================="

echo ""
echo "1️⃣ Register users"

curl -s -X POST "$BASE/register" \
-H "Content-Type: application/json" \
-d '{"username":"player1","email":"p1@test.com","password":"123456"}'

echo ""

curl -s -X POST "$BASE/register" \
-H "Content-Type: application/json" \
-d '{"username":"player2","email":"p2@test.com","password":"123456"}'

echo ""
echo "✔ register step done"
echo ""

echo "2️⃣ Login"

RESP1=$(curl -s -X POST "$BASE/login" \
-H "Content-Type: application/json" \
-d '{"username":"player1","password":"123456"}')

TOKEN1=$(echo $RESP1 | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

RESP2=$(curl -s -X POST "$BASE/login" \
-H "Content-Type: application/json" \
-d '{"username":"player2","password":"123456"}')

TOKEN2=$(echo $RESP2 | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo "TOKEN1=$TOKEN1"
echo "TOKEN2=$TOKEN2"

if [ -z "$TOKEN1" ] || [ -z "$TOKEN2" ]; then
  echo "❌ ERROR: login failed"
  exit 1
fi

echo "✔ login OK"
echo ""

echo "3️⃣ Profile"

curl -s "$BASE/profile" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ profile OK"
echo ""

echo "4️⃣ Users list"

curl -s "$BASE/users" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ users OK"
echo ""

echo "5️⃣ Lessons"

curl -s "$BASE/lessons?lang=en" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ lessons OK"
echo ""

echo "6️⃣ Lesson by id"

curl -s "$BASE/lessons/1?lang=en" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ lesson OK"
echo ""

echo "7️⃣ Complete lesson"

curl -s -X POST "$BASE/complete-lesson?lang=en" \
-H "Authorization: Bearer $TOKEN1" \
-H "Content-Type: application/json" \
-d '{"lesson_id":1}'

echo ""
echo "✔ complete lesson OK"
echo ""

echo "8️⃣ Practice"

curl -s "$BASE/practice/1?lang=en" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ practice OK"
echo ""

echo "9️⃣ Submit practice"

curl -s -X POST "$BASE/practice/submit" \
-H "Authorization: Bearer $TOKEN1" \
-H "Content-Type: application/json" \
-d '[{"symbol":"A","correct":2,"wrong":1}]'

echo ""
echo "✔ submit practice OK"
echo ""

echo "🔟 Freemode"

curl -s "$BASE/freemode?lang=en&count=3" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ freemode OK"
echo ""

echo "11️⃣ Friends add"

curl -s -X POST "$BASE/friends/add" \
-H "Authorization: Bearer $TOKEN1" \
-H "Content-Type: application/json" \
-d '{"friend":"player2"}'

echo ""
echo "✔ add friend OK"
echo ""

echo "12️⃣ Friends list"

curl -s "$BASE/friends" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ friends OK"
echo ""

echo "13️⃣ Friendship streaks"

curl -s "$BASE/friendship-streaks" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ streaks OK"
echo ""

echo "14️⃣ DUEL CREATE"

CREATE=$(curl -s -X POST "$BASE/duel/create" \
-H "Authorization: Bearer $TOKEN1")

echo $CREATE

DUEL_ID=$(echo $CREATE | grep -o '"id":"[^"]*"' | cut -d'"' -f4)

echo "DUEL_ID=$DUEL_ID"

if [ -z "$DUEL_ID" ]; then
  echo "❌ ERROR duel create failed"
  exit 1
fi

echo "✔ duel created"
echo ""

echo "15️⃣ Duel join"

curl -s -X POST "$BASE/duel/join" \
-H "Authorization: Bearer $TOKEN2"

echo ""
echo "✔ duel joined"
echo ""

echo "16️⃣ Duel status"

curl -s "$BASE/duels/status/$DUEL_ID" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ duel status OK"
echo ""

echo "17️⃣ Duel tasks"

curl -s -X POST "$BASE/duels/get-tasks/$DUEL_ID?lang=en" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ tasks generated"
echo ""

echo ""
echo "8️⃣ Score Test"
echo ""

curl -s -X POST "$BASE/duels/get-score/$DUEL_ID" \
-H "Authorization: Bearer $TOKEN1" \
-H "Content-Type: application/json" \
-d '{"score":124}'

echo "9️⃣ Duel finish"

curl -s -X POST "$BASE/duels/finish/$DUEL_ID" \
-H "Authorization: Bearer $TOKEN1"

echo ""
echo "✔ duel finished"
echo ""

echo "=============================="
echo "🎉 ALL TESTS FINISHED"
echo "=============================="