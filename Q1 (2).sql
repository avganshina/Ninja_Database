SELECT weapon.name, weapon.mindamage, weapon.maxdamage, attack.damage as "actual damage", count(*)
FROM weapon, attack
WHERE weapon.id = attack.weapon_id
GROUP BY attack.damage
ORDER BY weapon.name, count(*)