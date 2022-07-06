INSERT INTO funds (fund_id, fund_name, tg_bot_key, creation_date, change_time)
SELECT DISTINCT ON (fund_name)
      area_id AS fund_id
    , tags ->> 'name' AS fund_name
    , floor(random() * 10000) AS tg_bot_key
    , now() as creation_date
    , now() as change_time
FROM public.polygons
WHERE 
        tags ->> 'name' IS NOT NULL 
    AND tags ->> 'shop' = 'mall'
    ;

INSERT INTO storages (
      storage_id
    , storage_name
    , geom
    , postcode
    , district
    , city
    , street
    , house_number
    , creation_date
    , change_time
	, fund_id)
SELECT
      area_id as storage_id
    , tags ->> 'name' AS storage_name
    , ST_Centroid(geom) AS geom
	, substring(tags ->> 'addr:postcode' from '[0-9]')::int AS postcode
    , tags ->> 'addr:district' AS district
    , tags ->> 'addr:city' AS city
    , tags ->> 'addr:street' AS street
    , tags ->> 'addr:housenumber' AS house_number
    , now() as creation_date
    , now() as change_time
	, area_id as fund_id
FROM public.polygons
LEFT JOIN public.funds on funds.fund_id = area_id
WHERE funds.fund_id is not null
    ;
    
INSERT INTO product_categories (category_id, category_name, category_thumbnail) 
    VALUES 
      (100, 'Медикаменти','https://bulma.io/images/placeholders/600x480.png')
    , (200, 'Спорядження','https://bulma.io/images/placeholders/800x480.png')
    , (300, 'Прдукти харчування','https://bulma.io/images/placeholders/480x640.png')
    ;
    

INSERT INTO products (
    product_name
    , weight
    , height
    , width
    , length
    , creation_date
    , change_time
	, category_id
    ) 
VALUES ( 
        'Бинт еластичний'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
		, 100
       ),
       ( 
        'Фізрозчин'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
	    , 100
       ),
       ( 
        'Мотопомпа'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
		, 200
       ),
       ( 
        'Ігрова приставка PS5 PlayStation 5'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
		, 200
       ),
       ( 
        'Сублімовані продукти'
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , floor(random() * 10)
        , now()
        , now()
  	    , 300
       );

DO $$
BEGIN
    FOR i IN 1..(SELECT COUNT(storage_id) * 2 FROM storages)
    LOOP
        INSERT INTO public.stocks 
        (
           quantity
         , creation_date
         , change_time
		 , storage_id
         , product_id
		)
        SELECT 
              floor( random() * 50) AS quantity
            , now() AS created_at
            , now() AS updated_at
            , storage_id
            , product_id
        FROM storages
        CROSS JOIN (
            SELECT product_id
            FROM products 
            OFFSET floor(
                random() * (
                    SELECT COUNT(product_id)
                    FROM products
                    )
                ) 
            LIMIT 1) prod
        OFFSET floor(
            random() * (
                SELECT COUNT(storage_id) 
                FROM storages
                )
            ) 
        LIMIT 1
            ON CONFLICT DO NOTHING;
    END LOOP;
END$$;


INSERT INTO drivers ( driver_login
                     , driver_pswhash 
					 , phone_number
                     , creation_date
					 , change_time
                     , last_online
                    ) VALUES
      ('test_driver_1', crypt('test_driver_1_password'
    , gen_salt('bf')),'0332322323', now(), now(), now())
    , ('test_driver_2', crypt('test_driver_2_password'
    , gen_salt('bf')),'0221211212' , now(), now(), now())
    ;
    
	
	
	

INSERT INTO customers (
      customer_id
    , customer_name
    , geom
    , postcode
    , district
    , city
    , street
    , house_number
    , creation_date
    , change_time)
SELECT
      area_id as customer_id
    , tags ->> 'name' AS customer_name
    , ST_Centroid(geom) AS geom
	, substring(tags ->> 'addr:postcode' from '[0-9]')::int AS postcode
    , tags ->> 'addr:district' AS district
    , tags ->> 'addr:city' AS city
    , tags ->> 'addr:street' AS street
    , tags ->> 'addr:housenumber' AS house_number
    , now() as creation_date
    , now() as change_time
FROM public.polygons
WHERE 
        tags ->> 'name' IS NOT NULL 
   AND (tags ->> 'amenity' in ('townhall', 'government')
    OR tags ->> 'office' = 'government'
    OR tags ->> 'building' = 'government')
	;

DO $$
BEGIN
    FOR i IN 1..(SELECT COUNT(customer_id) * 2 FROM customers)
    LOOP
        INSERT INTO public.order_basket 
        (
           creation_date
         , change_time
		 , customer_id)
        SELECT 

             now() AS creation_date
            , now() AS change_time
			, customer_id
        FROM customers
        OFFSET floor(
            random() * (
                SELECT COUNT(customer_id) 
                FROM customers
                )
            ) 
        LIMIT 1
            ON CONFLICT DO NOTHING;
    END LOOP;
END$$;


DO $$
BEGIN
    FOR i IN 1..(SELECT COUNT(basket_id) * 2 FROM order_basket)
    LOOP
        INSERT INTO public.order_items 
        (
           quantity
         , creation_date
         , change_time
		 , basket_id
		 , product_id
		)
        SELECT 

             floor( random() * 10) AS quantit
            , now() AS creation_date
            , now() AS change_time
			, basket_id
			, product_id
        FROM public.order_basket
        CROSS JOIN (
            SELECT product_id
            FROM products 
            OFFSET floor(
                random() * (
                    SELECT COUNT(product_id)
                    FROM products
                    )
                ) 
            LIMIT 1) prod
        OFFSET floor(
            random() * (
                SELECT COUNT(basket_id) 
                FROM order_basket
                )
            ) 
        LIMIT 1
            ON CONFLICT DO NOTHING;
    END LOOP;
END$$;
