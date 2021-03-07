SELECT weapon.name, SUM(success)/(count(*) * 1.0) as "Actual hitpct", weapon.hitpct
FROM  attack, weapon
WHERE attack.weapon_id = weapon.id
GROUP BY attack.weapon_id
