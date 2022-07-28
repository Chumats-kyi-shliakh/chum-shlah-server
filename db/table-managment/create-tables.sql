CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgrouting;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

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
	, is_complete BOOL NOT NULL DEFAULT FALSE
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


CREATE TABLE ways_configuration (
      tag_id integer PRIMARY KEY
    , tag_key text DEFAULT 'highway'
    , tag_value text
    , priority real
    , maxspeed integer
    , CONSTRAINT configuration_tag_id_key UNIQUE (tag_id)
    );
CREATE INDEX IF NOT EXISTS  ways_configuration_tag_id_idx
    ON ways_configuration USING btree
    (tag_id ASC NULLS LAST);
    


INSERT INTO ways_configuration (
      tag_id
    , tag_value
    , priority
    , maxspeed
) VALUES
     (100,     'road',                 3,       50)
    ,(101,     'motorway',             1,       130)
    ,(102,     'motorway_link',        1,       130)
    ,(103,     'motorway_junction',    1,       130)
    ,(104,     'trunk',                1.05,    110)
    ,(105,     'trunk_link',           1.05,    110)
    ,(106,     'primary',              1.15,    90)
    ,(107,     'primary_link',         1.15,    90)
    ,(108,     'secondary',            1.5,     90)
    ,(109,     'secondary_link',       1.5,     90)
    ,(110,     'tertiary',             1.75,    90)
    ,(111,     'tertiary_link',        1.75,    90)
    ,(112,     'residential',          2.5,     50)
    ,(113,     'living_street',        3,       20)
    ,(114,     'service',              2.5,     50)
    ,(115,     'unclassified',         3,       90)
    ,(116,     'track',                3,       20)
    ,(117,     'proposed',             -1,      0)
    ,(118,     'destroyed',            -1,      0)
	ON CONFLICT DO NOTHING;
    
    
CREATE TABLE IF NOT EXISTS ways
(
      id serial PRIMARY KEY
    , way_id bigint
    , tag_id bigint REFERENCES ways_configuration
    , osm_source bigint
    , osm_target bigint
    , source bigint
    , target bigint
    , name text
    , destroyed text
    , proposed text
    , length_m real
    , cost_s double precision
    , reverse_cost_s double precision
    , dir text
    , the_geom geometry(Linestring, 4326)
);
CREATE INDEX IF NOT EXISTS ways_geom_idx
    ON ways USING gist
    (the_geom);
-- CREATE INDEX IF NOT EXISTS ways_geog_idx
--     ON ways USING gist
--     (GEOGRAPHY(the_geom));
CREATE INDEX IF NOT EXISTS ways_geom_ua_idx
    ON ways USING gist
    (ST_Transform(the_geom, 5558));
CREATE INDEX IF NOT EXISTS ways_id_idx
    ON ways USING btree
    (way_id ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS ways_tag_id_idx
    ON ways USING btree
    (tag_id ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS ways_source_idx
    ON ways USING btree
    (source ASC NULLS LAST);
CREATE INDEX IF NOT EXISTS ways_target_idx
    ON ways USING btree
    (target ASC NULLS LAST);
    
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
--  , ways
--  , ways_configuration
-- 	;