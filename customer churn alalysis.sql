use database tourism;
use schema europe;
CREATE OR replace TABLE customer_churn(
    Customer_Id number (10,0),
    Churn NUMBER (10,0),
    Tenure number(10,0),
    PreferedLoginDevice varchar (30),
    CityTier number(6),
    WarehouseToHome number(6,0),
    PreferredPaymentMode varchar(20),
    Gender varchar(6),
   HourSpendOnApp NUMBER (12,0),
    NumberOfDeviceRegistered NUMBER(12,0),
    PreferredOrderCategory varchar(20),
    SatisfactionScore NUMBER (12,6),
    MaritalStatus varchar(20),
    NumberOfAddress NUMBER (12,0),
    Complain NUMBER (12,0),
    OrderAmountHikeFromLastYear NUMBER (12,0),
    CoponUsed NUMBER (12,6),
    OrderCount NUMBER (12,6),
    DaySinceLastOrder NUMBER (12,6),
    CashbackAmount Number(10,0)
    );



    select * from customer_churn;
    select count(*) from customer_churn;--There are total 5630 record in this dataset


   -- Data Cleaning


-- 1. Find the total number of customers
SELECT DISTINCT COUNT(Customer_ID) as TotalNumberOfCustomers
FROM customer_churn;
-- Answer = There are 5,630 customers in this dataset




-- 2. Check for duplicate rows
SELECT Customer_ID, COUNT (Customer_ID) as Count
FROM customer_churn
GROUP BY Customer_ID
Having COUNT (Customer_ID) > 1;
-- Answer = There are no duplicate rows


-- 3. Check for null values count for columns with null values

(SELECT  Tenure as ColumnName , COUNT(*) AS NullCount 
FROM customer_churn
WHERE Tenure IS NULL
GROUP BY TENURE)
UNION 
(SELECT WarehouseToHome as ColumnName, COUNT(*) AS NullCount 
FROM customer_churn
WHERE warehousetohome IS NULL 
GROUP BY WAREHOUSETOHOME)
UNION
(SELECT HourSpendonApp as ColumnName , COUNT(*) AS NullCount 
FROM customer_churn
WHERE hourspendonapp IS NULL
GROUP BY HOURSPENDONAPP)
UNION
SELECT OrderAmountHikeFromLastYear as columnName, COUNT(*) AS NullCount 
FROM customer_churn
WHERE orderamounthikefromlastyear IS NULL 
GROUP BY ORDERAMOUNTHIKEFROMLASTYEAR
UNION
SELECT CoponUsed as ColumnName, COUNT(*) AS NullCount 
FROM customer_churn
WHERE  coponused IS NULL
GROUP BY COPONUSED
UNION
SELECT OrderCount as ColumnName, COUNT(*) AS NullCount 
FROM customer_churn
WHERE ordercount IS NULL 
GROUP BY ORDERCOUNT
UNION
SELECT DaySinceLastOrder as ColumnName, COUNT(*) AS NullCount 
FROM customer_churn
WHERE daysincelastorder IS NULL
GROUP BY DAYSINCELASTORDER;







SELECT
    COUNT(CASE WHEN Tenure IS NULL THEN 1 END) AS count_Tenure,
    COUNT(CASE WHEN warehousetohome IS NULL THEN 1 END) AS count_warehouseToHome,
    COUNT(CASE WHEN hourspendonapp IS NULL THEN 1 END) AS count_hourspendonapp,
    COUNT(CASE WHEN orderamounthikefromlastyear IS NULL THEN 1 END) AS count_orderamounthike,
    COUNT(CASE WHEN coponused IS NULL THEN 1 END) AS count_coponused,
    COUNT(CASE WHEN ordercount  IS NULL THEN 1 END) AS count_ordercount,
    COUNT(CASE WHEN daysincelastorder IS NULL THEN 1 END) AS count_daysincelastorder
    from customer_churn;
            --we can see that the dataset has a lot null values



-- 3.1 Handle null values
-- We will fill null values with their mean. 



