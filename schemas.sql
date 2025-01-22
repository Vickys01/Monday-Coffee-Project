create database monday_coffee_db


drop table city
drop table customers
drop table products
drop table sales

CREATE TABLE city
(
	city_id	INT PRIMARY KEY,
	city_name VARCHAR(15),	
	population	BIGINT,
	estimated_rent	FLOAT,
	city_rank INT
)



create table customers(

customer_id int primary key,
customer_name varchar(50),
city_id int,
constraint fk_city foreign key (city_id) references city(city_id)
)

CREATE TABLE products
(
	product_id	INT PRIMARY KEY,
	product_name VARCHAR(35),	
	Price float
)

CREATE TABLE sales
(
	sale_id	INT PRIMARY KEY,
	sale_date	date,
	product_id	INT,
	customer_id	INT,
	total FLOAT,
	rating INT,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 
)

Alter table customers add constraint fk_city foreign key (city_id) references city(city_id)

Alter table sales add CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(product_id),
	                 CONSTRAINT fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id) 


select * from customers


