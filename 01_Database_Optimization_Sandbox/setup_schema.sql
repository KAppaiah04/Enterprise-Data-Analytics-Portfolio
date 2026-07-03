-- create inventory master table
CREATE TABLE inventory_stock (
    stock_id INTEGER PRIMARY KEY,
    sku TEXT NOT NULL,
    item_description TEXT,
    quantity integer DEFAULT 0,
    location_code text not NULL,
    date_recived text not NULL

);

-- create warehous location master table
create table warehouse_locations(
    location_code text primary key,
    zone text not null, 
    aisle_number integer,
    shelf_level integer
)

-- checking the mock generated data of stock
select * from inventory_stock;

-- finding the oldest stock in the warehouse
select sku, item_description, quantity, location_code, date_recived
from inventory_stock
order by date_recived;

    -- finding inventory aging and velocity means demanding of product
SELECT sku,
    item_description,
    quantity,
    location_code,
    date_recived,
        -- calculating how many days the item is sitting in warehouse
    ROUND((julianday('now') - julianday(date_recived)),2) as days_in_warehouse,
        -- lableing them based on demand
        CASE
            WHEN (julianday('now') - julianday(date_recived)) <= 7 THEN "Fast - High Demand"
            WHEN (julianday('now') - julianday(date_recived)) <= 20 THEN 'Medium - Steady Demand'
            ELSE 'Slow - Demand'
        END as demand_level,
        COUNT(*) as total_items,
        SUM(quantity) as total_physical_units
FROM inventory_stock
GROUP BY demand_level
ORDER BY total_items DESC;

-- Checking Fast demand items are sitting in right place or trapped in warehouse 

SELECT
    i.sku,
    i.item_description,
    i.quantity,
    i.location_code,
    w.aisle_number,
    w.shelf_level,
    (julianday('now') - julianday(date_recived)) as days_in_warehouse,
    CASE
        WHEN (julianday('now')- julianday(date_recived)) <= 7 THEN 'Fast - High Demand'
        WHEN (julianday('now')- julianday(date_recived)) <= 20 THEN 'Medium - Steady Demand'
        ELSE 'Slow - Demand'
    END as buisness_demand_status
    FROM
    inventory_stock i
    JOIN  warehouse_locations w ON i.location_code = w.location_code
    WHERE buisness_demand_status = 'Fast - High Demand'
    ORDER BY w.aisle_number DESC;


-- Calculating the financial or labor loss imapcting
SELECT
    i.sku,
    i.item_description,
    i.quantity,
    i.location_code,
    w.aisle_number,
    w.shelf_level,
    -- a simple math to calculate travel difficulty score
    (w.aisle_number * 3) + (w.shelf_level * 5) as travel_difficulty_score
FROM
    inventory_stock i
JOIN warehouse_locations w ON i.location_code = w.location_code
WHERE (julianday('now') - julianday(date_recived)) <=7
ORDER BY travel_difficulty_score;


-- Re slotting to propose solution
SELECT
    i.sku,
    i.item_description,
    i.location_code as current_location,
    w.aisle_number as current_aisle,
    w.shelf_level as current_shelf,
    (w.aisle_number * 3) + (w.shelf_level * 5) as current_difficulty_score,
    -- propsing an optimized target location strategy based on higher demand
    CASE
        WHEN (w.aisle_number * 3) + (w.shelf_level * 5) >= 40 THEN 'Critical Action- Relocate to Aisle 01 or 02 (Ground level)'
        WHEN (w.aisle_number * 3) + (w.shelf_level * 5) >= 25 THEN 'Recommend : Move to Mid-Aisle (Shelf 1-2)'
        ELSE 'OK : Leave in Current optimal position'
    END as operational_action_plan
FROM
    inventory_stock i
JOIN warehouse_locations w ON i.location_code = w.location_code
WHERE (julianday('now') - julianday(i.date_recived)) <=7 
ORDER BY current_difficulty_score DESC;

-- ROI Simulation query

SELECT
    COUNT (*) as total_high_demand_records,
    SUM ((w.aisle_number * 3) + (w.shelf_level * 5 )) as total_diffiuclty_score,
    --calculate the difficulty drops if we actually move demand items
    SUM (
        CASE
            WHEN (w.aisle_number * 3) + (w.shelf_level * 5) >= 40 THEN 8 -- optimised score
            ELSE (w.aisle_number * 3) + (w.shelf_level * 5)
        END
    ) as total_optimized_difficulty,
    -- figure out percentage reduction in labor /movement friction
    ROUND (
        (1.0 - (SUM(CASE WHEN (w.aisle_number * 3)+(w.shelf_level * 5) >= 40 THEN 8 ELSE (w.aisle_number*3)+(w.shelf_level*5) ENd)* 1.0/ SUM((w.aisle_number * 3)+(w.shelf_level*5)))) * 100,2
    ) AS labor_friction_reduction_percentage 
FROM
inventory_stock i 
JOIN warehouse_locations w on i.location_code = w.location_code
WHERE (julianday('now') - julianday(date_recived)) <= 7;




