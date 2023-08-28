create database case3;
use case3;

## Q1 How many different nodes make up the Data Bank network?

select count(distinct(node_id)) as 'unique_nodes' from customer_nodes;

##Q2 How many nodes are there in each region?

select regions.Region_id, region_name, count(node_id) as 'no_of_nodes' from regions, customer_nodes
where regions.region_id = customer_nodes.region_id
group by region_name, regions.region_id
order by region_id asc;

##Q3 How many customers are divided among the regions?

select region_name, count(distinct(customer_id)) as 'no_of_customers' from customer_nodes
inner join regions using(region_id)
group by region_name;

##Q4 Determine the total amount of transactions for each region name.

select region_name, sum(txn_amount) as 'Total_amt_of_txn' from regions, customer_transactions, customer_nodes
where customer_nodes.region_id = regions.region_id and customer_nodes.customer_id = customer_transactions.customer_id
group by region_name;

##Q5 How long does it take on an average to move clients to a new node?

select (round(avg(datediff(end_date,start_date)),2)) as 'avg_time_to_move_norde' from customer_nodes
where end_date!= '9999-12-31';

##Q6 What is the unique count and total amount for each transaction type?

select txn_type, count(txn_type) as 'count_txn_type', sum(txn_amount) as 'Total_amt' from customer_transactions
group by txn_type;

##Q7 What is the average number and size of past deposits across all customers?

SELECT round(count(customer_id)/(SELECT count(DISTINCT customer_id)
FROM customer_transactions)) AS average_deposit_count,
concat('$', round(avg(txn_amount), 2)) AS average_deposit_amount
FROM customer_transactions
WHERE txn_type = "deposit";

##Q8 For each month - how many Data Bank cust make more than 1 deposit and at least either 1 purchase or 1 withdrawal in a single month?

WITH transaction_count_per_month_cte AS
  (SELECT customer_id,
          month(txn_date) AS txn_month,
          SUM(IF(txn_type="deposit", 1, 0)) AS deposit_count,
          SUM(IF(txn_type="withdrawal", 1, 0)) AS withdrawal_count,
          SUM(IF(txn_type="purchase", 1, 0)) AS purchase_count
   FROM customer_transactions
   GROUP BY customer_id,
            month(txn_date))
SELECT txn_month,
       count(DISTINCT customer_id) as customer_count
FROM transaction_count_per_month_cte
WHERE deposit_count>1
  AND (purchase_count = 1
       OR withdrawal_count = 1)
GROUP BY txn_month;