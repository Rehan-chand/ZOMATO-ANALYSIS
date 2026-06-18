

SELECT * FROM COUNTRY_TABLE ;

SELECT * FROM ZOMATO_TABLE ;

------------------------------------------------------------------------------------------------------------------
# 1) COUNTRY TABLE 

SELECT * FROM country_table ;

#  OR 

SELECT DISTINCT(A.COUNTRYCODE) , B.COUNTRY_NAME 
FROM zomato_table AS A LEFT JOIN country_table AS B
ON A.CountryCode=B.Country_Code
order by CountryCode asc ;

--------------------------------------------------------------------------------------------------------------------------

# 2) CALENDER TABLE

SELECT  
         distinct(Datekey_Opening) , 
         year(Datekey_Opening) AS YEAR ,
         month(Datekey_Opening) AS MONTH_NO ,
         monthname(Datekey_Opening) AS MONTH_NAME ,
         concat("Q" , quarter(Datekey_Opening) ) AS QUARTER ,
         CONCAT(year(Datekey_Opening),"-",DATE_FORMAT(Datekey_Opening,"%b")) AS YR_MTH ,
         weekday(Datekey_Opening) AS WEEKDAY_NO ,
         dayname(Datekey_Opening) AS WEEKDAY_NAME ,
         CONCAT("FM","-", month(adddate(Datekey_Opening,interval -3 month)) ) AS FINANCIAL_MONTH ,
		 CONCAT("FQ","-", QUARTER(adddate(Datekey_Opening,interval -1 QUARTER)) ) AS FINANCIAL_QUARTER
FROM zomato_table
order by Datekey_Opening ASC ;

------------------------------------------------------------------------------------------------------------------------------------------------------

# 3) NUMBER OF RESTAURENTS BASED ON COUNTRY AND CITY 


WITH CITIES AS
     ( 
        SELECT  
               A.COUNTRYCODE AS CONTRY_CODE ,
               B.COUNTRY_NAME AS CONTRY_NAME ,
	           A.CITY AS CITY,
	           COUNT(A.RestaurantID) AS NO_RES_CITY
        FROM ZOMATO_TABLE AS A LEFT JOIN country_table AS B
        ON A.CountryCode = B.Country_Code
        GROUP BY A.COUNTRYCODE , B.Country_Name , A.CITY 
        ORDER BY A.COUNTRYCODE , B.Country_Name , A.CITY ASC 
	  ) 

SELECT  
       CONTRY_CODE ,
       CONTRY_NAME ,
       SUM(NO_RES_CITY) OVER ( partition by CONTRY_CODE , CONTRY_NAME) AS NO_RES_COUNTRY ,
       CITY ,
       NO_RES_CITY , 
	   SUM(NO_RES_CITY) OVER () AS TOTAL_NO_RES 
 FROM CITIES ;

---------------------------------------------------------------------------------------------------------------------------------------------------

# 4) NUMBER OF RESTAURENTS OPENED BASED ON YEAR , QUARTER , MONTH 

SELECT DISTINCT
    Opening_Year,
    Year_Count,
    Opening_Quarter,
    Quarter_Count,
    Opening_Month,
    Month_Count,
    Total_Restaurants
FROM (
        SELECT
               YEAR(Datekey_Opening) AS opening_year,
               QUARTER(Datekey_Opening) AS opening_quarter,
               MONTH(Datekey_Opening) AS opening_month,

               COUNT(RESTAURANTID) OVER ( PARTITION BY YEAR(Datekey_Opening) ) AS year_count,

               COUNT(RESTAURANTID) OVER ( PARTITION BY YEAR(Datekey_Opening), QUARTER(Datekey_Opening) ) AS quarter_count,

               COUNT(RESTAURANTID) OVER ( PARTITION BY YEAR(Datekey_Opening), QUARTER(Datekey_Opening), MONTH(Datekey_Opening) ) AS month_count,
               
			   COUNT(RESTAURANTID) OVER () AS total_restaurants
        
        FROM ZOMATO_TABLE
        
     ) AS OPENING_TABLE

