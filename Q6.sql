SELECT n1.name as "Attacker", Weapon.name, count(*) as "Number of Attacks"
FROM ninja n1, attack a1, Weapon
WHERE n1.id = a1.attacker_id
AND a1.weapon_id = Weapon.id
GROUP BY n1.name, weapon.name
ORDER BY n1.name, count(*)