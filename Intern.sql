--Creating data table for columns event_id, event_time, user_id, platform and filtering for column parameter_name for item_id and referrer
--to identify best producing referrer per browsing platform.

SELECT 
  event_id,
  event_time,
  user_id,
  platform,
--filtering table for item_id and referrer occurences, casting item_id to integer, aggregration MAX to consolidate duplicates containing nulls for 
--duplicate occurences of item_id and referrer
  MAX(CASE WHEN parameter_name = 'item_id' 
      THEN cast(parameter_value as int) 
      ELSE NULL END) AS item_id,
  MAX(CASE WHEN parameter_name = 'referrer' 
      THEN parameter_value 
      ELSE NULL 
    END) AS referrer
FROM  
  dsv1069.events
WHERE event_name = 'view_item'
GROUP BY
  event_id,
  event_time,
  user_id,
  platform
--Query Resuts JPEG1

------------------------------------------------

--Identifying best click-throughs
SELECT 
  date(event_time) as date,
  --looking at categorical variables event_time
  event_name,
  COUNT(*)
FROM
  dsv1069.events_ex2
GROUP BY 
  date(event_time),
  event_name
--Chart JPEG 2

--Identifying best click-throughs - platform

SELECT 
  date(event_time) as date,
  --looking at categorical variables platform
  platform,
  COUNT(*)
FROM
  dsv1069.events_ex2
GROUP BY 
  date(event_time),
  platform
--Android and iOS not recorded until March 2017
--Chart JPEG3

-----------------------------------

--Time series, counting new users and accounting for deleted and merged users (merged users create duplicates)
SELECT 
  new.day, 
  new.new_users, 
  deleted.deleted_users,
  merged.merged_users
FROM 
--Subquery and self joins
    (SELECT 
      date(created_at) as day,
      COUNT(*) as new_users
    FROM 
      dsv1069.users
    GROUP BY 
      day) AS new
LEFT JOIN
    (SELECT 
      date(deleted_at) AS day,
      COUNT(*) AS deleted_users
    FROM 
      dsv1069.users
    WHERE deleted_at IS NOT NULL
    GROUP BY
      day) as deleted
ON deleted.day = new.day    
LEFT JOIN    
    (SELECT 
      date(merged_at) as day,
      COUNT(*) as merged_users
    FROM 
      dsv1069.users
    WHERE
      id <> parent_user_id
    AND
      parent_user_id IS NOT NULL
    GROUP BY
      day) AS merged
ON merged.day = new.day      


--7 day rolling sum of orders and count of items ordered.

SELECT 
  dates_rollup.date,
--Coalesce to fill null dates (no orders) with zeros for time series consistency (no missing dates)
  COALESCE(SUM(orders), 0)        AS orders,
  COALESCE(SUM(items_ordered), 0) AS items_ordered,
  COUNT(*) AS days_with_orders --Validating that every week has 7 rows (including days without orders)
FROM 
  dsv1069.dates_rollup
--Left join on subquery
LEFT JOIN
  (
  SELECT 
    DATE(orders.paid_at)          AS day,
    COUNT(Distinct invoice_id)    AS orders,
    COUNT(Distinct line_item_id)  AS items_ordered
  FROM 
    dsv1069.orders
  GROUP BY 
    DATE(orders.paid_at) 
    ) AS daily_orders
ON 
  dates_rollup.date >= daily_orders.day 
AND 
  dates_rollup.d7_ago < daily_orders.day
GROUP BY 
  dates_rollup.date