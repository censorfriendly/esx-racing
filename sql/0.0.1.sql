ALTER TABLE `users` 
ADD COLUMN `racecrypto` INT(11) NOT NULL DEFAULT 0 ;

CREATE TABLE `racing_tracktimes` (
  `identifier` varchar(55) NOT NULL,
  `track_id` int(11) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `best_lap` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`identifier`,`track_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
