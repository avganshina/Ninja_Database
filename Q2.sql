SELECT n1.name as "Attacker", n2.name as "Defender", count(*) as "Number of attacks"
FROM ninja n1, ninja n2, attack
WHERE n1.id = attack.attacker_id and n2.id = attack.defender_id
GROUP BY n1.name, n2.name
ORDER BY count(*)