CREATE TABLE `testDB`.`Updated Tuples` (
 `ID` INT NOT NULL AUTO_INCREMENT,
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

CREATE TABLE `testDB`.`Inserted Tuples` (
`ID` INT NOT NULL AUTO_INCREMENT,
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

CREATE TABLE `testDB`.`Deleted Tuples` (
`ID` INT NOT NULL AUTO_INCREMENT,
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

DELIMITER $$
DROP TRIGGER IF EXISTS `testDB`.`Penna_BEFORE_INSERT` $$
CREATE TRIGGER `testDB`.`Penna_BEFORE_UPDATE` BEFORE UPDATE ON `Penna` FOR EACH ROW
BEGIN
INSERT INTO `testDB`.`Updated Tuples` (`Timestamp`, `state`, `locality`, `precinct`, `geo`, `totalvotes`, `Biden`, `Trump`, `filestamp`) VALUES (OLD.Timestamp, OLD.state, OLD.locality, OLD.precinct, OLD.geo, OLD.totalvotes, OLD.Biden, OLD.Trump, OLD.filestamp);
END$$
DELIMITER ;


DELIMITER $$
DROP TRIGGER IF EXISTS `testDB`.`Penna_BEFORE_INSERT`$$
CREATE TRIGGER `testDB`.`Penna_BEFORE_INSERT` BEFORE INSERT ON `Penna` FOR EACH ROW
BEGIN
INSERT INTO `testDB`.`Inserted Tuples` (`Timestamp`, `state`, `locality`, `precinct`, `geo`, `totalvotes`, `Biden`, `Trump`, `filestamp`) VALUES (NEW.Timestamp, NEW.state, NEW.locality, NEW.precinct, NEW.geo, NEW.totalvotes, NEW.Biden, NEW.Trump, NEW.filestamp);
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `testDB`.`Penna_BEFORE_DELETE` BEFORE DELETE ON `Penna` FOR EACH ROW
BEGIN
INSERT INTO `testDB`.`Deleted Tuples` (`Timestamp`, `state`, `locality`, `precinct`, `geo`, `totalvotes`, `Biden`, `Trump`, `filestamp`) VALUES (OLD.Timestamp, OLD.state, OLD.locality, OLD.precinct, OLD.geo, OLD.totalvotes, OLD.Biden, OLD.Trump, OLD.filestamp);
END$$
DELIMITER ;


-- Part 2


DELIMITER $$
CREATE PROCEDURE `testDB`.`MoveVotes`(IN Precinct_ VARCHAR(100), IN time_s DATETIME, IN CoreCandidate VARCHAR(45), IN Number_of_Moved_Votes INT)
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE BidenVotes INT;
DECLARE TrumpVotes INT;
DECLARE NewBidenVotes INT;
DECLARE NewTrumpVotes INT;
DECLARE currID INT;
-- declare a cursor to get the votes of the core candidate and the other candidate
DECLARE cur CURSOR FOR SELECT `ID`, `Biden`, `Trump` FROM `testDB`.`Penna` WHERE `precinct` = Precinct_ AND `Timestamp` >= time_s;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

-- CHECK IF PRECINCT EXISTS
IF (SELECT COUNT(*) FROM `testDB`.`Penna` WHERE `precinct` = Precinct_) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Precinct does not exist';
END IF;
-- CHECK IF TIMESTAMP EXISTS
IF (SELECT COUNT(*) FROM `testDB`.`Penna` WHERE `Timestamp` = time_s and `precinct` = Precinct_) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Timestamp does not exist';
END IF;

-- CHECK IF CORE CANDIDATE IS TRUMP OR BIDEN
IF CoreCandidate != 'Trump' AND CoreCandidate != 'Biden' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CoreCandidate is not Trump or Biden';
END IF;

OPEN cur;
read_loop: LOOP
    FETCH  cur INTO currID, BidenVotes, TrumpVotes;
    IF done THEN
        LEAVE read_loop;
    END IF;
    -- CHECK IF NUMBER OF VOTES IS LESS THAN NUMBER OF VOTES OF CORE CANDIDATE
    IF CoreCandidate = 'Trump' AND Number_of_Moved_Votes > TrumpVotes THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough votes';
    END IF;
    IF CoreCandidate = 'Biden' AND Number_of_Moved_Votes > BidenVotes THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough votes';
    END IF;
    -- UPDATE THE VOTES
    IF CoreCandidate = 'Trump' THEN
        SET NewBidenVotes = BidenVotes + Number_of_Moved_Votes;
        SET NewTrumpVotes = TrumpVotes - Number_of_Moved_Votes;
    ELSE
        SET NewBidenVotes = BidenVotes - Number_of_Moved_Votes;
        SET NewTrumpVotes = TrumpVotes + Number_of_Moved_Votes;
    END IF;
    UPDATE `testDB`.`Penna` SET `Biden` = NewBidenVotes, `Trump` = NewTrumpVotes WHERE `ID`=currID and `precinct` = Precinct AND `Timestamp` = Timestamp;
END LOOP;
CLOSE cur;
END$$
DELIMITER ;
