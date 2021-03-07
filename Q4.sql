select hour, minute, second, count(*)
from (select strftime('%H',ttime) as hour,
	strftime('%M',ttime) as minute,
	strftime('%s',ttime) as second
	from attack)
group by hour, minute
