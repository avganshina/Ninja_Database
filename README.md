# Ninja_Database
Code written in SQL - Link to the database file: https://drive.google.com/file/d/1pqW_7MHHtd5iwtbACjdJTZ4qRhosuDeO/view?usp=sharing

Anastasia Ganshina - Ninja Queries

Table of Contents:

Question 1 - Damage Profile
Question 2 - Ninja Attacks
Question 3 - Time of Attacks
Question 4 - Random Times
Question 5 - Correct HITPCT
Question 6 - Favorite Weapon

--------------------------------------------------------------------------------------------------------------------------------------------------
_**Question 1: **_
_Figure out the damage profile for each weapon. Weapons have a minimum and a maximum amount of damage, and the damage is either randomly chosen between the two values (i.e. each number between the minimum and maximum has an equal probability) or it’s normally distributed (i.e. a Gaussian distribution, where the middle values are more common than the extremes)._
--------------------------------------------------------------------------------------------------------------------------------------------------
First, to see what the minimum and the maximum damage of each weapon is, the following query is produced:

Q1 (1) -  in attachments

SELECT weapon.name, weapon.mindamage, weapon.maxdamage
FROM weapon

Result:
katana		3	24
shuriken	1	8
nunchaku	1	11
blowgun	2	20
wakizashi	4	9
harsh words	2	16
sai		2	20
kakute		2	12
naginate	3	10
Atomic	3	24

To see the whether the damage profile of each weapon is normally distributed or randomly chosen, following query is created: 
Q1 (2) -  in attachments

SELECT weapon.name, weapon.mindamage, weapon.maxdamage, attack.damage as "actual damage", count(*)
FROM weapon, attack
WHERE weapon.id = attack.weapon_id
GROUP BY attack.damage
ORDER BY weapon.name, count(*)

Result:

atomic leg drop	3	24	24	54
atomic leg drop	3	24	21	472
atomic leg drop	3	24	20	1121
atomic leg drop	3	24	19	1776
atomic leg drop	3	24	17	3336
atomic leg drop	3	24	16	4210
atomic leg drop	3	24	11	10586
atomic leg drop	3	24	8	17047

blowgun		2	20	5	13936

harsh words		2	16	14	5774

kakute			2	12	12	7149
kakute			2	12	4	13249
katana			3	24	23	148
katana			3	24	22	281
katana			3	24	15	5130
Katana			3	24	13	6439

naginate		3	10	6	15268

nunchaku		1	11	1	4374
nunchaku		1	11	3	8544
nunchaku		1	11	10	12336
nunchaku		1	11	7	16439

sai			2	20	18	2648
sai			2	20	0	128636

shuriken		1	8	2	5336

wakizashi		4	9	9	15711

The result shows that some weapons (wakizashi, shuriken, sai, naginate, harsh words, blowgun) have only one damage value, if the attack is successful

Others have more than one distinct value:

atomic leg drop, Katana, kakute damage is chosen by normal distribution as we can see that in the majority of times the value is close to the middle value

--------------------------------------------------------------------------------------------------------------------------------------------------
_**Question 2: **
Figure out the likelihood of each ninja attacking every other ninja. Do some ninjas really like to attack some other ninjas, or not like to attack other ninjas?
In order to see the tendencies of ninjas to attack other ninjas, the following query is produced:_
--------------------------------------------------------------------------------------------------------------------------------------------------

Q2 -  in attachments

SELECT n1.name as "Attacker", n2.name as "Defender", count(*) as "Number of attacks"
FROM ninja n1, ninja n2, attack
WHERE n1.id = attack.attacker_id and n2.id = attack.defender_id
GROUP BY n1.name, n2.name
ORDER BY count(*)

This query returns the name of the attacker,  the name of the defender and the number of attacks as well as orders the lines by the numbers of attacks to see what ninjas fight the most.

Results:

petri	- 	zerubabel	- 	125	- 	which means petri does not attack zerubabel that often
…
…
…
petri	-	nana		-	8920	-	which means petri likes to attack nana the most

--------------------------------------------------------------------------------------------------------------------------------------------------
_**Question 3:**
When does each ninja prefer to attack? Do some ninjas not attack on some days, months, or years?_
--------------------------------------------------------------------------------------------------------------------------------------------------

To see when all the attacks were attempted by each ninja, the following query is produced:

Q3 (1) -  in attachments

		SELECT Ninja.name as "Attacker", Attack.ttime
FROM Ninja, attack

This query although answers the question “When does each ninja prefer to attack?”, shows too many results to comprehend.  

To do that, we first need to create a temporary table that will contain the year and the month of the attack:

