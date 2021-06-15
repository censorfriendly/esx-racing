CREATE TABLE `racing_active` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `race_id` int(11) NOT NULL,
  `race_key` varchar(45) NOT NULL DEFAULT '',
  `identifier` varchar(55) NOT NULL,
  `player_name` varchar(255) NOT NULL,
  `lap` int(11) NOT NULL DEFAULT '1',
  `checkpoint` int(11) NOT NULL DEFAULT '1',
  `best_lap` varchar(45) DEFAULT NULL,
  `total_time` varchar(45) DEFAULT NULL,
  `finished` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

CREATE TABLE `racing_pending` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `race_id` varchar(55) NOT NULL,
  `identifier` varchar(55) DEFAULT NULL,
  `player_name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=latin1;

CREATE TABLE `racing_tracktimes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_name` varchar(255) NOT NULL,
  `track_id` int(11) DEFAULT NULL,
  `best_lap` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `racing_temp` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `race_id` int(11) NOT NULL,
  `identifier` varchar(55) NOT NULL,
  `track_time` varchar(45) DEFAULT NULL,
  `placement` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
