-- newPenna(): This stored procedure will create a table newPenna, showing for each precinct  how many votes were added to totalvotes, Trump, Biden between timestamp T and the last timestamp directly preceding  T.  In other words, create a table like Penna but replace totalvotes with newvotes, Trump with new_Trump and Biden with new_Biden.  Stored procedure with cursor is recommended. 
-- using cursor
DELIMITER $$
CREATE PROCEDURE `newPenna`()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE v_id INT;
DECLARE prev_id INT;
DECLARE v_timestamp DATETIME;
DECLARE prev_timestamp DATETIME;
DECLARE v_state VARCHAR(45);
DECLARE prev_state VARCHAR(45);
DECLARE v_locality VARCHAR(45);
DECLARE prev_locality VARCHAR(45);
DECLARE v_precinct VARCHAR(50);
DECLARE prev_precinct VARCHAR(50);
DECLARE v_geo VARCHAR(45);
DECLARE prev_geo VARCHAR(45);
DECLARE v_newvotes INT;
DECLARE prev_votes INT;
DECLARE v_newTrump INT;
DECLARE prev_Trump INT;
DECLARE v_newBiden INT;
DECLARE prev_Biden INT;
DECLARE v_filestamp VARCHAR(45);
DECLARE prev_filestamp VARCHAR(45);
-- cursor to iterate through the table and get the newly aded votes subtracting the previous votes
DECLARE cur1 CURSOR FOR SELECT * FROM Penna ORDER BY id;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

-- create a new table newPenna if it does not exist
CREATE TABLE IF NOT EXISTS newPenna (
`ID` INT NOT NULL,
`Timestamp` DATETIME NULL,
`state` VARCHAR(45) NULL,
`locality` VARCHAR(45) NULL,
`precinct` VARCHAR(50) NULL,
`geo` VARCHAR(45) NULL,
`newvotes` INT NULL,
`new_Trump` INT NULL,
`new_Biden` INT NULL,
`filestamp` VARCHAR(45) NULL,
PRIMARY KEY (`ID`));

-- open cursor
OPEN cur1;
-- iterate through the cursor
read_loop: LOOP
FETCH cur1 INTO v_id, v_timestamp, v_state, v_locality, v_precinct, v_geo, v_newvotes, v_newBiden, v_newTrump, v_filestamp;
IF done THEN
LEAVE read_loop;
END IF;
-- get the previous values
SET prev_id = (SELECT id FROM Penna WHERE timestamp < v_timestamp AND precinct=v_precinct ORDER BY timestamp DESC LIMIT 1);
SET prev_timestamp = (SELECT timestamp FROM Penna WHERE id = prev_id);
SET prev_state = (SELECT state FROM Penna WHERE id = prev_id);
SET prev_locality = (SELECT locality FROM Penna WHERE id = prev_id);
SET prev_precinct = (SELECT precinct FROM Penna WHERE id = prev_id);
SET prev_geo = (SELECT geo FROM Penna WHERE id = prev_id);
SET prev_votes = (SELECT totalvotes FROM Penna WHERE id = prev_id);
SET prev_Biden = (SELECT Biden FROM Penna WHERE id = prev_id);
SET prev_Trump = (SELECT Trump FROM Penna WHERE id = prev_id);
SET prev_filestamp = (SELECT filestamp FROM Penna WHERE id = prev_id);
-- insert the new values into the new table
INSERT INTO newPenna (id, timestamp, state, locality, precinct, geo, newvotes, new_Trump, new_Biden, filestamp) VALUES (v_id, v_timestamp, v_state, v_locality, v_precinct, v_geo, (v_newvotes - prev_votes), (v_newTrump - prev_Trump), (v_newBiden - prev_Biden), v_filestamp);
END LOOP;
-- close cursor
CLOSE cur1;


END$$   
DELIMITER ;


-- Switch(): This stored procedure will return list of precincts, which have switched their winner from one candidate in last 24 hours of vote collection (i.e 24 hours before the last Timestamp data was collected) and that candidate was the ultimate winner of this precinct.   The format of the table should be:

DELIMITER $$
CREATE PROCEDURE `Switch`()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE v_id INT;
DECLARE prev_id INT;
DECLARE v_timestamp DATETIME;
DECLARE prev_timestamp DATETIME;
DECLARE v_state VARCHAR(45);
DECLARE v_locality VARCHAR(45);
DECLARE v_precinct VARCHAR(50);
DECLARE v_geo VARCHAR(45);
DECLARE prev_geo VARCHAR(45);
DECLARE v_newvotes INT;
DECLARE prev_votes INT;
DECLARE v_newTrump INT;
DECLARE prev_Trump INT;
DECLARE v_newBiden INT;
DECLARE prev_Biden INT;
DECLARE v_filestamp VARCHAR(45);
DECLARE prev_filestamp VARCHAR(45);
DECLARE v_winner VARCHAR(45);
DECLARE prev_winner VARCHAR(45);
DECLARE v_newwinner VARCHAR(45);
DECLARE prev_newwinner VARCHAR(45);
DECLARE looser VARCHAR(45);

-- cursor through all the precincts and return the list that the winner has changed in the last 24 hours
DECLARE cur1 CURSOR FOR SELECT * FROM Penna ORDER BY precinct and date(timestamp);
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

CREATE TABLE IF NOT EXISTS Switch (
`ID` INT NOT NULL,
`Precinct` VARCHAR(50) NULL,
`Timestamp` DATETIME NULL,
`Winner` VARCHAR(45) NULL,
`Looser` VARCHAR(45) NULL,
PRIMARY KEY (`ID`));

OPEN cur1;
read_loop: LOOP
FETCH cur1 INTO v_id, v_timestamp, v_state, v_locality, v_precinct, v_geo, v_newvotes, v_newBiden, v_newTrump, v_filestamp;
IF done THEN
LEAVE read_loop;
END IF;
-- get the previous values bfore 24 hours of the time stamp
SET prev_id = (SELECT id FROM Penna WHERE timestamp <= DATE_SUB(v_timestamp, INTERVAL 1 DAY) AND precinct=v_precinct ORDER BY timestamp DESC LIMIT 1);
SET prev_timestamp = (SELECT timestamp FROM Penna WHERE id = prev_id);
SET prev_Trump = (SELECT Trump FROM Penna WHERE id = prev_id);
SET prev_Biden = (SELECT Biden FROM Penna WHERE id = prev_id);
-- get the winner of the previous values
IF prev_Trump > prev_Biden THEN
SET prev_winner = 'Trump';
ELSEIF prev_Trump < prev_Biden THEN
SET prev_winner = 'Biden';
ELSE
SET prev_winner = 'Tie';
END IF;
-- get the winner of the current values
IF v_newTrump > v_newBiden THEN
SET v_winner = 'Trump';
SET looser = 'Biden';
ELSEIF v_newTrump < v_newBiden THEN
SET v_winner = 'Biden';
SET looser = 'Trump';
ELSE
SET v_winner = 'Tie';
END IF;
-- if the winner has changed, return the list of precincts with the winner and the timestamp
IF prev_winner != v_winner THEN
INSERT INTO Switch (id, precinct, timestamp, winner, looser) VALUES (v_id, v_precinct, v_timestamp, v_winner, looser);
END IF;
END LOOP;
CLOSE cur1;
END$$
DELIMITER ;