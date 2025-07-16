create database major_project_sql;
use major_project_sql;

select * from trade_data2;
select * from company_data1;
select * from stock_priSce_data1;
select * from trader_data1;

-- primary and foriegn key for all tables

desc trade_data;
ALTER TABLE trader_data ADD PRIMARY KEY (trader_id);
ALTER TABLE company_data ADD PRIMARY KEY (company_id);
ALTER TABLE stock_price_data ADD PRIMARY KEY (stock_id);
ALTER TABLE trade_data ADD PRIMARY KEY (trade_id);

select * from company_data1;
desc company_data;
create table company_data1(company_id int primary key, company_name varchar(30), sector varchar(30), market_cap float(2));
desc company_data1;

select * from trader_data;
desc trader_data;
create table trader_data1(trade_id int primary key, trader_name varchar(30), gender varchar(30), age int, location varchar(30), trading_frequency int);
desc trader_data1;
select * from stock_price_data;
desc stock_price_data;

create table stock_price_data1(stock_id int primary key, date varchar(30), open_price float(2), close_price float(2), high_price float(2), low_price float(2), volume_trated int, company_id int);

alter table stock_price_data1
add constraint fk_stock_company
foreign key (company_id)
references company_data1(company_id);

alter table trade_data2
add constraint fk_trade_trader
foreign key (trader_id)
references trader_data1(trader_id);

ALTER TABLE trade_data2
ADD CONSTRAINT fk_trade_stock
FOREIGN KEY (stock_id)
REFERENCES stock_price_data1(stock_id);

select company_id
from stock_price_data
where company_id not in (select company_id from company_data1);

set sql_safe_updates = 0;

delete from stock_price_data
where company_id not in (select company_id from company_data1);
desc trader_data1;
show tables;

alter table trader_data1
change trade_id trader_id int;

alter table trader_data1
modify trader_id varchar(50);

desc trade_data;
desc trader_data1;

alter table trader_data1
modify trader_id int;

select trader_id
from trade_data
where trader_id not in (select trader_id from trader_data1);

delete from trade_data
where trader_id not in (select trader_id from trader_data1);

desc trade_data;
desc stock_price_data;

alter table stock_price_data
drop foreign key fk_stock_company;

alter table trade_data
drop foreign key fk_trade_trader;

drop table company_data1;
drop table stock_price_data;
drop table trader_data1;
drop table trade_data;

alter table trader_data
drop column MyUnknownColumn,
drop column `MyUnknownColumn_[0]`,
drop column `MyUnknownColumn_[1]`;

SELECT DISTINCT stock_id 
FROM trade_data
WHERE stock_id NOT IN (
    SELECT stock_id FROM stock_price_data1
);

DELETE FROM trade_data
WHERE stock_id NOT IN (
    SELECT stock_id FROM stock_price_data1);
drop table stock_price_data;


SELECT DISTINCT stock_id
FROM trade_data
WHERE stock_id NOT IN (
    SELECT stock_id FROM stock_price_data1
);

DELETE FROM trade_data
WHERE stock_id NOT IN (
    SELECT stock_id FROM stock_price_data1
);

SELECT * FROM trade_data
WHERE stock_id NOT IN (SELECT stock_id FROM stock_price_data1);

-- Check for invalid trader_id
SELECT * FROM trade_data
WHERE trader_id NOT IN (SELECT trader_id FROM trader_data1);

-- questions and queries 
-- Which companies have the highest average stock return (close_price - open_price) over time?

select 
    c.company_name,
    round(avg(s.close_price - s.open_price), 2) as avg_daily_return
from stock_price_data1 s
join company_data1 c on s.company_id = c.company_id
where s.open_price is not null and s.close_price is not null
group by c.company_name
order by avg_daily_return desc;

desc trade_data;

truncate table trade_data;

alter table trade_data
modify column trade_id varchar(50) primary key;

alter table trade_data
drop primary key;

select * from trade_data;
drop table company_data1;
desc trade_data2;

-- questions and answers

-- slot1: sector and company overview

-- Q1: Which sector has the most listed companies?
select sector, count(*) as number_of_companies from company_data1 
group by sector order by number_of_companies desc;
  
  
-- Why are more companies listed under the Technology sector compared to other sectors, and what business or market factors—like growth potential, investor interest, and trading activity—make the tech sector more attractive for public listings?
-- What is the average market capitalization of technology companies compared to other sectors?
select sector, avg(market_cap) as avg_market_cap from company_data1 
group by sector order by avg_market_cap DESC;