UPDATE customer_churn
SET hourspendonapp = (SELECT AVG(Hourspendonapp) FROM customer_churn)
WHERE Hourspendonapp IS NULL ;

UPDATE customer_churn
SET tenure = (SELECT AVG(tenure) FROM customer_churn)
WHERE tenure IS NULL ;

UPDATE customer_churn
SET orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM customer_churn)
WHERE orderamounthikefromlastyear IS NULL; 

UPDATE customer_churn
SET WarehouseToHome = (SELECT  AVG(WarehouseToHome) FROM customer_churn)
WHERE WarehouseToHome IS NULL ;

UPDATE customer_churn
SET coponused = (SELECT AVG(coponused) FROM customer_churn)
WHERE coponused IS NULL; 

UPDATE customer_churn
SET ordercount = (SELECT AVG(ordercount) FROM customer_churn)
WHERE ordercount IS NULL ;

UPDATE customer_churn
SET daysincelastorder = (SELECT AVG(daysincelastorder) FROM customer_churn)
WHERE daysincelastorder IS NULL ;



--4. Create a new column based on  the values of churn column.
-- The values in churn column are 0 and 1 values were O means stayed and 1 means churned. I will create a new column 
-- called customerstatus that shows 'Stayed' and 'Churned' instead of 0 and 1
ALTER TABLE customer_churn
ADD CustomerStatus NVARCHAR(50);

UPDATE customer_churn
SET CustomerStatus = 
CASE 
    WHEN Churn = 1 THEN 'Churned' 
    WHEN Churn = 0 THEN 'Stayed'
END ;

select  distinct customerstatus
from customer_churn;



-- 5. Create a new column based on the values of complain column.
-- The values in complain column are 0 and 1 values were O means No and 1 means Yes. I will create a new column 
-- called complainrecieved that shows 'Yes' and 'No' instead of 0 and 1  
ALTER TABLE customer_churn
ADD ComplainRecieved NVARCHAR(10);

UPDATE customer_churn
SET ComplainRecieved =  
CASE 
    WHEN complain = 1 THEN 'Yes'
    WHEN complain = 0 THEN 'No'
END;


-- 6. Check values in each column for correctness and accuracy

-- 6.1 a) Check distinct values for preferredlogindevice column
select distinct PREFEREDLOGINDEVICE 
from customer_churn;
-- the result shows phone and mobile phone which indicates the same thing, so I will replace mobile phone with phone

-- 6.1 b) Replace mobile phone with phone

select ltrim(preferedlogindevice)
from customer_churn;
UPDATE customer_churn
SET PREFEREDLOGINDEVICE = 'phone'
WHERE PREFEREDLOGINDEVICE = 'Mobile phone';


-- 6.2 a) Check distinct values for PREFERREDORDERCATEGORY column
select distinct PREFERREDORDERCATEGORY 
from customer_churn;
-- the result shows mobile phone and mobile, so I replace mobile with mobile phone

-- 6.2 b) Replace mobile with mobile phone
UPDATE customer_churn
SET PREFERREDORDERCATEGORY = 'Mobile Phone'
WHERE PREFERREDORDERCATEGORY = 'Mobile';


-- 6.3 a) Check distinct values for preferredpaymentmode column
select distinct PreferredPaymentMode 
from customer_churn;
-- the result shows Cash on Delivery and COD which mean the same thing, so I replace COD with Cash on Delivery

-- 6.3 b) Replace mobile with mobile phone
UPDATE customer_churn
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD';




-- 6.4 a) check distinct value in warehousetohome column
SELECT DISTINCT warehousetohome
FROM customer_churn;
-- I can see two values 126 and 127 that are outliers, it could be a data entry error, so I will correct it to 26 & 27 respectively

-- 6.4 b) Replace value 127 with 27
UPDATE customer_churn
SET warehousetohome = '27'
WHERE warehousetohome = '127';

-- 6.4 C) Replace value 126 with 26
UPDATE customer_churn
SET warehousetohome = '26'
WHERE warehousetohome = '126';



