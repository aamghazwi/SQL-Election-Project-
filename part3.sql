-- a)   The sum of votes for Trump and Biden cannot be larger than totalvotes

-- You should write SQL queries to verify the constraints and return TRUE or FALSE (in case constraint is not satisfied).  Queries that don’t return a boolean value won’t be accepted.  

-- The stored procedure for part a
DELIMITER $$
CREATE PROCEDURE `check1`()
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
SET @sql = 'SELECT IF(SUM(Biden) + SUM(Trump) <= SUM(totalvotes), TRUE, FALSE) AS Result FROM Penna';
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- Sql query for the part a
SELECT IF(SUM(Biden) + SUM(Trump) <= SUM(totalvotes), TRUE, FALSE) AS Result FROM Penna;

-- There cannot be any tuples with timestamps later than Nov 11 and earlier than Nov3

-- The stored procedure for part b

DELIMITER $$
CREATE PROCEDURE `check2`()
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
SET @sql = 'SELECT IF((SELECT COUNT(*) FROM Penna WHERE Timestamp > "2020-11-11 23:59:59") = 0 AND (SELECT COUNT(*) FROM Penna WHERE Timestamp < "2020-11-03 00:00:00") = 0, TRUE, FALSE) AS Result';
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- Sql query for the part b
SELECT IF((SELECT COUNT(*) FROM Penna WHERE Timestamp > "2020-11-11 23:59:59") = 0 AND (SELECT COUNT(*) FROM Penna WHERE Timestamp < "2020-11-03 00:00:00") = 0, TRUE, FALSE) AS Result;


-- The stored procedure for part c

DELIMITER $$
CREATE PROCEDURE `check3`()
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
-- check the each timestamps total votes is smaller than the next timestamp
SET @sql = 'SELECT IF((SELECT COUNT(*) FROM (SELECT * FROM Penna WHERE Timestamp > "2020-11-05 00:00:00" ORDER BY Timestamp ASC) AS A JOIN (SELECT * FROM Penna WHERE Timestamp > "2020-11-05 00:00:00" ORDER BY Timestamp DESC) AS B ON A.Precinct = B.Precinct AND A.Timestamp < B.Timestamp WHERE A.totalvotes > B.totalvotes) = 0, TRUE, FALSE) AS Result';
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- Sql query for the part c
SELECT IF((SELECT COUNT(*) FROM (SELECT * FROM Penna WHERE Timestamp > "2020-11-05 00:00:00" ORDER BY Timestamp ASC) AS A JOIN (SELECT * FROM Penna WHERE Timestamp > "2020-11-05 00:00:00" ORDER BY Timestamp DESC) AS B ON A.Precinct = B.Precinct AND A.Timestamp < B.Timestamp WHERE A.totalvotes > B.totalvotes) = 0, TRUE, FALSE) AS Result;