Q3 (2) -  in attachments

CREATE TEMPORARY TABLE ymd AS
SELECT strftime('%Y',ttime) as year,
	strftime('%M',ttime) as month,
	strftime('%d',ttime) as day,
	attacker_id, defender_id
	from attack;

To see if there are any ninjas that do not attack at specific years, the following query is produces:

Q3 (3) -  in attachments

SELECT name, year, count(*)
from ymd, ninja
WHERE ninja.id = attacker_id
GROUP BY attacker_id, year;

Results show that every ninja have done 1400-1600 attacks each year with no exceptions.

The following query shows if there are any anomalies for months:

Q3 (4) -  in attachments

SELECT name, month, count(*)
from ymd, ninja
WHERE ninja.id = attacker_id
GROUP BY attacker_id, month;

Results show that each ninja does 250 - 350 attacks every month with no exceptions

The following query shows if there are any anomalies for days and months:

Q3 (5) -  in attachments

SELECT name, day, month, count(*)
from ymd, ninja
WHERE ninja.id = attacker_id
GROUP BY attacker_id, month, day;

THe results do not show any preferences of any ninjas for any day

--------------------------------------------------------------------------------------------------------------------------------------------------
_**Question 4:**
The time of day (hour, minute, second) of attacks was randomly chosen. How can you verify this? Does this seem to be the case?_
--------------------------------------------------------------------------------------------------------------------------------------------------

In order to see whether the time was chosen randomly, the following query is executed:
Q4 -  in attachments
select hour, minute, second, count(*)
from (select strftime('%H',ttime) as hour,
strftime('%M',ttime) as minute,
strftime('%s',ttime) as second
from attack)
group by hour, minute

The result shows that each hour, each minute and each second got approximately the same number of attacks (within error margin). This shows that ninjas have no preferences at any specific time and, therefore, the time was chosen randomly.

--------------------------------------------------------------------------------------------------------------------------------------------------
_**Question 5:**

Is the hitpct (i.e. the likelihood of a successful attack with a weapon) in the weapons table accurate for each weapon? The value for hitpct in the weapon table may not match the observed data in the attack table._
--------------------------------------------------------------------------------------------------------------------------------------------------

In order to see whether the hitpct shows the right result, we first need to see the value of hitpct for each weapon.

Q5 (1) -  in attachments

SELECT weapon.name, weapon.hitpct
FROM weapon

Result: 

katana			0.57
shuriken		0.71
nunchaku		0.63
blowgun		0.39
wakizashi		0.69
harsh words		0.49
sai			0.74
kakute			0.38
naginate		0.5
atomic leg drop	0.58


To calculate the actual hitpct, we need to divide the number of successful attacks to the number of all attacks:

Q5 (2) -  in attachments

SELECT weapon.name, SUM(success)/(count(*) * 1.0) as "Actual hitpct"
FROM  attack, weapon
WHERE attack.weapon_id = weapon.id
GROUP BY attack.weapon_id

Result: 

Katana			0.635823486214033	0.57
shuriken		0.71408833198342	0.71
nunchaku		0.706746396049922	0.63
blowgun		0.392015877147319	0.39
wakizashi		0.628833386025925	0.69
harsh words		0.398535004930272	0.49
sai			0.740465960342665	0.74
kakute			0.380050505050505	0.38
naginate		0.596011131725417	0.5
atomic leg drop	0.519161636030659	0.58

As a result, only shuriken, blowgun, sai, kakute have the correct hitpct.

--------------------------------------------------------------------------------------------------------------------------------------------------
**_Question 6:**

What is each ninja’s likelihood of using each weapon? Do some ninjas not like to use certain weapons, or prefer to use one or more weapons significantly more than others?_
--------------------------------------------------------------------------------------------------------------------------------------------------

To see what ninjas prefer to use what weapons, the following query is produced:

SELECT n1.name as "Attacker", Weapon.name, count(*) as "Number of Attacks"
FROM ninja n1, attack a1, Weapon
WHERE n1.id = a1.attacker_id
AND a1.weapon_id = Weapon.id
GROUP BY n1.name, weapon.name
ORDER BY n1.name, count(*)

This query returns the name of the ninja, what weapons this ninja used and how many times.

Results:


bob	katana			1310
bob	wakizashi		1331
bob	nunchaku		1347
bob	harsh words		1349
bob	shuriken		1352
bob	blowgun		1357
bob	naginate		1359
bob	kakute			1397
bob	atomic leg drop	2784
bob	sai			3956

