CREATE TABLE IF NOT EXISTS funds (
	  fund_id serial PRIMARY KEY
	, fund_name varchar(250) NOT NULL
	, tg_bot_key varchar(250) NOT NULL
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
);


CREATE TABLE IF NOT EXISTS storages (
	  storage_id serial PRIMARY KEY
	, storage_name varchar(250) NOT NULL
	, geom GEOMETRY(POINT,4326)
	, postcode int
	, district varchar(50) 
	, city varchar(50) 
	, street varchar(50) 
	, house_number varchar(50) 
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, fund_id int REFERENCES funds 	
	ON DELETE CASCADE 
	ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS product_categories (
	  category_id int PRIMARY KEY
	, category_name varchar(50) 
	, category_thumbnail text
);


CREATE TABLE IF NOT EXISTS products (
	  product_id serial PRIMARY KEY
	, product_name varchar(250) 
	, weight varchar(10)
	, height varchar(10)
	, width varchar(10)
	, length varchar(10)
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, category_id int REFERENCES product_categories 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS stocks (
	  stock_id serial PRIMARY KEY
	, quantity int NOT NULL CHECK (quantity >= 0)
	, creation_date timestamp with time zone DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, storage_id int REFERENCES storages 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
	, product_id int REFERENCES products 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS customers (
	  customer_id serial PRIMARY KEY
	, customer_name varchar(250) 
	, geom GEOMETRY(POINT,4326)
	, postcode int
	, district varchar(50) 
	, city varchar(50) 
	, street varchar(50) 
	, house_number varchar(50) 
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
);


CREATE TABLE IF NOT EXISTS order_basket (
	  basket_id serial PRIMARY KEY
	, completed BOOL NOT NULL DEFAULT FALSE
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, customer_id int REFERENCES customers 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS order_items (
	  item_id serial PRIMARY KEY
	, quantity int NOT NULL CHECK (quantity >= 0) 
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, is_complete  BOOL NOT NULL DEFAULT FALSE
	, product_id int REFERENCES products 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
	, basket_id int REFERENCES order_basket 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS drivers (
	  driver_id UUID PRIMARY KEY DEFAULT gen_random_uuid()
	, driver_login varchar(250) NOT NULL
	, driver_pswhash TEXT NOT NULL
	, phone_number varchar(25) NOT NULL
	, is_online BOOL NOT NULL DEFAULT FALSE
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, last_online timestamp with time zone NOT NULL
);


CREATE TABLE IF NOT EXISTS active_delivery (
	  delivery_id UUID PRIMARY KEY DEFAULT gen_random_uuid()
	, is_complete BOOL NOT NULL DEFAULT FALSE
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, driver_id uuid REFERENCES drivers 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS delivery_items (
	  d_item_id serial PRIMARY KEY
	, is_outdated BOOL NOT NULL DEFAULT FALSE
	, is_complete BOOL NOT NULL DEFAULT FALSE	
	, quantity int NOT NULL CHECK (quantity >= 0)
	, creation_date timestamp with time zone NOT NULL DEFAULT now()
	, change_time timestamp with time zone NOT NULL
	, delivery_id uuid REFERENCES active_delivery 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
	, item_id int REFERENCES order_items 
	ON DELETE CASCADE 
	ON UPDATE CASCADE
	, stock_id int REFERENCES stocks 
	ON DELETE CASCADE 
	ON UPDATE CASCADE

);

-- DROP TABLE IF EXISTS
-- 	delivery_items
-- 	, active_delivery
-- 	, drivers
-- 	, order_items
-- 	, order_basket
-- 	, customers
-- 	, stocks
-- 	, products
-- 	, product_categories
-- 	, storages
-- 	, funds
-- 	;