/**************************************************
Data Exploration and Answering business questions
***************************************************/


-- 1. What is the overall customer churn rate?

SELECT
    (COUNT(CASE WHEN customerstatus = 'Churned' THEN 1 END) / COUNT(*)) * 100 AS churn_percentage
FROM customer_churn;
-- Answer = The Churn rate is 16.84%.The churn rate of 16.84% indicates that a significant portion of customers in the dataset have ended their association with the company

-- 2. How does the churn rate vary based on the preferred login device?
SELECT PREFEREDLOGINDEVICE, 
        COUNT(*) AS TotalCustomers,
        SUM(churn) AS ChurnedCustomers,
        round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY PREFEREDLOGINDEVICE;
-- Answer = The prefered login devices are computer and phone. Computer accounts for the highest churnrate
-- with 19.83% and then phone with 15.62%. 



-- 3. What is the distribution of customers across different city tiers?
SELECT citytier, 
       COUNT(*) AS TotalCustomer, 
       SUM(Churn) AS ChurnedCustomers, 
       round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY citytier
ORDER BY churnrate DESC;
-- Answer = citytier3 has the highest churn rate, followed by citytier2 and then citytier1 has the least churn rate.


-- 4. Is there any correlation between the warehouse-to-home distance and customer churn?
-- Firstly, we will create a new column that provides a distance range based on the values in warehousetohome column
ALTER TABLE customer_churn
ADD warehousetohomerange VARCHAR(50);

UPDATE customer_churn
SET warehousetohomerange =
CASE 
    WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END;


-- Finding correlation between warehousetohome and churnrate
SELECT warehousetohomerange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY warehousetohomerange
ORDER BY Churnrate DESC;
-- Answer = The churn rate increases as the warehousetohome distance increases.So there is a positive relationship between them


-- 5. Which is the most prefered payment mode among churned customers?
SELECT preferredpaymentmode,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
      round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY preferredpaymentmode
ORDER BY Churnrate DESC;
-- Answer = The most prefered payment mode among churned customers is Cash on Delivery and the least favourite is Credit Card



-- 6. What is the typical tenure for churned customers?
-- Firstly, we will create a new column that provides a tenure range based on the values in tenure column
ALTER TABLE customer_churn
ADD TenureRange VARCHAR(50);

UPDATE customer_churn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN 'more than 2 years'
END;

-- Finding typical tenure for churned customers
SELECT TenureRange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
      round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY TenureRange
ORDER BY Churnrate DESC;
-- Answer = Most customers churned within a 6 months tenure period.This shows that customers who have been with the company for longer periods, specifically more than 2 years in this case, have shown a lower likelihood of churn compared to customers in shorter tenure groups.


-- 7. Is there any difference in churn rate between male and female customers?
SELECT gender,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY gender
ORDER BY Churnrate DESC;
-- Answer = More men churned in comaprison to wowen.However, the difference in churn rates between the genders is relatively small. This suggests that gender alone may not be a significant factor in predicting customer churn.



-- 8. How does the average time spent on the app differ for churned and non-churned customers?
SELECT customerstatus, avg(hourspendonapp) AS AverageHourSpentonApp
FROM customer_churn
GROUP BY customerstatus;
-- Answer = There is no difference between the average time spent on the app for churned and non-churned customers.this indicates that the average app usage time does not seem to be a differentiating factor between customers who churned and those who stayed.



-- 9. Does the number of registered devices impact the likelihood of churn?
SELECT NumberofDeviceRegistered,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY NumberofDeviceRegistered
ORDER BY Churnrate DESC;
-- Answer = There seems to be a correlation between the number of devices registered by customers and the likelihood of churn. As the number of registered devices increseas the churn rate increases. 



-- 10. Which order category is most prefered among churned customers?
SELECT PREFERREDORDERCATEGORY,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
      round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY PREFERREDORDERCATEGORY
