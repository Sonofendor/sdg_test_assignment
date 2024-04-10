with 
first_payments as (
	select 
		ClientID as client_id,
		min(DateOfAdded) as first_payment_dttm
	from 
		dbo.tblClientBalanceOperation 
	where 
		SignOfPayment = 1
	group by 
		ClientID 
),
pre as (
	select 
		sum(case when datediff(week, c.DateOfAdded, fp.first_payment_dttm) = 0 then 1 else 0 end) as first_week,
		sum(case when datediff(week, c.DateOfAdded, fp.first_payment_dttm) = 1 then 1 else 0 end) as second_week,
		sum(case when datediff(week, c.DateOfAdded, fp.first_payment_dttm) = 2 then 1 else 0 end) as third_week,
		sum(case when datediff(week, c.DateOfAdded, fp.first_payment_dttm) >= 3 then 1 else 0 end) as other_week,
		count(*) as total
	from 
		dbo.tblClients c 
		left join dbo.tblTestClients tc 
			on c.ClientID = tc.ClientID
		join first_payments fp
			on c.ClientID = fp.client_id
	where 
		tc.ClientID is null
)
select 
	first_week,
	round(first_week * 100.0 / total, 2) as first_week_share,
	second_week,
	round(second_week * 100.0 / total, 2) as second_week_share,
	third_week,
	round(third_week * 100.0 / total, 2) as third_week_share,
	other_week,
	round(other_week * 100.0 / total, 2) as other_week_share
from 
	pre
;