-- How has the number of new tech companies changed over the years?
select year(str_to_date(sp.date, '%Y-%m-%d')) as year,count(distinct c.company_id) as tech_listings
from stock_price_data1 sp join company_data1 c on sp.company_id = c.company_id
where c.sector = 'technology'group by year(str_to_date(sp.date, '%Y-%m-%d'))order by year;
 
 
select c.sector,  avg(s.volume_trated) as avg_trading_volume  from  stock_price_data1 s
join company_data1 c on s.company_id = c.company_id  group by  c.sector  
order by  avg_trading_volume desc;

SELECT c.sector, COUNT(DISTINCT t.trader_id) AS active_traders FROM trade_data2 t 
JOIN stock_price_data1 s ON t.stock_id = s.stock_id JOIN company_data1 c ON s.company_id = c.company_id 
GROUP BY c.sector ORDER BY active_traders DESC;

select c.sector, avg(s.close_price - s.open_price) as avg_daily_return 
from stock_price_data1 s join company_data1 c on s.company_id = c.company_id 
group by c.sector order by avg_daily_return desc;


 -- about company
 -- A:2 Among top 5 companies, which one shows the highest average stock volatility?
-- Step 1: Get the top 5 companies by market cap using a subquery with ranking
select c.company_name, round(avg(sp.high_price - sp.low_price), 2) as avg_volatility from stock_price_data1 sp
join company_data1 c on sp.company_id = c.company_id join (select company_id from company_data1 order by market_cap desc
limit 5) top_companies on c.company_id = top_companies.company_id group by c.company_name order by avg_volatility desc;


select sp.date, sp.open_price, sp.close_price, round(sp.high_price - sp.low_price, 2) as daily_volatility,
round(sp.close_price - sp.open_price, 2) as daily_return from stock_price_data1 sp
join company_data1 c on sp.company_id = c.company_id where c.company_name = 'pope group' order by sp.date;


select c.company_name, round(avg(sp.high_price - sp.low_price), 2) as avg_volatility,
round(avg(sp.close_price - sp.open_price), 2) as avg_daily_return from stock_price_data1 sp
join company_data1 c on sp.company_id = c.company_id where c.company_name = 'gonzalez-park';

-- 
select c.company_name, c.market_cap, stats.avg_close_price, stats.starting_price, stats.latest_price from company_data1 c join 
(select sp.company_id, round(avg(sp.close_price), 2) as avg_close_price, (select sp1.close_price from stock_price_data1 sp1 
where sp1.company_id = sp.company_id order by sp1.date asc limit 1) as starting_price,(select sp2.close_price from stock_price_data1 sp2 
where sp2.company_id = sp.company_id order by sp2.date desc limit 1) as latest_price from stock_price_data1 sp group by sp.company_id) 
stats on c.company_id = stats.company_id where c.company_name in ('pope group', 'gray plc', 'blair-hill', 'morris, lane and clarke', 'gonzalez-park')
order by c.market_cap desc;


-- Do these companies provide valuable products or services that customers need, which would support the companies' stability and attractiveness to investors? 
select c.company_name, c.sector, sum(td.trade_value) as total_trade_value, avg(td.trade_value) as avg_trade_value,
avg(sp.close_price) as avg_close_price from trade_data2 td join stock_price_data1 sp on td.stock_id = sp.stock_id
join company_data1 c on sp.company_id = c.company_id where c.company_name in ('pope group', 'gray plc', 'blair-hill', 
'morris, lane and clarke', 'gonzalez-park')group by c.company_name, c.sector order by total_trade_value desc;

--  Considering potential gains and losses, do any of these companies align with the investment goals and risk tolerance of businesses or individual customers?
select c.company_name, c.market_cap, ps.avg_volatility, ps.starting_price, ps.latest_price, ps.avg_close_price, coalesce(sum(td.trade_value), 0) 
as total_trade_value from company_data1 c join (select sp.company_id, round(avg(sp.high_price - sp.low_price), 2) as avg_volatility,
(select sp1.close_price from stock_price_data1 sp1 where sp1.company_id = sp.company_id order by sp1.date asc limit 1) as starting_price,
(select sp2.close_price from stock_price_data1 sp2 where sp2.company_id = sp.company_id order by sp2.date desc limit 1) as latest_price,
round(avg(sp.close_price), 2) as avg_close_price from stock_price_data1 sp group by sp.company_id) ps on c.company_id = ps.company_id
left join trade_data2 td on td.stock_id in (select sp3.stock_id from stock_price_data1 sp3 where sp3.company_id = c.company_id)
where c.company_name in ('pope group','gray plc','blair-hill','morris, lane and clarke','gonzalez-park')group by c.company_name,c.market_cap,
ps.avg_volatility, ps.starting_price, ps.latest_price, ps.avg_close_price order by total_trade_value desc;


