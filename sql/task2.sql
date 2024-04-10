declare @StartDate DATE;
declare @EndDate DATE;

select 
@StartDate = dateadd(day, 1, eomonth(min(DateOfAdded), -1)), 
@EndDate = dateadd(day, 1, eomonth(max(DateOfAdded), -1))
from dbo.tblClientBalanceOperation;

with
date_range as (
    select @StartDate as month
    union all
    select dateadd(month, 1, month)
    from date_range
    where month <= @EndDate
),
payments_by_month as (
	select
		tcbo.ClientID as client_id,
		dateadd(day, 1, eomonth(tcbo.DateOfAdded, -1)) as month,
		count(*) as number_of_transactions
	from 
		dbo.tblClientBalanceOperation tcbo 
	where 
		tcbo.SignOfPayment = 1
	group by 
		tcbo.ClientID,
		dateadd(day, 1, eomonth(DateOfAdded, -1))
),
clients as (
	select 
		c.CLientID as client_id,
		c.Status as client_status
	from 
		dbo.tblClients c
		left join dbo.tblTestClients tc 
			on c.ClientID = tc.ClientID 
		where 
			tc.ClientID is null
),
agg_by_month_client as (
	select 
		dr.month,
		c.client_id,
		c.client_status,
		coalesce(pbm.number_of_transactions, 0) as number_of_transactions_this_month,
		lag(coalesce(pbm.number_of_transactions, 0)) over (partition by c.client_id order by dr.month) as number_of_transactions_previous_month
	from
		date_range dr
		cross join clients c 
		left join payments_by_month pbm
			on dr.month = pbm.month
			and c.client_id = pbm.client_id
)
select 
	month,
	sum(
		case 
			when number_of_transactions_previous_month > 0 and number_of_transactions_this_month = 0 then 1 else 0 
		end
	) as lost_clients,
	round(100.0 * 
	sum(
		case 
			when number_of_transactions_previous_month > 0 and number_of_transactions_this_month = 0 and client_status = 3 then 1 else 0 
		end
	) /
	sum(
		case 
			when number_of_transactions_previous_month > 0 and number_of_transactions_this_month = 0 then 1 else 0 
		end
	), 2) as lost_clients_deleted_share
from 
	agg_by_month_client
where 
	number_of_transactions_previous_month is not null
group by 
	month
order by 
	month desc
;