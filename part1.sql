 CREATE TABLE `testDB`.`Penna` (
 `ID` INT NOT NULL,
 `Timestamp` DATETIME NULL,
 `state` VARCHAR(45) NULL,
 `locality` VARCHAR(45) NULL,
 `precinct` VARCHAR(50) NULL,
 `geo` VARCHAR(45) NULL,
 `totalvotes` INT NULL,
 `Biden` INT NULL,
 `Trump` INT NULL,
 `filestamp` VARCHAR(45) NULL,
 PRIMARY KEY (`ID`));

--  1.	API1(candidate, timestamp, precinct) - Given a candidate C, timestamp T and precinct P, return how many votes did the candidate C  have at  T or largest timestamp T’ smaller than T, in case T does not appear in Penna. 

-- stored procedure with error handleing
 
DELIMITER $$
CREATE PROCEDURE `API1`(IN candidate VARCHAR(45), IN timest VARCHAR(45), IN precinct VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
SET @sql = CONCAT('SELECT ', candidate, ' FROM Penna WHERE Timestamp <= "', timest, '" AND precinct = "', precinct, '" ORDER BY Timestamp DESC LIMIT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- 2.	API2(date) - Given a date, return the candidate who had the most votes at the last timestamp for this date as well as  how many votes he got. For example the last timestamp for 2020-11-06 will be 2020-11-06 23:51:43.

DELIMITER $$
CREATE PROCEDURE `API2`(IN date VARCHAR(45))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
SET @sql = CONCAT('SELECT IF(Biden > Trump, "Biden", "Trump") AS Candidate, IF(Biden > Trump, Biden, Trump) AS Votes FROM Penna WHERE Timestamp <="', date, ' 23:59:59" ORDER BY Timestamp DESC LIMIT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- 3.	API3(candidate) - Given a candidate return top 10 precincts that this candidate win. Order precincts by total votes and list TOP 10 in descending order of totalvotes. 

DELIMITER $$
CREATE PROCEDURE `API3`(IN candidate VARCHAR(45))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
SET @sql = CONCAT('SELECT precinct FROM Penna WHERE ', candidate, ' >= Trump GROUP BY Precinct ORDER BY ',candidate, '  DESC LIMIT 10');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- 4.	API4(precinct) - Given a precinct,  Show who won this precinct (Trump or Biden) as well as what percentage of total votes went to the winner.

DELIMITER $$
CREATE PROCEDURE `API4`(IN precinct VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
SET @sql = CONCAT('SELECT IF(Biden > Trump, "Biden", "Trump") AS Candidate, IF(Biden > Trump, Biden, Trump) AS Votes, IF(Biden > Trump, Biden, Trump)/totalvotes AS Percentage FROM Penna WHERE Precinct = "', precinct, '" ORDER BY Timestamp DESC LIMIT 1');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- 5.	API5(string) - Given a string s of characters, create a stored procedure which determines who won more votes in all precincts whose names contain this string s and how many votes did they get in total.  For example,  for  s= ‘Township’, the procedure will return the name (Trump or Biden) who won more votes in union of  precincts which have “Township” in their name as well as sum of votes for the winner. 

DELIMITER $$
CREATE PROCEDURE `API5`(IN string VARCHAR(50))
BEGIN
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
SELECT 'Error';
END;
SET @sql = CONCAT('SELECT IF(Biden > Trump, "Biden", "Trump") AS Candidate, IF(Biden > Trump, SUM(Biden), SUM(Trump)) AS Votes FROM Penna WHERE Precinct LIKE "%', string, '%"');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;