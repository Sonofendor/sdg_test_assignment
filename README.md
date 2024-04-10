# sdg_test_assignment
Test assignment for Senior Data Engineer position at Social Discovery Group by Artem Grishechko

**Structure:**
* data/ -- SQL Server db backup
* results/ -- csv files with results of queries
* sql/ -- sql files with queries
* compose.yaml -- Docker compose file
* scripts.txt -- additional scripts for setup

## Task Description
### Task 1
Вывести детализацию по клиенту:
1. ID клиента
2. Дата и сумма первой покупки
3. Дата и сумма повторной (следующей после первой) покупки
4. Дата последней покупки
5. Сумма покупок, совершенных в течение месяца после первой покупки
6. Время (кол-во дней) между первой и повторной покупкой
7. Среднее время (кол-во дней) между покупками

### Task 2
Количество потерянных клиентов по месяцам.
Потерянным клиентом считается тот, который совершал покупки в предыдущем месяце, но не совершал в текущем.  Какой % из этих потерянных клиентов находятся в статусе Deleted? 

### Task 3
Сколько клиентов совершают первую покупку в первую неделю с регистрации на сайте, сколько во вторую неделю, сколько на третьей неделе и сколько позже? (вывести абсолютные значения и доли)


### Описание таблиц 
**tblClients** – информация о клиентах.
Поле Status может принимать следующие значения:
```sql
,case [Status]
		when 1 then 'Active'
		when 2 then 'Updated by client'
		when 3 then 'Deleted'
		when 4 then 'Passive'
		else cast([Status] as nvarchar(3))
	end ClientStatus
```

**tblCountryNames** – названия стран на разных языках, в подготовке статистики используется английское название cn.CultureID=1

**tblTestClients** – содержит клиентов, которые используются для тестирования новых продуктов, этих клиентов следует исключать из статистики

**tblClientBalanceOperation** – транзакции покупок клиентов
_BalanceOperationID_ – идентификатор покупки
_ClientID_ – идентификатор клиента
_Amount_ – сумма покупки в $
_SignOfPayment_ – признак того, что покупка прошла успешно или безуспешно (SignOfPayment=1 – успешная покупка)

**tblOnlineSessions_mini** – отображает присутствие клиента онлайн
_[OnlineTime]_ – дата входа на сайт
_[OfflineTime]_ – дата выхода в оффлайн
