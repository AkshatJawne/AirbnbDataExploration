-- PRELIMINARY STEPS

-- 1. Loading data into PostgreSQL from local csv file

select * from "exploration";

COPY "exploration" FROM '/Users/akshatjawne/Desktop/Airbnb_Open_Data.csv' DELIMITER ',' CSV HEADER ;

-- DATA CLEANING

-- 1. Improve table column names to make naming conventions consistent

ALTER TABLE "exploration"
RENAME COLUMN "NAME" TO property_description;

ALTER TABLE "exploration"
RENAME COLUMN "host id" TO "host_id";

ALTER TABLE "exploration"
RENAME COLUMN "neighbourhood group" TO "borough";

ALTER TABLE "exploration"
RENAME COLUMN "country code" TO "country_code";

ALTER TABLE "exploration"
RENAME COLUMN "room type" TO "room_type";

ALTER TABLE "exploration"
RENAME COLUMN "Construction year" TO "construction_year";

ALTER TABLE "exploration"
RENAME COLUMN "service fee" TO "service_fee";

ALTER TABLE "exploration"
RENAME COLUMN "minimum nights" TO "minimum_nights";

ALTER TABLE "exploration"
RENAME COLUMN "number of reviews" TO "number_of_reviews";

ALTER TABLE "exploration"
RENAME COLUMN "last review" TO "date_of_last_review";

ALTER TABLE "exploration"
RENAME COLUMN "reviews per month" TO "reviews_per_month";

ALTER TABLE "exploration"
RENAME COLUMN "review rate number" TO "review_score";

ALTER TABLE "exploration"
RENAME COLUMN "calculated host listings count" TO "host_listings_count";

ALTER TABLE "exploration"
RENAME COLUMN "availability 365" TO "availability_365";

-- 2. Remove License column given that it has no data 

ALTER TABLE "exploration"
DROP COLUMN "license";

-- 3. Removing host_id columns given unique nature of propeties identified with id

ALTER TABLE "exploration"
DROP COLUMN "host_id";

-- 4. Fixing blanks in country and country code columns given all data is from NYC

UPDATE "exploration"
SET country = 'United States'
WHERE country IS NULL;

UPDATE "exploration"
SET country_code = 'US'
WHERE country_code IS NULL;

-- 5. Fixing borough inputs where spelling is messed up in dataset

UPDATE "exploration"
SET borough = 'Brooklyn'
WHERE borough = 'brookln';

UPDATE "exploration"
SET borough = 'Manhattan'
WHERE borough = 'manhatan';

-- EXPLORATORY DATA ANALYSIS 

-- 1. Which neighbourhood has the highest number of listings? 

SELECT "neighbourhood", COUNT("neighbourhood") FROM "airbnb_exploration" 
GROUP BY "neighbourhood" ORDER BY COUNT(neighbourhood) DESC LIMIT 1;

-- 2. What is the percent distribution of different room types?

SELECT "room_type", COUNT(*) AS "room_info",
COUNT(*) * 100.0/ SUM(COUNT(*)) OVER () AS "room_percent"
FROM "exploration"
GROUP BY "room_type" ORDER BY COUNT("room_type") DESC;

-- 3. What is the spread of cancellation types in different boroughs? 
--    How do the average listing prices compare on the policy?

SELECT "cancellation_policy", "borough", COUNT (*) AS "cancellation_info"
FROM "exploration" WHERE "borough" IS NOT NULL
GROUP BY "cancellation_policy", "borough" ORDER BY COUNT ("cancellation_policy") DESC;

-- 4. Is there a relationship between the construction year and the price?

SELECT "construction_year", AVG(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer) 
AS "average_price", ROUND(STDDEV(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer), 
2) AS "standard_deviation"
FROM "exploration"
GROUP BY "construction_year" ;

-- 5. How do keywords (identified by linked study) impact average property price?

SELECT 'location' as "word", AVG(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer) as "average_price" 
FROM "exploration" WHERE property_description ~ 'location'
UNION ALL 
SELECT 'apartment' as "word", AVG(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer) as "average_price" 
FROM "exploration" WHERE property_description ~ 'apartment'
UNION ALL
SELECT 'clean' as "word", AVG(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer) as "average_price" 
FROM "exploration" WHERE property_description ~ 'clean'
UNION ALL
SELECT 'center' as "word", AVG(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer) as "average_price" 
FROM "exploration" WHERE property_description ~ 'center'
UNION ALL
SELECT 'room' as "word", AVG(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer) as "average_price" 
FROM "exploration" WHERE property_description ~ 'room'
UNION ALL
SELECT 'all properties' as "word", AVG(TRIM( TRAILING FROM (REPLACE(REPLACE(price, ',', ''), '$', '')))::integer) as "average_price" 
FROM "exploration"
ORDER BY average_price DESC;

