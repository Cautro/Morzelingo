#!/bin/bash

BASE="http://localhost:8080/api"
USERS=5000

echo "=============================="
echo " MORZELINGO MEGA STRESS TEST"
echo "=============================="

rm -f tokens.txt
rm -f duel_ids.txt

################################
echo "1️⃣ REGISTER $USERS USERS"
################################

for i in $(seq 1 $USERS)
do
curl -s -X POST "$BASE/register" \
-H "Content-Type: application/json" \
-d "{
\"username\":\"mega$i\",
\"email\":\"mega$i@test.com\",
\"password\":\"123456\"
}" > /dev/null &
done

wait
echo "✔ REGISTER DONE"


################################
echo "2️⃣ LOGIN USERS"
################################

for i in $(seq 1 $USERS)
do

TOKEN=$(curl -s -X POST "$BASE/login" \
-H "Content-Type: application/json" \
-d "{
\"username\":\"mega$i\",
\"password\":\"123456\"
}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo $TOKEN >> ./StressTests/tokens.txt

done

echo "✔ LOGIN DONE"


################################
echo "3️⃣ PROFILE TEST"
################################

while read TOKEN
do
curl -s "$BASE/profile" \
-H "Authorization: Bearer $TOKEN" > /dev/null &
done < tokens.txt

wait
echo "✔ PROFILE OK"


################################
echo "4️⃣ USERS LIST"
################################

TOKEN=$(head -1 tokens.txt)

curl -s "$BASE/users" \
-H "Authorization: Bearer $TOKEN" > /dev/null

echo "✔ USERS OK"


################################
echo "5️⃣ LESSONS LOAD"
################################

while read TOKEN
do
curl -s "$BASE/lessons?lang=en" \
-H "Authorization: Bearer $TOKEN" > /dev/null &
done < tokens.txt

wait
echo "✔ LESSONS OK"


################################
echo "6️⃣ PRACTICE LOAD"
################################

while read TOKEN
do
curl -s "$BASE/practice/1?lang=en" \
-H "Authorization: Bearer $TOKEN" > /dev/null &
done < tokens.txt

wait
echo "✔ PRACTICE OK"


################################
echo "7️⃣ FREEMODE LOAD"
################################

while read TOKEN
do
curl -s "$BASE/freemode?lang=en&count=5" \
-H "Authorization: Bearer $TOKEN" > /dev/null &
done < tokens.txt

wait
echo "✔ FREEMODE OK"


################################
echo "8️⃣ FRIENDS ADD"
################################

TOKEN1=$(sed -n '1p' tokens.txt)
TOKEN2=$(sed -n '2p' tokens.txt)

curl -s -X POST "$BASE/friends/add" \
-H "Authorization: Bearer $TOKEN1" \
-H "Content-Type: application/json" \
-d '{"friend":"mega2"}' > /dev/null

curl -s "$BASE/friends" \
-H "Authorization: Bearer $TOKEN1" > /dev/null

echo "✔ FRIENDS OK"


################################
echo "9️⃣ DUEL CREATE"
################################

head -500 tokens.txt | while read TOKEN
do

ID=$(curl -s -X POST "$BASE/duel/create" \
-H "Authorization: Bearer $TOKEN" \
| grep -o '"id":"[^"]*"' | cut -d'"' -f4)

echo $ID >> ./StessTests/duel_ids.txt &

done

wait
echo "✔ DUELS CREATED"


################################
echo "🔟 DUEL JOIN"
################################

paste -d' ' <(tail -500 tokens.txt) duel_ids.txt | while read TOKEN ID
do

curl -s -X POST "$BASE/duel/join" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done

wait

echo "✔ DUELS JOINED"


################################
echo "11️⃣ GET DUEL TASKS"
################################

paste -d' ' tokens.txt duel_ids.txt | while read TOKEN ID
do

curl -s "$BASE/duels/get-tasks/$ID?lang=en" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done

wait

echo "✔ TASKS OK"


################################
echo "12️⃣ FINISH DUELS"
################################

paste -d' ' tokens.txt duel_ids.txt | while read TOKEN ID
do

curl -s -X POST "$BASE/duels/finish/$ID" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done

wait

echo "✔ DUELS FINISHED"


################################
echo "13️⃣ MASSIVE RANDOM LOAD"
################################

for i in {1..5000}
do

TOKEN=$(shuf -n 1 tokens.txt)

R=$((RANDOM % 5))

if [ $R -eq 0 ]; then
curl -s "$BASE/freemode?count=3" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

if [ $R -eq 1 ]; then
curl -s "$BASE/practice/1" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

if [ $R -eq 2 ]; then
curl -s "$BASE/lessons?lang=en" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

if [ $R -eq 3 ]; then
curl -s "$BASE/profile" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

if [ $R -eq 4 ]; then
curl -s "$BASE/freemode?count=5" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

done

wait

echo "✔ RANDOM LOAD OK"

echo ""
echo "=============================="
echo "🚀 1000 USERS TEST COMPLETED"
echo "=============================="