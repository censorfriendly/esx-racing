ALTER TABLE `users` 
ADD COLUMN `racecrypto` INT(11) NOT NULL DEFAULT 0 ;

CREATE TABLE `racing_tracktimes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_name` varchar(255) NOT NULL,
  `track_id` int(11) DEFAULT NULL,
  `best_lap` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

