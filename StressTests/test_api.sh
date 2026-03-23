BASE="http://localhost:8080"
JSON="Content-Type: application/json"

U1="tester1"
U2="tester2"
P1="pass123"
P2="pass123"

echo "=== REGISTER USER 1 ==="
curl -s -X POST "$BASE/api/register" \
  -H "$JSON" \
  -d "{\"username\":\"$U1\",\"email\":\"$U1@example.com\",\"password\":\"$P1\",\"referral_code\":\"\"}"
echo
echo

echo "=== REGISTER USER 2 ==="
curl -s -X POST "$BASE/api/register" \
  -H "$JSON" \
  -d "{\"username\":\"$U2\",\"email\":\"$U2@example.com\",\"password\":\"$P2\",\"referral_code\":\"\"}"
echo
echo

echo "=== LOGIN USER 1 ==="
TOKEN1=$(curl -s -X POST "$BASE/api/login" \
  -H "$JSON" \
  -d "{\"username\":\"$U1\",\"password\":\"$P1\"}" \
  | sed -E 's/.*"token":"([^"]+)".*/\1/')
echo "$TOKEN1"
echo

echo "=== LOGIN USER 2 ==="
TOKEN2=$(curl -s -X POST "$BASE/api/login" \
  -H "$JSON" \
  -d "{\"username\":\"$U2\",\"password\":\"$P2\"}" \
  | sed -E 's/.*"token":"([^"]+)".*/\1/')
echo "$TOKEN2"
echo

echo "=== PUBLIC PRACTICE ==="
curl -s -X POST "$BASE/api/practice?letters=ABCD&lang=en"
echo
echo

echo "=== USERS ==="
curl -s "$BASE/api/users" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== PROFILE ==="
curl -s "$BASE/api/profile" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== LESSONS ==="
curl -s "$BASE/api/lessons?lang=en" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== LESSON BY ID ==="
curl -s "$BASE/api/lessons/1?lang=en" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== PRACTICE BY LESSON ==="
curl -s "$BASE/api/practice/1?lang=en" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== PRACTICE SUBMIT ==="
curl -s -X POST "$BASE/api/practice/submit" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "$JSON" \
  -d '[{"symbol":"A","correct":3,"wrong":1},{"symbol":"B","correct":2,"wrong":0}]'
echo
echo

echo "=== FREEMODE ==="
curl -s "$BASE/api/freemode?lang=en&letters=ABCD&mode=text&count=5" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== COMPLETE LESSON 1 ==="
curl -s -X POST "$BASE/api/complete-lesson?lang=en" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "$JSON" \
  -d '{"lesson_id":1}'
echo
echo

echo "=== FRIENDS LIST (BEFORE ADD) ==="
curl -s "$BASE/api/friends" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== ADD FRIEND ==="
curl -s -X POST "$BASE/api/friends/add" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "$JSON" \
  -d "{\"friend\":\"$U2\"}"
echo
echo

echo "=== FRIENDS LIST (AFTER ADD) ==="
curl -s "$BASE/api/friends" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== UPDATE FRIENDSHIP STREAKS ==="
curl -s -X POST "$BASE/api/friends/update-streaks" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== FRIENDSHIP STREAKS (ONLY ME) ==="
curl -s "$BASE/api/friendship-streaks?me=true" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== DELETE FRIEND ==="
curl -s -X POST "$BASE/api/friends/delete" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "$JSON" \
  -d "{\"friend\":\"$U2\"}"
echo
echo

echo "=== REPLAY LESSON ==="
curl -s "$BASE/api/practice/replay/1?lang=en" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== CREATE DUEL ==="
DUEL_ID=$(curl -s -X POST "$BASE/api/duel/create" \
  -H "Authorization: Bearer $TOKEN1" \
  | sed -E 's/.*"id":"([^"]+)".*/\1/')
echo "$DUEL_ID"
echo

echo "=== JOIN DUEL ==="
curl -s -X POST "$BASE/api/duel/join" \
  -H "Authorization: Bearer $TOKEN2"
echo
echo

echo "=== DUELS LIST ==="
curl -s "$BASE/api/duels" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== DUEL STATUS ==="
curl -s "$BASE/api/duels/status/$DUEL_ID" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== DUEL TASKS ==="
curl -s -X POST "$BASE/api/duels/get-tasks/$DUEL_ID?lang=en" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== USER 1 SUBMIT DUEL SCORE ==="
curl -s -X POST "$BASE/api/duels/get-score/$DUEL_ID" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "$JSON" \
  -d '{"score":42}'
echo
echo

echo "=== USER 2 SUBMIT DUEL SCORE ==="
curl -s -X POST "$BASE/api/duels/get-score/$DUEL_ID" \
  -H "Authorization: Bearer $TOKEN2" \
  -H "$JSON" \
  -d '{"score":35}'
echo
echo

echo "=== DUEL STATUS AFTER SCORES ==="
curl -s "$BASE/api/duels/status/$DUEL_ID" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== FINISH DUEL AS USER 1 ==="
curl -s -X POST "$BASE/api/duels/finish/$DUEL_ID" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== FINISH DUEL AS USER 2 ==="
curl -s -X POST "$BASE/api/duels/finish/$DUEL_ID" \
  -H "Authorization: Bearer $TOKEN2"
echo
echo

echo "=== CREATE SECOND DUEL FOR LEAVE TEST ==="
DUEL2_ID=$(curl -s -X POST "$BASE/api/duel/create" \
  -H "Authorization: Bearer $TOKEN1" \
  | sed -E 's/.*"id":"([^"]+)".*/\1/')
echo "$DUEL2_ID"
echo

echo "=== LEAVE SECOND DUEL ==="
curl -s -X POST "$BASE/api/duels/leave/$DUEL2_ID" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo

echo "=== SECOND DUEL STATUS ==="
curl -s "$BASE/api/duels/status/$DUEL2_ID" \
  -H "Authorization: Bearer $TOKEN1"
echo
echo