ORDER BY Churnrate DESC;
-- Answer = Mobile phone category has the highest churn rate and grocery has the least churn rate.Customers who primarily order items in the “Mobile Phone” category have the highest churn rate, indicating a potential need for targeted retention strategies for this group. On the other hand, the “Grocery” category exhibits the lowest churn rate, suggesting that customers in this category may have higher retention and loyalty.



-- 11. Is there any relationship between customer satisfaction scores and churn?
SELECT satisfactionscore,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY satisfactionscore
ORDER BY Churnrate DESC;
-- Answer = Customer satisfaction score of 5 has the highest churn rate, satisfaction score of 1 has the least churn rate. This suggests that even highly satisfied customers may still churn, highlighting the importance of proactive customer retention strategies across all satisfaction levels.




-- 12. Does the marital status of customers influence churn behavior?
SELECT maritalstatus,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
      round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY maritalstatus
ORDER BY Churnrate DESC;
-- Answer = Single customers have the highest churn rate while married customers have the least churn rate. This indicates that single customers may be more likely to discontinue their relationship with the company. On the other hand, married customers have the lowest churn rate, followed by divorced customers.





-- 13. How many addresses do churned customers have on average?
SELECT AVG(numberofaddress) AS Averagenumofchurnedcustomeraddress
FROM customer_churn
WHERE customerstatus = 'Churned';
-- Answer = On average, churned customers have 4 addresses.





-- 14. Does customer complaints influence churned behavior?
SELECT complainrecieved,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY complainrecieved
ORDER BY Churnrate DESC;
-- Answer = Customers with complains had the highest churn rate.The fact that a larger proportion of customers who stopped using the company’s services registered complaints indicates the importance of dealing with and resolving customer concerns. This is vital for decreasing the number of customers who leave and building lasting loyalty. By actively listening to customer feedback, addressing their issues, and consistently working on improving the quality of their offerings, companies can create a better overall experience for customers. This approach helps to minimize the chances of customers leaving and fosters stronger relationships with them in the long run.




-- 15. How does the usage of coupons differ between churned and non-churned customers?
SELECT customerstatus, round(SUM(coponused)) AS SumofCouponUsed
FROM customer_churn
GROUP BY customerstatus;
-- Churned customers used less coupons in comparison to non churned customers.The higher coupon usage among stayed customers indicates their higher level of loyalty and engagement with the company. By implementing strategies to reward loyalty, provide personalized offers, and maintain continuous engagement, the company can further leverage coupon usage as a tool to strengthen customer loyalty and increase overall customer retention.



-- 16. What is the average number of days since the last order for churned customers?
SELECT customerstatus,  round(AVG(daysincelastorder)) AS AverageNumofDaysSinceLastOrder
FROM customer_churn
group by customerstatus;
-- Answer = The average number of days since last order for churned customer is 3 and for the stayed customer is 5 day. The fact that churned customers have, on average, only had a short period of time since their last order indicates that they recently stopped engaging with the company. By focusing on enhancing the overall customer experience, implementing targeted retention initiatives, and maintaining continuous engagement, the company can work towards reducing churn and increasing customer loyalty.




-- 17. Is there any correlation between cashback amount and churn rate?
-- Firstly, we will create a new column that provides a tenure range based on the values in tenure column
ALTER TABLE customer_churn
ADD cashbackamountrange VARCHAR(50);

UPDATE customer_churn
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END;

-- Finding correlation between cashbackamountrange and churned rate
SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       round((SUM (churn) / COUNT(*)) * 100,2)   AS ChurnRate
FROM customer_churn
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC;
-- Answer = Customers with a Moderate Cashback Amount (Between 100 and 200) have the highest churn rate, follwed by
-- High cashback amount, then very high cashback amount and finally low cashback amount.Customers who received moderate cashback amounts had a relatively higher churn rate, while those who received higher and very high cashback amounts exhibited lower churn rates. Customers who received lower cashback amounts also had a 100% retention rate. This suggests that offering higher cashback amounts can positively influence customer loyalty and reduce churn.

























    