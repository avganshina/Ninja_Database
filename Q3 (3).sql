SELECT name, year, count(*)
from ymd, ninja
WHERE ninja.id = attacker_id
GROUP BY attacker_id, year;