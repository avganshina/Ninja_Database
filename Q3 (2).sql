CREATE TEMPORARY TABLE ymd AS
SELECT strftime('%Y',ttime) as year,
	strftime('%M',ttime) as month,
	strftime('%d',ttime) as day,
	attacker_id, defender_id
	from attack;




