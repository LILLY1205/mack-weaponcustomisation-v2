-- Run this SQL on your oxmysql database

-- New table name, no access_code column
CREATE TABLE IF NOT EXISTS `mack_gunsmith` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `propid` INT NOT NULL,
  `citizenid` VARCHAR(64) NOT NULL,
  `proptype` VARCHAR(64) NULL,
  `properties` LONGTEXT NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_propid` (`propid`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