-- slot 3:-Trader behavior and demand

-- q1:  Which age group trades the most in terms of total trade value?
select case when age < 25 then 'under 25'when age between 25 and 40 then '25-40' when age between 41 and 60 then '41-60'
else '60+' end as age_group, sum(td.trade_value) as total_trade_value from trade_data2 td join trader_data1 t on td.trader_id = t.trader_id
group by age_group order by total_trade_value desc;


select case when age between 25 and 40 then '25-40' when age between 41 and 60 then '41-60' end as age_group,
round(avg(trading_frequency), 2) as avg_trading_frequency from trader_data1 where age between 25 and 60
group by age_group;

-- Is the average trade value per transaction higher for the 41–60 age group?
select case when t.age between 25 and 40 then '25-40' when t.age between 41 and 60 then '41-60' end as age_group,
round(avg(td.trade_value), 2) as avg_trade_value_per_trade from trade_data2 td join trader_data1 t on td.trader_id = t.trader_id
where t.age between 25 and 60 group by age_group;
 
 
select t.location, '41-60' as age_group, sum(td.trade_value) as total_trade_value from trade_data2 td 
join trader_data1 t  on td.trader_id = t.trader_id
where t.age between 41 and 60 group by t.location order by total_trade_value desc limit 5;


select c.sector, case when t.age between 25 and 40 then '25-40' when t.age between 41 and 60 then '41-60' end as age_group,
sum(td.trade_value) as total_trade_value from trade_data2 td join trader_data1 t on td.trader_id = t.trader_id
join stock_price_data1 sp on td.stock_id = sp.stock_id join company_data1 c on sp.company_id = c.company_id where t.age between 25 and 60
group by c.sector, age_group order by c.sector, total_trade_value desc;

-- slot 4: stock demands
-- Is there a strong correlation between trade volume and stock price volatility?
select s.stock_id, round(avg(s.volume_trated), 2) as avg_volume, round(avg(s.high_price - s.low_price), 2) as avg_volatility
from stock_price_data1 s group by s.stock_id order by avg_volatility desc;

-- slot 5 :-sector
-- Which sector has the lowest average stock price and lowest trade volume?
select c.sector, round(avg(sp.close_price), 2) as avg_price, round(avg(sp.volume_trated), 2) as avg_volume
from stock_price_data1 sp join company_data1 c on sp.company_id = c.company_id group by c.sector order by avg_price asc;
 
 -- what factors make the energy sector appealing for first-time or low-budget investors?
select c.company_name, round(avg(sp.close_price), 2) as avg_close_price, round(avg(sp.high_price - sp.low_price), 2) as avg_volatility
from stock_price_data1 sp join company_data1 c on sp.company_id = c.company_id where c.sector = 'energy'
group by c.company_name order by avg_close_price asc limit 5;

 -- why is the trading volume low despite the low stock price?
 select c.company_name, round(avg(sp.close_price), 2) as avg_price, round(avg(sp.volume_trated), 2) as avg_volume,
sum(td.trade_value) as total_trade_value from stock_price_data1 sp join company_data1 c on sp.company_id = c.company_id
left join trade_data2 td on sp.stock_id = td.stock_id where c.sector = 'energy' group by c.company_name
order by total_trade_value asc limit 5;
	
 
 
 -- how can targeted marketing or investment education increase interest in the energy sector?
select c.company_name, count(td.trade_value) as trade_value_count from stock_price_data1 sp
join company_data1 c on sp.company_id = c.company_id left join trade_data2 td on sp.stock_id = td.stock_id
where c.sector = 'energy' group by c.company_name order by trade_value_count desc limit 5;
 
 
 -- what kind of investment products or plans can be built around the energy sector to engage new investors? 
select c.company_name, round(min(sp.close_price), 2) as lowest_price, round(avg(sp.close_price), 2) as avg_price
from stock_price_data1 sp join company_data1 c on sp.company_id = c.company_id where c.sector = 'energy'
group by c.company_name order by lowest_price asc limit 5;
