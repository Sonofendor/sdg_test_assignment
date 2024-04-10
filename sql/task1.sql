with 
payments as (
	select 
		ClientID as client_id,
		BalanceOperationID as payment_id,
		DateOfAdded as payment_dttm,
		Amount as payment_amount,
		row_number() over (partition by ClientID order by DateOfAdded asc) as payment_number,
		row_number() over (partition by ClientID order by DateOfAdded desc) as payment_number_desc,
		lead(DateOfAdded) over (partition by ClientID order by DateOfAdded asc) as next_payment_dttm,
		min(DateOfAdded) over (partition by ClientID) as first_payment_dttm
	from 
		dbo.tblClientBalanceOperation tcbo 
	where 
		SignOfPayment = 1
),
first_payment as (
	select
		client_id,
		convert(date, payment_dttm) as payment_date,
		payment_amount
	from 
		payments 
	where 
		payment_number = 1
),
second_payment as (
	select
		client_id,
		convert(date, payment_dttm) as payment_date,
		payment_amount
	from 
		payments 
	where 
		payment_number = 2
),
last_payment as (
	select
		client_id,
		convert(date, payment_dttm) as payment_date,
		payment_amount
	from 
		payments 
	where 
		payment_number_desc	 = 1
),
first_month_totals as (
	select 
		client_id,
		sum(payment_amount) as amount
	from 
		payments
	where 
		DATEDIFF(MONTH, first_payment_dttm, payment_dttm) < 1
	group by 
		client_id
),
days_between_payments as (
	select 
		client_id,
		avg(DATEDIFF(DAY, payment_dttm, next_payment_dttm)) as average_days_between_payments
	from 
		payments
	group by 
		client_id
)
select 
	c.ClientID as client_id,
	fp.payment_date as first_payment_date,
	fp.payment_amount as first_payment_amount,
	sp.payment_date as second_payment_date,
	sp.payment_amount as second_payment_amount,
	lp.payment_date as last_payment_date,
	datediff(day, fp.payment_date, sp.payment_date) as days_between_first_and_second_payments,
	dbp.average_days_between_payments
from 
	dbo.tblClients c
	left join dbo.tblTestClients tc 
		on c.ClientID = tc.ClientID 
	left join first_payment fp 
		on c.ClientID = fp.client_id
	left join second_payment sp 
		on c.ClientID = sp.client_id
	left join last_payment lp 
		on c.ClientID = lp.client_id
	left join days_between_payments dbp 
		on c.ClientID = dbp.client_id
where 
	tc.ClientID is null
;