ORDER BY opening_year , opening_quarter , opening_month ;


------------------------------------------------------------------------------------------------------------------------------------------------------

# 5) Count of Resturants based on Average Ratings				

select
case
	 when rating >= 1 and rating<2  then "1-2" 
     when rating >= 2 and rating<3  then "2-3" 
     when rating >= 3 and rating<4  then "3-4" 
     when rating >= 4 and rating<=5 then "4-5" 
end as Ratings ,
count(restaurantid) as Restaurant_Count
from zomato_table 
group by ratings 
order by ratings asc;


---------------------------------------------------------------------------------------------------------------------------------------------------------

# 6) Create buckets based on Average Price of reasonable size and find out how many resturants falls in each buckets										

SELECT
CASE 
     WHEN AVERAGE_COST_FOR_TWO = 0       THEN "N/A"
     WHEN AVERAGE_COST_FOR_TWO > 0       AND  AVERAGE_COST_FOR_TWO <= 200    THEN "1) 0-200" 
     WHEN AVERAGE_COST_FOR_TWO > 200     AND  AVERAGE_COST_FOR_TWO <= 500    THEN "2) 200-500" 
     WHEN AVERAGE_COST_FOR_TWO > 500     AND  AVERAGE_COST_FOR_TWO <= 1000   THEN "3) 500-1K" 
     WHEN AVERAGE_COST_FOR_TWO > 1000    AND  AVERAGE_COST_FOR_TWO <= 5000   THEN "4) 1K-5K" 
     WHEN AVERAGE_COST_FOR_TWO > 5000    AND  AVERAGE_COST_FOR_TWO <= 10000  THEN "5) 5K-10K" 
     WHEN AVERAGE_COST_FOR_TWO > 10000   AND  AVERAGE_COST_FOR_TWO <= 100000 THEN "6) 10K-1LAKH" 
     WHEN AVERAGE_COST_FOR_TWO > 100000  THEN "7) ABOVE 1 LAKH" 
END AS AVERAGE_COST ,
count(restaurantid) as Restaurant_Count
FROM ZOMATO_TABLE
GROUP BY AVERAGE_COST
ORDER BY AVERAGE_COST ;

----------------------------------------------------------------------------------------------------------------------------------------------------------

# 7) Percentage of Resturants based on "Has_Table_booking"		


select   Has_table_booking as Table_Booking ,
count(RestaurantID) as Restaunt_Count ,
concat(round((count(RestaurantID)  / sum(count(RestaurantID)) over() * 100 ),2)," %") as Resturant_Percent
from zomato_table
group by table_booking ;

------------------------------------------------------------------------------------------------------------------------------------------------------

# 8) Percentage of Resturants based on "Has_Online_Delivery"

select   Has_Online_delivery as Online_Delivery ,
count(RestaurantID) as Restaunt_Count ,
concat(round((count(RestaurantID)  / sum(count(RestaurantID)) over() * 100 ),2)," %") as Restaurant_Percent
from zomato_table
group by online_delivery ;

----------------------------------------------------------------------------------------------------------------------------------------------------

# 9.1 ) Top 10 Cuisines by Number of Restaurants

SELECT CUISINES , count(RESTAURANTID) AS RESTAURANT_COUNT
FROM ZOMATO_TABLE
GROUP BY CUISINES
ORDER BY RESTAURANT_COUNT DESC 
LIMIT 10 ;

--------------------------------------------------------------------------------------------------------------------------------------------------------------

# 9.2 ) Top 10 Cities by no. of restaurents

SELECT CITY , count(RESTAURANTID) AS RESTAURANT_COUNT
FROM ZOMATO_TABLE
GROUP BY CITY
ORDER BY RESTAURANT_COUNT DESC 
LIMIT 10 ;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

# 9.3 ) TOP 10 CUISINES BY AVERAGE RATING

SELECT CUISINES , AVG(RATING) AS AVG_RATING
FROM ZOMATO_TABLE
GROUP BY CUISINES
ORDER BY AVG_RATING DESC 
LIMIT 10 ;

--------------------------------------------------------------------------------------------------------------------------------------------------------------


