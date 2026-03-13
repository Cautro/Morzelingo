#!/bin/bash

BASE="http://localhost:8080/api"
USERS=50000

echo "=============================="
echo " MORZELINGO PRO STRESS TEST"
echo "=============================="

rm -f tokens.txt

################################
echo ""
echo "1️⃣ Creating users"
################################

for i in $(seq 1 $USERS)
do

curl -s -X POST "$BASE/register" \
-H "Content-Type: application/json" \
-d "{
\"username\":\"load$i\",
\"email\":\"load$i@test.com\",
\"password\":\"123456\"
}" > /dev/null &

done

wait

echo "✔ users created"


################################
echo ""
echo "2️⃣ Login users"
################################

for i in $(seq 1 $USERS)
do

TOKEN=$(curl -s -X POST "$BASE/login" \
-H "Content-Type: application/json" \
-d "{
\"username\":\"load$i\",
\"password\":\"123456\"
}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

echo $TOKEN >> tokens.txt

done

echo "✔ tokens saved"


################################
echo ""
echo "3️⃣ Freemode load"
################################

while read TOKEN
do

curl -s "$BASE/freemode?count=5" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done < tokens.txt

wait

echo "✔ freemode OK"


################################
echo ""
echo "4️⃣ Practice load"
################################

while read TOKEN
do

curl -s "$BASE/practice/1" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done < tokens.txt

wait

echo "✔ practice OK"


################################
echo ""
echo "5️⃣ Lessons load"
################################

while read TOKEN
do

curl -s "$BASE/lessons?lang=en" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done < tokens.txt

wait

echo "✔ lessons OK"


################################
echo ""
echo "6️⃣ Duel creation"
################################

head -50 tokens.txt | while read TOKEN
do

curl -s -X POST "$BASE/duel/create" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done

wait

echo "✔ duels created"


################################
echo ""
echo "7️⃣ Duel join"
################################

tail -50 tokens.txt | while read TOKEN
do

curl -s -X POST "$BASE/duel/join" \
-H "Authorization: Bearer $TOKEN" > /dev/null &

done

wait

echo "✔ duels joined"


################################
echo ""
echo "8️⃣ Massive mixed load"
################################

for i in {1..1000}
do

TOKEN=$(shuf -n 1 tokens.txt)

R=$((RANDOM % 3))

if [ $R -eq 0 ]; then
curl -s "$BASE/freemode?count=3" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

if [ $R -eq 1 ]; then
curl -s "$BASE/practice/1" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

if [ $R -eq 2 ]; then
curl -s "$BASE/lessons?lang=en" -H "Authorization: Bearer $TOKEN" > /dev/null &
fi

done

wait

echo "✔ mixed load OK"

echo ""
echo "=============================="
echo "🚀 STRESS TEST COMPLETED"
echo "=============================="