carlos	katana			316
carlos	atomic leg drop	372
carlos	shuriken		660
carlos	naginate		695
carlos	nunchaku		1040
carlos	kakute			1068
carlos	harsh words		1442
carlos	blowgun		1444
carlos	wakizashi		1793
carlos	sai			8845

Deandre katana		359
Deandre atomic leg drop	378
Deandre huriken		712
Deandre naginate		741
Deandre blowgun		1025
Deandre kakute		1066
Deandre wakizashi		1390
Deandre sai			1393
Deandre harsh words		1749
Deandre nunchaku		8842

erika	naginate		344
erika	katana			355
erika	shuriken		653
erika	kakute			702
erika	nunchaku		1016
erika	sai			1037
erika	harsh words		1432
erika	blowgun		1436
erika	wakizashi		1825
erika	atomic leg drop	8745

gina	sai			1042
gina	katana			1045
gina	wakizashi		1078
gina	nunchaku		1121
gina	atomic leg drop	2034
gina	blowgun		2054
gina	kakute		2071
gina	shuriken	2133
gina	naginate	2134
gina	harsh words	3088

hai	katana		361
hai	atomic 		395
hai	shuriken	714
hai	naginate	715
hai	blowgun	1069
hai	kakute		1071
hai	wakizashi	1391
hai	sai		1397
hai	harsh words	1746
hai	nunchaku	8831

jess	katana		610
jess	atomic		625
jess	naginate	1191
jess	shuriken	1196
jess	nunchaku	1736
jess	kakute		1846
jess	sai		2279
jess	blowgun	2336
jess	harsh words	2862
jess	wakizashi	3083

kiva	nunchaku	1012
kiva	harsh words	1055
kiva	atomic		1065
kiva	wakizashi	1092
kiva	naginate	2043
kiva	shuriken	2059
kiva	kakute		2085
kiva	katana		2120
kiva	blowgun	2130
kiva	sai		3093

Leonardo atomic leg drop	516
leonardo	katana	578
leonardo	naginate	1181
leonardo	shuriken	1245
leonardo	kakute	1695
leonardo	nunchaku	1732
leonardo	sai	2324
leonardo	blowgun	2377
leonardo	harsh words	2921
leonardo	wakizashi	3015

nana	atomic leg drop	586
nana	katana	588
nana	naginate	1159
nana	shuriken	1161
nana	kakute	1790
nana	nunchaku	1808
nana	blowgun	2288
nana	sai	2307
nana	harsh words	2941
nana	wakizashi	2969

petri	shuriken	1326
petri	katana	1357
petri	sai	1367
petri	blowgun	1393
petri	naginate	1395
petri	harsh words	1410
petri	atomic leg drop	1411
petri	kakute	2670
petri	wakizashi	2706
petri	nunchaku	2814

quianna	atomic leg drop	313
quianna	katana	386
quianna	kakute	703
quianna	shuriken	711
quianna	nunchaku	1030
quianna	sai	1040
quianna	harsh words	1383
quianna	blowgun	1422
quianna	wakizashi	1772
quianna	naginate	8776

salvador	wakizashi	1314
salvador	shuriken	1318
salvador	sai	1320
salvador	katana	1323
salvador	kakute	1341
salvador	nunchaku	1346
salvador	blowgun	1350
salvador	naginate	1383
salvador	harsh words	2683
salvador	atomic leg drop	3998

thu	atomic leg drop	575
thu	katana	621
thu	shuriken	1197
thu	naginate	1214
thu	kakute	1769
thu	nunchaku	1780
thu	blowgun	2329
thu	sai	2368
thu	harsh words	2900
thu	wakizashi	2929

violet	wakizashi	1530
violet	shuriken	1580
violet	nunchaku	1591
violet	harsh words	1614
violet	naginate	1614
violet	katana	1615
violet	sai	1638
violet	blowgun	1652
violet	atomic leg drop	1665
violet	kakute	3118

wu	katana	1133
wu	sai	1145
wu	shuriken	1152
wu	naginate	1155
wu	harsh words	1165
wu	atomic leg drop	1180
wu	nunchaku	2333
wu	blowgun	2341
wu	kakute	2392
wu	wakizashi	3680

zerubabel	katana	902
zerubabel	sai	920
zerubabel	nunchaku	924
zerubabel	naginate	929
zerubabel	kakute	936
zerubabel	shuriken	1820
zerubabel	wakizashi	1895
zerubabel	blowgun	2733
zerubabel	atomic leg drop	2844
zerubabel	harsh words	3755

This means that each ninja has a favorite weapon and the least favorite weapon.

This means that each ninja has a favorite weapon and the least favorite weapon.
