-- 1 - create temporary table from serviceevents (execution time : < 30 sec / 141427 rows)
DROP TABLE IF EXISTS `glpi_plugin_monitoring_hostcounters_tmp`;
CREATE TABLE IF NOT EXISTS `glpi_plugin_monitoring_hostcounters_tmp` (
   `id` INT(11) NOT NULL AUTO_INCREMENT,
   `serviceId` INT(11),
   `hostname` VARCHAR(255) DEFAULT NULL,
   `date` DATETIME DEFAULT NULL,
   `cutPages` INT(11) NOT NULL DEFAULT '0',
   `retractedPages` INT(11) NOT NULL DEFAULT '0',
   `printerChanged` INT(11) NOT NULL DEFAULT '0',
   `paperChanged` INT(11) NOT NULL DEFAULT '0',
   `binEmptied` INT(11) NOT NULL DEFAULT '0',
   PRIMARY KEY (`id`)
)
SELECT
  `plugin_monitoring_services_id` AS serviceId
  , 'unknown' AS hostname
  , `date` AS DATE
  , IF(LOCATE('\'Cut Pages\'=', `perf_data`)>0, SUBSTRING_INDEX(SUBSTRING_INDEX(`perf_data`, '\'Cut Pages\'=', -1), 'c', 1) , 0) AS cutPages
  , IF(LOCATE('\'Retracted Pages\'=', `perf_data`)>0, SUBSTRING_INDEX(SUBSTRING_INDEX(`perf_data`, '\'Retracted Pages\'=', -1), 'c', 1) , 0) AS retractedPages
  , 0 AS printerChanged
  , 0 AS paperChanged
  , 0 AS binEmptied
FROM
  `glpi_plugin_monitoring_serviceevents`
WHERE 
  LOCATE('\'Cut Pages\'=', `perf_data`)>0;

-- 2- update hostname (execution time : < 7 sec / 141402 rows)
UPDATE `glpi_plugin_monitoring_hostcounters_tmp`
    INNER JOIN `glpi_plugin_monitoring_services` 
        ON (`glpi_plugin_monitoring_hostcounters_tmp`.`serviceId` = `glpi_plugin_monitoring_services`.`id`)
    INNER JOIN `glpi_plugin_monitoring_componentscatalogs_hosts` 
        ON (`glpi_plugin_monitoring_services`.`plugin_monitoring_componentscatalogs_hosts_id` = `glpi_plugin_monitoring_componentscatalogs_hosts`.`id`)
    INNER JOIN `glpi_computers` 
        ON (`glpi_plugin_monitoring_componentscatalogs_hosts`.`items_id` = `glpi_computers`.`id`)
SET
	hostname = `glpi_computers`.`name`;

-- 3 - clean table from rotten data (invalid counters and unknown hosts)
DELETE FROM `glpi_plugin_monitoring_hostcounters_tmp`
WHERE cutPages = '-1' OR cutPages = '0' OR hostname='unknown';

-- 4 - create temporary table with grouped data (execution time : < 1 sec / 141427 rows)
DROP TABLE IF EXISTS `glpi_plugin_monitoring_hostcounters_tmp_grouped`;
CREATE TABLE IF NOT EXISTS `glpi_plugin_monitoring_hostcounters_tmp_grouped` (
   `id` INT(11) NOT NULL AUTO_INCREMENT,
   `hostname` VARCHAR(255) DEFAULT NULL,
   `date` DATE DEFAULT NULL,
   `cutPages` INT(11) NOT NULL DEFAULT '0',
   `retractedPages` INT(11) NOT NULL DEFAULT '0',
   `printerChanged` INT(11) NOT NULL DEFAULT '0',
   `paperChanged` INT(11) NOT NULL DEFAULT '0',
   `binEmptied` INT(11) NOT NULL DEFAULT '0',
   PRIMARY KEY (`id`)
);
-- 5a - import data from old server ...
INSERT  INTO `glpi_plugin_monitoring_hostcounters_tmp_grouped`(`id`,`hostname`,`date`,`cutPages`,`retractedPages`,`printerChanged`,`paperChanged`,`binEmptied`) VALUES (1,'cnam-atm-0001','2013-11-20',484,33,0,0,0),(2,'cnam-atm-0001','2013-11-21',485,33,0,0,0),(3,'cnam-atm-0001','2013-11-22',486,33,0,0,0),(4,'cnam-atm-0001','2013-11-23',486,33,0,0,0),(5,'cnam-atm-0001','2013-11-24',486,33,0,0,0),(6,'cnam-atm-0001','2013-11-25',489,33,0,0,0),(7,'cnam-atm-0001','2013-11-26',491,33,0,0,0),(8,'cnam-atm-0001','2013-11-27',493,34,0,0,0),(9,'cnam-atm-0001','2013-11-28',502,36,0,0,0),(10,'cnam-atm-0001','2013-11-29',504,36,0,0,0),(11,'cnam-atm-0001','2013-11-30',504,36,0,0,0),(12,'cnam-atm-0001','2013-12-01',504,36,0,0,0),(13,'cnam-atm-0001','2013-12-02',506,36,0,0,0),(14,'cnam-atm-0001','2013-12-03',511,36,0,0,0),(15,'cnam-atm-0001','2013-12-04',512,36,0,0,0),(16,'ek3k-cnam-0002','2013-11-19',756,24,0,0,0),(17,'ek3k-cnam-0002','2013-11-20',760,25,0,0,0),(18,'ek3k-cnam-0002','2013-11-21',439,17,1,0,0),(19,'ek3k-cnam-0002','2013-11-22',762,25,1,0,0),(20,'ek3k-cnam-0002','2013-11-23',456,17,1,0,0),(21,'ek3k-cnam-0002','2013-11-24',456,17,1,0,0),(22,'ek3k-cnam-0002','2013-11-25',464,17,1,0,0),(23,'ek3k-cnam-0002','2013-11-26',316,32,1,0,0),(24,'ek3k-cnam-0002','2013-11-27',316,32,1,0,0),(25,'ek3k-cnam-0002','2013-11-28',815,25,1,0,0),(26,'ek3k-cnam-0003','2013-11-21',351,46,0,0,0),(27,'ek3k-cnam-0003','2013-11-22',351,46,0,0,0),(28,'ek3k-cnam-0003','2013-11-23',351,46,0,0,0),(29,'ek3k-cnam-0003','2013-11-24',351,46,0,0,0),(30,'ek3k-cnam-0003','2013-11-25',353,46,0,0,0),(31,'ek3k-cnam-0003','2013-11-26',353,46,0,0,0),(32,'ek3k-cnam-0003','2013-11-27',353,46,0,0,0),(33,'ek3k-cnam-0003','2013-11-28',353,46,0,0,0),(34,'ek3k-cnam-0003','2013-11-29',353,46,0,0,0),(35,'ek3k-cnam-0003','2013-11-30',353,46,0,0,0),(36,'ek3k-cnam-0003','2013-12-01',353,46,0,0,0),(37,'ek3k-cnam-0003','2013-12-02',353,46,0,0,0),(38,'ek3k-cnam-0003','2013-12-03',353,46,0,0,0),(39,'ek3k-cnam-0003','2013-12-04',353,46,0,0,0),(40,'ek3k-cnam-0003','2013-12-05',374,47,0,0,0),(41,'ek3k-cnam-0003','2013-12-06',374,47,0,0,0),(42,'ek3k-cnam-0003','2013-12-07',374,47,0,0,0),(43,'ek3k-cnam-0003','2013-12-08',374,47,0,0,0),(44,'ek3k-cnam-0003','2013-12-09',376,48,0,0,0),(45,'ek3k-cnam-0003','2013-12-10',379,48,0,0,0),(46,'ek3k-cnam-0003','2013-12-11',381,48,0,0,0),(47,'ek3k-cnam-0006','2013-11-27',375,6,0,0,0),(48,'ek3k-cnam-0006','2013-11-28',375,6,0,0,0),(49,'ek3k-cnam-0006','2013-11-29',383,6,0,0,0),(50,'ek3k-cnam-0006','2013-11-30',383,6,0,0,0),(51,'ek3k-cnam-0006','2013-12-01',383,6,0,0,0),(52,'ek3k-cnam-0006','2013-12-02',388,6,0,0,0),(53,'ek3k-cnam-0006','2013-12-03',392,6,0,0,0),(54,'ek3k-cnam-0006','2013-12-04',394,6,0,0,0),(55,'ek3k-cnam-0006','2013-12-05',396,6,0,0,0),(56,'ek3k-cnam-0006','2013-12-06',408,6,0,0,0),(57,'ek3k-cnam-0006','2013-12-07',408,6,0,0,0),(58,'ek3k-cnam-0006','2013-12-08',408,6,0,0,0),(59,'ek3k-cnam-0006','2013-12-09',410,6,0,0,0),(60,'ek3k-cnam-0006','2013-12-10',414,6,0,0,0),(61,'ek3k-cnam-0006','2013-12-11',414,6,0,0,0),(62,'ek3k-cnam-0010','2013-11-19',256,7,0,0,0),(63,'ek3k-cnam-0010','2013-11-20',292,7,0,0,0),(64,'ek3k-cnam-0010','2013-11-21',302,8,0,0,0),(65,'ek3k-cnam-0010','2013-11-22',337,9,0,0,0),(66,'ek3k-cnam-0010','2013-11-23',337,9,0,0,0),(67,'ek3k-cnam-0010','2013-11-24',337,9,0,0,0),(68,'ek3k-cnam-0010','2013-11-25',412,10,0,0,0),(69,'ek3k-cnam-0010','2013-11-26',429,10,0,0,0),(70,'ek3k-cnam-0010','2013-11-27',437,10,0,0,0),(71,'ek3k-cnam-0010','2013-11-28',446,10,0,0,0),(72,'ek3k-cnam-0010','2013-11-29',469,11,0,0,0),(73,'ek3k-cnam-0010','2013-11-30',469,11,0,0,0),(74,'ek3k-cnam-0010','2013-12-01',469,11,0,0,0),(75,'ek3k-cnam-0010','2013-12-02',487,11,0,0,0),(76,'ek3k-cnam-0010','2013-12-03',539,11,0,0,0),(77,'ek3k-cnam-0010','2013-12-04',567,11,0,0,0),(78,'ek3k-cnam-0010','2013-12-05',592,12,0,0,0),(79,'ek3k-cnam-0010','2013-12-06',658,13,0,0,0),(80,'ek3k-cnam-0010','2013-12-07',658,13,0,0,0),(81,'ek3k-cnam-0010','2013-12-08',658,13,0,0,0),(82,'ek3k-cnam-0010','2013-12-09',693,13,0,0,0),(83,'ek3k-cnam-0010','2013-12-10',775,13,0,0,0),(84,'ek3k-cnam-0010','2013-12-11',775,13,0,0,0),(85,'ek3k-cnam-0012','2013-11-20',223,4,0,0,0),(86,'ek3k-cnam-0012','2013-11-21',237,4,0,0,0),(87,'ek3k-cnam-0012','2013-11-22',257,4,0,0,0),(88,'ek3k-cnam-0012','2013-11-23',257,4,0,0,0),(89,'ek3k-cnam-0012','2013-11-24',257,4,0,0,0),(90,'ek3k-cnam-0012','2013-11-25',274,4,0,0,0),(91,'ek3k-cnam-0012','2013-11-26',286,4,0,0,0),(92,'ek3k-cnam-0012','2013-11-27',291,4,0,0,0),(93,'ek3k-cnam-0012','2013-11-28',293,4,0,0,0),(94,'ek3k-cnam-0012','2013-11-29',298,4,0,0,0),(95,'ek3k-cnam-0012','2013-11-30',298,4,0,0,0),(96,'ek3k-cnam-0012','2013-12-01',298,4,0,0,0),(97,'ek3k-cnam-0012','2013-12-02',321,4,0,0,0),(98,'ek3k-cnam-0012','2013-12-03',342,4,0,0,0),(99,'ek3k-cnam-0012','2013-12-04',346,4,0,0,0),(100,'ek3k-cnam-0012','2013-12-05',351,4,0,0,0),(101,'ek3k-cnam-0012','2013-12-06',419,4,0,0,0),(102,'ek3k-cnam-0012','2013-12-07',419,4,0,0,0),(103,'ek3k-cnam-0012','2013-12-08',419,4,0,0,0),(104,'ek3k-cnam-0012','2013-12-09',436,5,0,0,0),(105,'ek3k-cnam-0012','2013-12-10',458,5,0,0,0),(106,'ek3k-cnam-0012','2013-12-11',460,5,0,0,0),(107,'ek3k-cnam-0013','2013-11-28',219,5,0,0,0),(108,'ek3k-cnam-0013','2013-11-29',304,5,0,0,0),(109,'ek3k-cnam-0013','2013-11-30',304,5,0,0,0),(110,'ek3k-cnam-0013','2013-12-01',304,5,0,0,0),(111,'ek3k-cnam-0013','2013-12-02',374,5,0,0,0),(112,'ek3k-cnam-0013','2013-12-03',396,6,0,0,0),(113,'ek3k-cnam-0013','2013-12-04',500,6,0,0,0),(114,'ek3k-cnam-0013','2013-12-05',546,7,0,0,0),(115,'ek3k-cnam-0013','2013-12-06',616,8,0,0,0),(116,'ek3k-cnam-0013','2013-12-07',616,8,0,0,0),(117,'ek3k-cnam-0013','2013-12-08',616,8,0,0,0),(118,'ek3k-cnam-0013','2013-12-09',737,10,0,0,0),(119,'ek3k-cnam-0013','2013-12-10',750,10,0,0,0),(120,'ek3k-cnam-0013','2013-12-11',751,10,0,0,0),(121,'ek3k-cnam-0014','2013-11-19',291,4,0,0,0),(122,'ek3k-cnam-0014','2013-11-20',301,4,0,0,0),(123,'ek3k-cnam-0014','2013-11-21',312,5,0,0,0),(124,'ek3k-cnam-0014','2013-11-22',364,5,0,0,0),(125,'ek3k-cnam-0014','2013-11-23',364,5,0,0,0),(126,'ek3k-cnam-0014','2013-11-24',364,5,0,0,0),(127,'ek3k-cnam-0014','2013-11-25',445,5,0,0,0),(128,'ek3k-cnam-0014','2013-11-26',479,5,0,0,0),(129,'ek3k-cnam-0014','2013-11-27',499,5,0,0,0),(130,'ek3k-cnam-0014','2013-11-28',500,5,0,0,0),(131,'ek3k-cnam-0014','2013-11-29',500,5,0,0,0),(132,'ek3k-cnam-0014','2013-11-30',502,6,0,0,0),(133,'ek3k-cnam-0014','2013-12-01',502,6,0,0,0),(134,'ek3k-cnam-0014','2013-12-02',527,6,0,0,0),(135,'ek3k-cnam-0014','2013-12-03',540,6,0,0,0),(136,'ek3k-cnam-0014','2013-12-04',588,6,0,0,0),(137,'ek3k-cnam-0014','2013-12-05',595,6,0,0,0),(138,'ek3k-cnam-0014','2013-12-06',602,6,0,0,0),(139,'ek3k-cnam-0014','2013-12-07',602,6,0,0,0),(140,'ek3k-cnam-0014','2013-12-08',602,6,0,0,0),(141,'ek3k-cnam-0014','2013-12-09',638,6,0,0,0),(142,'ek3k-cnam-0014','2013-12-10',686,6,0,0,0),(143,'ek3k-cnam-0014','2013-12-11',686,6,0,0,0),(144,'ek3k-cnam-0015','2013-11-20',297,6,0,0,0),(145,'ek3k-cnam-0015','2013-11-21',320,7,0,0,0),(146,'ek3k-cnam-0015','2013-11-22',323,7,0,0,0),(147,'ek3k-cnam-0015','2013-11-23',323,7,0,0,0),(148,'ek3k-cnam-0015','2013-11-24',323,7,0,0,0),(149,'ek3k-cnam-0015','2013-11-25',323,7,0,0,0),(150,'ek3k-cnam-0015','2013-11-26',338,9,0,0,0),(151,'ek3k-cnam-0015','2013-11-27',355,10,0,0,0),(152,'ek3k-cnam-0015','2013-11-28',356,10,0,0,0),(153,'ek3k-cnam-0015','2013-11-29',359,10,0,0,0),(154,'ek3k-cnam-0015','2013-11-30',359,10,0,0,0),(155,'ek3k-cnam-0015','2013-12-01',359,10,0,0,0),(156,'ek3k-cnam-0015','2013-12-02',359,10,0,0,0),(157,'ek3k-cnam-0015','2013-12-03',359,10,0,0,0),(158,'ek3k-cnam-0015','2013-12-04',359,10,0,0,0),(159,'ek3k-cnam-0015','2013-12-05',367,10,0,0,0),(160,'ek3k-cnam-0015','2013-12-06',367,10,0,0,0),(161,'ek3k-cnam-0015','2013-12-07',367,10,0,0,0),(162,'ek3k-cnam-0015','2013-12-08',367,10,0,0,0),(163,'ek3k-cnam-0015','2013-12-09',367,10,0,0,0),(164,'ek3k-cnam-0015','2013-12-10',393,12,0,0,0),(165,'ek3k-cnam-0015','2013-12-11',393,12,0,0,0),(166,'ek3k-cnam-0016','2013-11-28',231,5,0,0,0),(167,'ek3k-cnam-0016','2013-11-29',312,5,0,0,0),(168,'ek3k-cnam-0016','2013-11-30',312,5,0,0,0),(169,'ek3k-cnam-0016','2013-12-01',312,5,0,0,0),(170,'ek3k-cnam-0016','2013-12-02',331,5,0,0,0),(171,'ek3k-cnam-0016','2013-12-03',336,5,0,0,0),(172,'ek3k-cnam-0016','2013-12-04',417,5,0,0,0),(173,'ek3k-cnam-0016','2013-12-05',427,5,0,0,0),(174,'ek3k-cnam-0016','2013-12-06',510,5,0,0,0),(175,'ek3k-cnam-0016','2013-12-07',510,5,0,0,0),(176,'ek3k-cnam-0016','2013-12-08',510,5,0,0,0),(177,'ek3k-cnam-0016','2013-12-09',617,5,0,0,0),(178,'ek3k-cnam-0016','2013-12-10',633,5,0,0,0),(179,'ek3k-cnam-0016','2013-12-11',633,5,0,0,0),(180,'ek3k-cnam-0017','2013-11-20',203,4,0,0,0),(181,'ek3k-cnam-0017','2013-11-21',218,4,0,0,0),(182,'ek3k-cnam-0017','2013-11-22',264,4,0,0,0),(183,'ek3k-cnam-0017','2013-11-23',264,4,0,0,0),(184,'ek3k-cnam-0017','2013-11-24',264,4,0,0,0),(185,'ek3k-cnam-0017','2013-11-25',287,4,0,0,0),(186,'ek3k-cnam-0017','2013-11-26',358,5,0,0,0),(187,'ek3k-cnam-0017','2013-11-27',375,5,0,0,0),(188,'ek3k-cnam-0017','2013-11-28',377,5,0,0,0),(189,'ek3k-cnam-0017','2013-11-29',437,6,0,0,0),(190,'ek3k-cnam-0017','2013-11-30',437,6,0,0,0),(191,'ek3k-cnam-0017','2013-12-01',437,6,0,0,0),(192,'ek3k-cnam-0017','2013-12-02',496,6,0,0,0),(193,'ek3k-cnam-0017','2013-12-03',532,6,0,0,0),(194,'ek3k-cnam-0017','2013-12-04',640,6,0,0,0),(195,'ek3k-cnam-0017','2013-12-05',648,6,0,0,0),(196,'ek3k-cnam-0017','2013-12-06',692,6,0,0,0),(197,'ek3k-cnam-0017','2013-12-07',692,6,0,0,0),(198,'ek3k-cnam-0017','2013-12-08',692,6,0,0,0),(199,'ek3k-cnam-0017','2013-12-09',787,8,0,0,0),(200,'ek3k-cnam-0017','2013-12-10',863,8,0,0,0),(201,'ek3k-cnam-0017','2013-12-11',863,8,0,0,0),(202,'ek3k-cnam-0018','2013-11-19',206,8,0,0,0),(203,'ek3k-cnam-0018','2013-11-20',212,8,0,0,0),(204,'ek3k-cnam-0018','2013-11-21',217,8,0,0,0),(205,'ek3k-cnam-0018','2013-11-22',310,11,0,0,0),(206,'ek3k-cnam-0018','2013-11-23',310,11,0,0,0),(207,'ek3k-cnam-0018','2013-11-24',310,11,0,0,0),(208,'ek3k-cnam-0018','2013-11-25',312,31,0,0,0),(209,'ek3k-cnam-0018','2013-11-26',549,31,0,0,0),(210,'ek3k-cnam-0018','2013-11-27',564,19,0,0,0),(211,'ek3k-cnam-0018','2013-11-28',572,19,0,0,0),(212,'ek3k-cnam-0018','2013-11-29',599,19,0,0,0),(213,'ek3k-cnam-0018','2013-11-30',599,19,0,0,0),(214,'ek3k-cnam-0018','2013-12-01',599,19,0,0,0),(215,'ek3k-cnam-0018','2013-12-02',629,19,0,0,0),(216,'ek3k-cnam-0018','2013-12-03',653,19,0,0,0),(217,'ek3k-cnam-0018','2013-12-04',674,19,0,0,0),(218,'ek3k-cnam-0018','2013-12-05',679,19,0,0,0),(219,'ek3k-cnam-0018','2013-12-06',731,19,0,0,0),(220,'ek3k-cnam-0018','2013-12-07',731,19,0,0,0),(221,'ek3k-cnam-0018','2013-12-08',731,19,0,0,0),(222,'ek3k-cnam-0018','2013-12-09',764,19,0,0,0),(223,'ek3k-cnam-0018','2013-12-10',820,19,0,0,0),(224,'ek3k-cnam-0018','2013-12-11',821,19,0,0,0),(225,'ek3k-cnam-0019','2013-11-20',305,7,0,0,0),(226,'ek3k-cnam-0019','2013-11-22',391,11,0,0,0),(227,'ek3k-cnam-0019','2013-11-23',391,11,0,0,0),(228,'ek3k-cnam-0019','2013-11-24',391,11,0,0,0),(229,'ek3k-cnam-0019','2013-11-25',439,11,0,0,0),(230,'ek3k-cnam-0019','2013-11-26',476,11,0,0,0),(231,'ek3k-cnam-0019','2013-11-27',487,11,0,0,0),(232,'ek3k-cnam-0019','2013-11-28',495,11,0,0,0),(233,'ek3k-cnam-0019','2013-11-29',561,11,0,0,0),(234,'ek3k-cnam-0019','2013-11-30',561,11,0,0,0),(235,'ek3k-cnam-0019','2013-12-01',561,11,0,0,0),(236,'ek3k-cnam-0019','2013-12-02',635,11,0,0,0),(237,'ek3k-cnam-0019','2013-12-03',663,11,0,0,0),(238,'ek3k-cnam-0019','2013-12-04',735,11,0,0,0),(239,'ek3k-cnam-0019','2013-12-05',746,11,0,0,0),(240,'ek3k-cnam-0019','2013-12-06',809,11,0,0,0),(241,'ek3k-cnam-0019','2013-12-07',809,11,0,0,0),(242,'ek3k-cnam-0019','2013-12-08',809,11,0,0,0),(243,'ek3k-cnam-0019','2013-12-09',914,11,0,0,0),(244,'ek3k-cnam-0019','2013-12-10',974,11,0,0,0),(245,'ek3k-cnam-0019','2013-12-11',974,11,0,0,0),(246,'ek3k-cnam-0020','2013-12-03',312,6,0,0,0),(247,'ek3k-cnam-0020','2013-12-04',345,3,0,0,0),(248,'ek3k-cnam-0020','2013-12-05',353,3,0,0,0),(249,'ek3k-cnam-0020','2013-12-06',457,3,0,0,0),(250,'ek3k-cnam-0020','2013-12-07',457,3,0,0,0),(251,'ek3k-cnam-0020','2013-12-08',457,3,0,0,0),(252,'ek3k-cnam-0020','2013-12-09',530,3,0,0,0),(253,'ek3k-cnam-0020','2013-12-10',559,3,0,0,0),(254,'ek3k-cnam-0020','2013-12-11',561,3,0,0,0),(255,'ek3k-cnam-0021','2013-11-29',249,9,0,0,0),(256,'ek3k-cnam-0021','2013-11-30',249,9,0,0,0),(257,'ek3k-cnam-0021','2013-12-01',249,9,0,0,0),(258,'ek3k-cnam-0021','2013-12-02',346,10,0,0,0),(259,'ek3k-cnam-0021','2013-12-04',371,10,0,0,0),(260,'ek3k-cnam-0021','2013-12-05',387,10,0,0,0),(261,'ek3k-cnam-0021','2013-12-06',477,10,0,0,0),(262,'ek3k-cnam-0021','2013-12-07',477,10,0,0,0),(263,'ek3k-cnam-0021','2013-12-08',477,10,0,0,0),(264,'ek3k-cnam-0021','2013-12-09',518,11,0,0,0),(265,'ek3k-cnam-0021','2013-12-10',550,11,0,0,0),(266,'ek3k-cnam-0021','2013-12-11',550,11,0,0,0),(267,'ek3k-cnam-0022','2013-11-29',276,6,0,0,0),(268,'ek3k-cnam-0022','2013-11-30',276,6,0,0,0),(269,'ek3k-cnam-0022','2013-12-01',276,6,0,0,0),(270,'ek3k-cnam-0022','2013-12-02',279,8,0,0,0),(271,'ek3k-cnam-0022','2013-12-03',280,8,0,0,0),(272,'ek3k-cnam-0022','2013-12-04',282,8,0,0,0),(273,'ek3k-cnam-0022','2013-12-10',415,11,0,0,0),(274,'ek3k-cnam-0022','2013-12-11',415,11,0,0,0),(275,'ek3k-cnam-0023','2013-11-28',307,10,0,0,0),(276,'ek3k-cnam-0023','2013-11-29',382,10,0,0,0),(277,'ek3k-cnam-0023','2013-11-30',382,10,0,0,0),(278,'ek3k-cnam-0023','2013-12-01',382,10,0,0,0),(279,'ek3k-cnam-0023','2013-12-02',461,11,0,0,0),(280,'ek3k-cnam-0023','2013-12-03',494,12,0,0,0),(281,'ek3k-cnam-0023','2013-12-04',570,13,0,0,0),(282,'ek3k-cnam-0023','2013-12-05',581,13,0,0,0),(283,'ek3k-cnam-0023','2013-12-06',664,14,0,0,0),(284,'ek3k-cnam-0023','2013-12-07',664,14,0,0,0),(285,'ek3k-cnam-0023','2013-12-08',664,14,0,0,0),(286,'ek3k-cnam-0023','2013-12-09',780,17,0,0,0),(287,'ek3k-cnam-0023','2013-12-10',863,17,0,0,0),(288,'ek3k-cnam-0023','2013-12-11',868,17,0,0,0),(289,'ek3k-cnam-0024','2013-11-29',294,4,0,0,0),(290,'ek3k-cnam-0024','2013-11-30',294,4,0,0,0),(291,'ek3k-cnam-0024','2013-12-01',294,4,0,0,0),(292,'ek3k-cnam-0024','2013-12-02',462,4,0,0,0),(293,'ek3k-cnam-0024','2013-12-03',626,4,0,0,0),(294,'ek3k-cnam-0024','2013-12-04',734,4,0,0,0),(295,'ek3k-cnam-0024','2013-12-05',782,4,0,0,0),(296,'ek3k-cnam-0024','2013-12-06',845,5,0,0,0),(297,'ek3k-cnam-0024','2013-12-07',845,5,0,0,0),(298,'ek3k-cnam-0024','2013-12-08',845,5,0,0,0),(299,'ek3k-cnam-0024','2013-12-09',955,5,0,0,0),(300,'ek3k-cnam-0024','2013-12-10',1033,5,0,0,0),(301,'ek3k-cnam-0024','2013-12-11',1039,5,0,0,0),(302,'ek3k-cnam-0025','2013-11-29',283,9,0,0,0),(303,'ek3k-cnam-0025','2013-11-30',283,9,0,0,0),(304,'ek3k-cnam-0025','2013-12-01',283,9,0,0,0),(305,'ek3k-cnam-0025','2013-12-02',363,9,0,0,0),(306,'ek3k-cnam-0025','2013-12-03',387,9,0,0,0),(307,'ek3k-cnam-0025','2013-12-04',392,9,0,0,0),(308,'ek3k-cnam-0025','2013-12-05',392,9,0,0,0),(309,'ek3k-cnam-0025','2013-12-06',395,9,0,0,0),(310,'ek3k-cnam-0025','2013-12-07',395,9,0,0,0),(311,'ek3k-cnam-0025','2013-12-08',395,9,0,0,0),(312,'ek3k-cnam-0025','2013-12-09',397,9,0,0,0),(313,'ek3k-cnam-0025','2013-12-10',397,9,0,0,0),(314,'ek3k-cnam-0025','2013-12-11',398,9,0,0,0),(315,'ek3k-cnam-0026','2013-11-29',257,8,0,0,0),(316,'ek3k-cnam-0026','2013-11-30',257,8,0,0,0),(317,'ek3k-cnam-0026','2013-12-01',257,8,0,0,0),(318,'ek3k-cnam-0026','2013-12-02',358,9,0,0,0),(319,'ek3k-cnam-0026','2013-12-03',412,9,0,0,0),(320,'ek3k-cnam-0026','2013-12-04',518,9,0,0,0),(321,'ek3k-cnam-0026','2013-12-05',526,9,0,0,0),(322,'ek3k-cnam-0026','2013-12-06',598,9,0,0,0),(323,'ek3k-cnam-0026','2013-12-07',598,9,0,0,0),(324,'ek3k-cnam-0026','2013-12-08',598,9,0,0,0),(325,'ek3k-cnam-0026','2013-12-09',674,9,0,0,0),(326,'ek3k-cnam-0026','2013-12-10',811,9,0,0,0),(327,'ek3k-cnam-0026','2013-12-11',811,9,0,0,0),(328,'ek3k-cnam-0028','2013-11-29',285,6,0,0,0),(329,'ek3k-cnam-0028','2013-11-30',285,6,0,0,0),(330,'ek3k-cnam-0028','2013-12-01',285,6,0,0,0),(331,'ek3k-cnam-0028','2013-12-02',298,8,0,0,0),(332,'ek3k-cnam-0028','2013-12-03',299,8,0,0,0),(333,'ek3k-cnam-0028','2013-12-04',450,14,0,0,0),(334,'ek3k-cnam-0028','2013-12-05',526,14,0,0,0),(335,'ek3k-cnam-0028','2013-12-06',592,14,0,0,0),(336,'ek3k-cnam-0028','2013-12-07',592,14,0,0,0),(337,'ek3k-cnam-0028','2013-12-08',592,14,0,0,0),(338,'ek3k-cnam-0028','2013-12-09',594,14,0,0,0),(339,'ek3k-cnam-0028','2013-12-10',652,14,0,0,0),(340,'ek3k-cnam-0028','2013-12-11',655,15,0,0,0),(341,'ek3k-cnam-0029','2013-11-28',269,6,0,0,0),(342,'ek3k-cnam-0029','2013-11-29',360,7,0,0,0),(343,'ek3k-cnam-0029','2013-11-30',360,7,0,0,0),(344,'ek3k-cnam-0029','2013-12-01',360,7,0,0,0),(345,'ek3k-cnam-0029','2013-12-02',403,7,0,0,0),(346,'ek3k-cnam-0029','2013-12-03',416,7,0,0,0),(347,'ek3k-cnam-0029','2013-12-04',476,7,0,0,0),(348,'ek3k-cnam-0029','2013-12-05',507,7,0,0,0),(349,'ek3k-cnam-0029','2013-12-06',560,8,0,0,0),(350,'ek3k-cnam-0029','2013-12-07',560,8,0,0,0),(351,'ek3k-cnam-0029','2013-12-08',560,8,0,0,0),(352,'ek3k-cnam-0029','2013-12-09',629,9,0,0,0),(353,'ek3k-cnam-0029','2013-12-10',662,9,0,0,0),(354,'ek3k-cnam-0029','2013-12-11',662,9,0,0,0),(355,'ek3k-cnam-0030','2013-12-02',361,14,0,0,0),(356,'ek3k-cnam-0030','2013-12-03',451,14,0,0,0),(357,'ek3k-cnam-0030','2013-12-04',517,15,0,0,0),(358,'ek3k-cnam-0030','2013-12-05',558,15,0,0,0),(359,'ek3k-cnam-0030','2013-12-06',604,16,0,0,0),(360,'ek3k-cnam-0030','2013-12-07',604,16,0,0,0),(361,'ek3k-cnam-0030','2013-12-08',604,16,0,0,0),(362,'ek3k-cnam-0030','2013-12-09',692,16,0,0,0),(363,'ek3k-cnam-0030','2013-12-10',777,16,0,0,0),(364,'ek3k-cnam-0030','2013-12-11',777,16,0,0,0),(365,'ek3k-cnam-0031','2013-11-28',229,5,0,0,0),(366,'ek3k-cnam-0031','2013-11-29',299,5,0,0,0),(367,'ek3k-cnam-0031','2013-11-30',299,5,0,0,0),(368,'ek3k-cnam-0031','2013-12-01',299,5,0,0,0),(369,'ek3k-cnam-0031','2013-12-02',378,5,0,0,0),(370,'ek3k-cnam-0031','2013-12-03',396,5,0,0,0),(371,'ek3k-cnam-0031','2013-12-04',534,5,0,0,0),(372,'ek3k-cnam-0031','2013-12-05',555,5,0,0,0),(373,'ek3k-cnam-0031','2013-12-06',606,6,0,0,0),(374,'ek3k-cnam-0031','2013-12-07',606,6,0,0,0),(375,'ek3k-cnam-0031','2013-12-08',606,6,0,0,0),(376,'ek3k-cnam-0031','2013-12-09',661,7,0,0,0),(377,'ek3k-cnam-0031','2013-12-10',765,9,0,0,0),(378,'ek3k-cnam-0031','2013-12-11',766,9,0,0,0),(379,'ek3k-cnam-0032','2013-11-21',186,5,0,0,0),(380,'ek3k-cnam-0032','2013-11-22',221,5,0,0,0),(381,'ek3k-cnam-0032','2013-11-23',221,5,0,0,0),(382,'ek3k-cnam-0032','2013-11-24',221,5,0,0,0),(383,'ek3k-cnam-0032','2013-11-25',287,6,0,0,0),(384,'ek3k-cnam-0032','2013-11-26',317,6,0,0,0),(385,'ek3k-cnam-0032','2013-11-27',343,6,0,0,0),(386,'ek3k-cnam-0032','2013-11-28',349,6,0,0,0),(387,'ek3k-cnam-0032','2013-11-29',379,6,0,0,0),(388,'ek3k-cnam-0032','2013-11-30',379,6,0,0,0),(389,'ek3k-cnam-0032','2013-12-01',379,6,0,0,0),(390,'ek3k-cnam-0032','2013-12-02',518,7,0,0,0),(391,'ek3k-cnam-0032','2013-12-03',549,9,0,0,0),(392,'ek3k-cnam-0032','2013-12-04',642,19,0,0,0),(393,'ek3k-cnam-0032','2013-12-05',660,19,0,0,0),(394,'ek3k-cnam-0032','2013-12-06',704,19,0,0,0),(395,'ek3k-cnam-0032','2013-12-07',704,19,0,0,0),(396,'ek3k-cnam-0032','2013-12-08',704,19,0,0,0),(397,'ek3k-cnam-0032','2013-12-09',819,19,0,0,0),(398,'ek3k-cnam-0032','2013-12-10',904,19,0,0,0),(399,'ek3k-cnam-0032','2013-12-11',906,19,0,0,0),(400,'ek3k-cnam-0033','2013-11-22',227,3,0,0,0),(401,'ek3k-cnam-0033','2013-11-23',227,3,0,0,0),(402,'ek3k-cnam-0033','2013-11-24',227,3,0,0,0),(403,'ek3k-cnam-0033','2013-11-25',245,3,0,0,0),(404,'ek3k-cnam-0033','2013-11-26',292,3,0,0,0),(405,'ek3k-cnam-0033','2013-11-27',343,3,0,0,0),(406,'ek3k-cnam-0033','2013-11-28',357,3,0,0,0),(407,'ek3k-cnam-0033','2013-11-29',389,3,0,0,0),(408,'ek3k-cnam-0033','2013-11-30',389,3,0,0,0),(409,'ek3k-cnam-0033','2013-12-01',389,3,0,0,0),(410,'ek3k-cnam-0033','2013-12-02',442,4,0,0,0),(411,'ek3k-cnam-0033','2013-12-03',493,5,0,0,0),(412,'ek3k-cnam-0033','2013-12-04',563,5,0,0,0),(413,'ek3k-cnam-0033','2013-12-05',589,7,0,0,0),(414,'ek3k-cnam-0033','2013-12-06',602,8,0,0,0),(415,'ek3k-cnam-0033','2013-12-07',602,8,0,0,0),(416,'ek3k-cnam-0033','2013-12-08',602,8,0,0,0),(417,'ek3k-cnam-0033','2013-12-09',641,9,0,0,0),(418,'ek3k-cnam-0033','2013-12-10',661,11,0,0,0),(419,'ek3k-cnam-0033','2013-12-11',662,11,0,0,0),(420,'ek3k-cnam-0034','2013-11-28',237,5,0,0,0),(421,'ek3k-cnam-0034','2013-11-29',324,6,0,0,0),(422,'ek3k-cnam-0034','2013-11-30',324,6,0,0,0),(423,'ek3k-cnam-0034','2013-12-01',324,6,0,0,0),(424,'ek3k-cnam-0034','2013-12-02',355,6,0,0,0),(425,'ek3k-cnam-0034','2013-12-03',398,6,0,0,0),(426,'ek3k-cnam-0034','2013-12-04',398,6,0,0,0),(427,'ek3k-cnam-0034','2013-12-05',417,7,0,0,0),(428,'ek3k-cnam-0034','2013-12-06',462,7,0,0,0),(429,'ek3k-cnam-0034','2013-12-07',462,7,0,0,0),(430,'ek3k-cnam-0034','2013-12-08',462,7,0,0,0),(431,'ek3k-cnam-0034','2013-12-09',505,7,0,0,0),(432,'ek3k-cnam-0034','2013-12-10',602,7,0,0,0),(433,'ek3k-cnam-0034','2013-12-11',602,7,0,0,0),(434,'ek3k-cnam-0035','2013-12-02',312,8,0,0,0),(435,'ek3k-cnam-0035','2013-12-03',358,8,0,0,0),(436,'ek3k-cnam-0035','2013-12-04',377,8,0,0,0),(437,'ek3k-cnam-0035','2013-12-05',384,8,0,0,0),(438,'ek3k-cnam-0035','2013-12-06',414,9,0,0,0),(439,'ek3k-cnam-0035','2013-12-07',414,9,0,0,0),(440,'ek3k-cnam-0035','2013-12-08',414,9,0,0,0),(441,'ek3k-cnam-0035','2013-12-09',461,9,0,0,0),(442,'ek3k-cnam-0035','2013-12-10',510,10,0,0,0),(443,'ek3k-cnam-0035','2013-12-11',510,10,0,0,0),(444,'ek3k-cnam-0036','2013-11-22',241,4,0,0,0),(445,'ek3k-cnam-0036','2013-11-23',241,4,0,0,0),(446,'ek3k-cnam-0036','2013-11-24',241,4,0,0,0),(447,'ek3k-cnam-0036','2013-11-25',246,4,0,0,0),(448,'ek3k-cnam-0036','2013-11-26',276,4,0,0,0),(449,'ek3k-cnam-0036','2013-11-27',289,4,0,0,0),(450,'ek3k-cnam-0036','2013-11-28',298,4,0,0,0),(451,'ek3k-cnam-0036','2013-11-29',342,4,0,0,0),(452,'ek3k-cnam-0036','2013-11-30',342,4,0,0,0),(453,'ek3k-cnam-0036','2013-12-01',342,4,0,0,0),(454,'ek3k-cnam-0036','2013-12-02',410,6,0,0,0),(455,'ek3k-cnam-0036','2013-12-03',411,6,0,0,0),(456,'ek3k-cnam-0036','2013-12-04',500,10,0,0,0),(457,'ek3k-cnam-0036','2013-12-05',519,10,0,0,0),(458,'ek3k-cnam-0036','2013-12-06',550,10,0,0,0),(459,'ek3k-cnam-0036','2013-12-07',550,10,0,0,0),(460,'ek3k-cnam-0036','2013-12-08',550,10,0,0,0),(461,'ek3k-cnam-0036','2013-12-09',599,10,0,0,0),(462,'ek3k-cnam-0036','2013-12-10',647,10,0,0,0),(463,'ek3k-cnam-0036','2013-12-11',650,10,0,0,0),(464,'ek3k-cnam-0037','2013-12-02',309,11,0,0,0),(465,'ek3k-cnam-0037','2013-12-03',363,12,0,0,0),(466,'ek3k-cnam-0037','2013-12-04',407,13,0,0,0),(467,'ek3k-cnam-0037','2013-12-05',429,13,0,0,0),(468,'ek3k-cnam-0037','2013-12-06',488,13,0,0,0),(469,'ek3k-cnam-0037','2013-12-07',488,13,0,0,0),(470,'ek3k-cnam-0037','2013-12-08',488,13,0,0,0),(471,'ek3k-cnam-0037','2013-12-09',569,13,0,0,0),(472,'ek3k-cnam-0037','2013-12-10',605,13,0,0,0),(473,'ek3k-cnam-0037','2013-12-11',605,13,0,0,0),(474,'ek3k-cnam-0038','2013-11-28',220,6,0,0,0),(475,'ek3k-cnam-0038','2013-11-29',266,6,0,0,0),(476,'ek3k-cnam-0038','2013-11-30',266,6,0,0,0),(477,'ek3k-cnam-0038','2013-12-01',266,6,0,0,0),(478,'ek3k-cnam-0038','2013-12-02',304,6,0,0,0),(479,'ek3k-cnam-0038','2013-12-03',338,6,0,0,0),(480,'ek3k-cnam-0038','2013-12-04',373,6,0,0,0),(481,'ek3k-cnam-0038','2013-12-05',380,6,0,0,0),(482,'ek3k-cnam-0038','2013-12-06',422,7,0,0,0),(483,'ek3k-cnam-0038','2013-12-07',422,7,0,0,0),(484,'ek3k-cnam-0038','2013-12-08',422,7,0,0,0),(485,'ek3k-cnam-0038','2013-12-09',468,7,0,0,0),(486,'ek3k-cnam-0038','2013-12-10',512,8,0,0,0),(487,'ek3k-cnam-0038','2013-12-11',512,8,0,0,0),(488,'ek3k-cnam-0039','2013-11-21',216,9,0,0,0),(489,'ek3k-cnam-0039','2013-11-22',339,20,0,0,0),(490,'ek3k-cnam-0039','2013-11-23',334,12,1,0,0),(491,'ek3k-cnam-0039','2013-11-24',334,12,1,0,0),(492,'ek3k-cnam-0039','2013-11-25',346,12,1,0,0),(493,'ek3k-cnam-0039','2013-11-26',386,13,1,0,0),(494,'ek3k-cnam-0039','2013-11-27',417,13,1,0,0),(495,'ek3k-cnam-0039','2013-11-28',432,13,1,0,0),(496,'ek3k-cnam-0039','2013-11-29',464,13,1,0,0),(497,'ek3k-cnam-0039','2013-11-30',464,13,1,0,0),(498,'ek3k-cnam-0039','2013-12-01',464,13,1,0,0),(499,'ek3k-cnam-0039','2013-12-02',519,13,1,0,0),(500,'ek3k-cnam-0039','2013-12-03',640,13,1,0,0),(501,'ek3k-cnam-0039','2013-12-04',735,14,1,0,0),(502,'ek3k-cnam-0039','2013-12-05',763,14,1,0,0),(503,'ek3k-cnam-0039','2013-12-06',788,15,1,0,0),(504,'ek3k-cnam-0039','2013-12-07',788,15,1,0,0),(505,'ek3k-cnam-0039','2013-12-08',788,15,1,0,0),(506,'ek3k-cnam-0039','2013-12-09',863,16,1,0,0),(507,'ek3k-cnam-0039','2013-12-10',945,17,1,0,0),(508,'ek3k-cnam-0039','2013-12-11',945,17,1,0,0),(509,'ek3k-cnam-0040','2013-12-05',229,4,0,0,0),(510,'ek3k-cnam-0040','2013-12-06',258,4,0,0,0),(511,'ek3k-cnam-0040','2013-12-07',258,4,0,0,0),(512,'ek3k-cnam-0040','2013-12-08',258,4,0,0,0),(513,'ek3k-cnam-0040','2013-12-09',293,6,0,0,0),(514,'ek3k-cnam-0040','2013-12-10',357,7,0,0,0),(515,'ek3k-cnam-0040','2013-12-11',357,7,0,0,0),(516,'ek3k-cnam-0041','2013-12-05',263,6,0,0,0),(517,'ek3k-cnam-0041','2013-12-06',303,7,0,0,0),(518,'ek3k-cnam-0041','2013-12-07',303,7,0,0,0),(519,'ek3k-cnam-0041','2013-12-08',303,7,0,0,0),(520,'ek3k-cnam-0041','2013-12-09',323,7,0,0,0),(521,'ek3k-cnam-0041','2013-12-10',360,7,0,0,0),(522,'ek3k-cnam-0041','2013-12-11',360,7,0,0,0),(523,'ek3k-cnam-0042','2013-12-05',256,8,0,0,0),(524,'ek3k-cnam-0042','2013-12-06',283,8,0,0,0),(525,'ek3k-cnam-0042','2013-12-07',283,8,0,0,0),(526,'ek3k-cnam-0042','2013-12-08',283,8,0,0,0),(527,'ek3k-cnam-0042','2013-12-09',339,8,0,0,0),(528,'ek3k-cnam-0042','2013-12-10',396,8,0,0,0),(529,'ek3k-cnam-0042','2013-12-11',396,8,0,0,0),(530,'ek3k-cnam-0044','2013-12-10',235,9,0,0,0),(531,'ek3k-cnam-0044','2013-12-11',235,9,0,0,0),(532,'ek3k-cnam-0045','2013-12-09',217,5,0,0,0),(533,'ek3k-cnam-0045','2013-12-10',295,5,0,0,0),(534,'ek3k-cnam-0045','2013-12-11',295,5,0,0,0),(535,'ek3k-cnam-0046','2013-12-05',291,4,0,0,0),(536,'ek3k-cnam-0046','2013-12-06',303,4,0,0,0),(537,'ek3k-cnam-0046','2013-12-07',303,4,0,0,0),(538,'ek3k-cnam-0046','2013-12-08',303,4,0,0,0),(539,'ek3k-cnam-0046','2013-12-09',338,4,0,0,0),(540,'ek3k-cnam-0046','2013-12-10',350,4,0,0,0),(541,'ek3k-cnam-0046','2013-12-11',353,4,0,0,0),(542,'ek3k-cnam-0047','2013-12-05',209,6,0,0,0),(543,'ek3k-cnam-0047','2013-12-06',295,6,0,0,0),(544,'ek3k-cnam-0047','2013-12-07',295,6,0,0,0),(545,'ek3k-cnam-0047','2013-12-08',295,6,0,0,0),(546,'ek3k-cnam-0047','2013-12-09',320,6,0,0,0),(547,'ek3k-cnam-0047','2013-12-10',364,6,0,0,0),(548,'ek3k-cnam-0047','2013-12-11',366,6,0,0,0),(549,'ek3k-cnam-0048','2013-12-04',233,4,0,0,0),(550,'ek3k-cnam-0048','2013-12-05',264,4,0,0,0),(551,'ek3k-cnam-0048','2013-12-06',306,4,0,0,0),(552,'ek3k-cnam-0048','2013-12-07',306,4,0,0,0),(553,'ek3k-cnam-0048','2013-12-08',306,4,0,0,0),(554,'ek3k-cnam-0048','2013-12-09',443,6,0,0,0),(555,'ek3k-cnam-0048','2013-12-10',491,7,0,0,0),(556,'ek3k-cnam-0048','2013-12-11',491,7,0,0,0),(557,'ek3k-cnam-0049','2013-12-06',288,6,0,0,0),(558,'ek3k-cnam-0049','2013-12-07',288,6,0,0,0),(559,'ek3k-cnam-0049','2013-12-08',288,6,0,0,0),(560,'ek3k-cnam-0049','2013-12-09',342,6,0,0,0),(561,'ek3k-cnam-0049','2013-12-10',342,6,0,0,0),(562,'ek3k-cnam-0049','2013-12-11',351,6,0,0,0),(563,'ek3k-cnam-0050','2013-12-04',237,5,0,0,0),(564,'ek3k-cnam-0050','2013-12-05',249,5,0,0,0),(565,'ek3k-cnam-0050','2013-12-06',261,5,0,0,0),(566,'ek3k-cnam-0050','2013-12-07',261,5,0,0,0),(567,'ek3k-cnam-0050','2013-12-08',261,5,0,0,0),(568,'ek3k-cnam-0050','2013-12-09',293,5,0,0,0),(569,'ek3k-cnam-0050','2013-12-10',333,5,0,0,0),(570,'ek3k-cnam-0050','2013-12-11',333,5,0,0,0),(571,'ek3k-cnam-0051','2013-12-04',254,5,0,0,0),(572,'ek3k-cnam-0051','2013-12-05',285,5,0,0,0),(573,'ek3k-cnam-0051','2013-12-06',286,5,0,0,0),(574,'ek3k-cnam-0051','2013-12-07',286,5,0,0,0),(575,'ek3k-cnam-0051','2013-12-08',286,5,0,0,0),(576,'ek3k-cnam-0051','2013-12-09',300,5,0,0,0),(577,'ek3k-cnam-0051','2013-12-10',333,5,0,0,0),(578,'ek3k-cnam-0051','2013-12-11',333,5,0,0,0),(579,'ek3k-cnam-0052','2013-12-05',225,6,0,0,0),(580,'ek3k-cnam-0052','2013-12-06',254,6,0,0,0),(581,'ek3k-cnam-0052','2013-12-07',254,6,0,0,0),(582,'ek3k-cnam-0052','2013-12-08',254,6,0,0,0),(583,'ek3k-cnam-0052','2013-12-09',289,6,0,0,0),(584,'ek3k-cnam-0052','2013-12-10',349,7,0,0,0),(585,'ek3k-cnam-0052','2013-12-11',349,7,0,0,0),(586,'ek3k-cnam-0055','2013-12-09',333,6,0,0,0),(587,'ek3k-cnam-0055','2013-12-10',333,6,0,0,0),(588,'ek3k-cnam-0055','2013-12-11',333,6,0,0,0),(589,'ek3k-cnam-0056','2013-12-05',244,6,0,0,0),(590,'ek3k-cnam-0056','2013-12-06',287,6,0,0,0),(591,'ek3k-cnam-0056','2013-12-07',287,6,0,0,0),(592,'ek3k-cnam-0056','2013-12-08',287,6,0,0,0),(593,'ek3k-cnam-0056','2013-12-09',348,6,0,0,0),(594,'ek3k-cnam-0056','2013-12-10',444,7,0,0,0),(595,'ek3k-cnam-0056','2013-12-11',446,7,0,0,0),(596,'ek3k-cnam-0057','2013-12-04',241,6,0,0,0),(597,'ek3k-cnam-0057','2013-12-05',242,6,0,0,0),(598,'ek3k-cnam-0057','2013-12-06',268,8,0,0,0),(599,'ek3k-cnam-0057','2013-12-07',268,8,0,0,0),(600,'ek3k-cnam-0057','2013-12-08',268,8,0,0,0),(601,'ek3k-cnam-0057','2013-12-09',300,9,0,0,0),(602,'ek3k-cnam-0057','2013-12-10',358,9,0,0,0),(603,'ek3k-cnam-0057','2013-12-11',360,9,0,0,0),(604,'ek3k-cnam-0058','2013-12-05',202,5,0,0,0),(605,'ek3k-cnam-0058','2013-12-06',234,5,0,0,0),(606,'ek3k-cnam-0058','2013-12-07',234,5,0,0,0),(607,'ek3k-cnam-0058','2013-12-08',234,5,0,0,0),(608,'ek3k-cnam-0058','2013-12-09',296,5,0,0,0),(609,'ek3k-cnam-0058','2013-12-10',327,5,0,0,0),(610,'ek3k-cnam-0058','2013-12-11',327,5,0,0,0),(611,'ek3k-cnam-0059','2013-12-09',262,8,0,0,0),(612,'ek3k-cnam-0059','2013-12-10',338,9,0,0,0),(613,'ek3k-cnam-0059','2013-12-11',338,9,0,0,0),(614,'ek3k-cnam-0061','2013-12-09',245,4,0,0,0),(615,'ek3k-cnam-0061','2013-12-10',329,4,0,0,0),(616,'ek3k-cnam-0061','2013-12-11',329,4,0,0,0),(617,'ek3k-cnam-0062','2013-12-06',230,5,0,0,0),(618,'ek3k-cnam-0062','2013-12-07',230,5,0,0,0),(619,'ek3k-cnam-0062','2013-12-08',230,5,0,0,0),(620,'ek3k-cnam-0062','2013-12-09',287,7,0,0,0),(621,'ek3k-cnam-0062','2013-12-10',289,7,0,0,0),(622,'ek3k-cnam-0062','2013-12-11',296,7,0,0,0),(623,'ek3k-cnam-0063','2013-12-05',210,4,0,0,0),(624,'ek3k-cnam-0063','2013-12-06',220,4,0,0,0),(625,'ek3k-cnam-0063','2013-12-07',220,4,0,0,0),(626,'ek3k-cnam-0063','2013-12-08',220,4,0,0,0),(627,'ek3k-cnam-0063','2013-12-09',244,4,0,0,0),(628,'ek3k-cnam-0063','2013-12-10',291,4,0,0,0),(629,'ek3k-cnam-0063','2013-12-11',296,4,0,0,0),(630,'ek3k-cnam-0065','2013-12-05',227,4,0,0,0),(631,'ek3k-cnam-0065','2013-12-06',249,4,0,0,0),(632,'ek3k-cnam-0065','2013-12-07',249,4,0,0,0),(633,'ek3k-cnam-0065','2013-12-08',249,4,0,0,0),(634,'ek3k-cnam-0065','2013-12-09',274,4,0,0,0),(635,'ek3k-cnam-0065','2013-12-10',296,4,0,0,0),(636,'ek3k-cnam-0065','2013-12-11',296,4,0,0,0),(637,'ek3k-cnam-0066','2013-12-10',229,6,0,0,0),(638,'ek3k-cnam-0066','2013-12-11',229,6,0,0,0),(639,'ek3k-cnam-0067','2013-12-04',290,6,0,0,0),(640,'ek3k-cnam-0067','2013-12-05',381,6,0,0,0),(641,'ek3k-cnam-0067','2013-12-06',423,6,0,0,0),(642,'ek3k-cnam-0067','2013-12-07',423,6,0,0,0),(643,'ek3k-cnam-0067','2013-12-08',423,6,0,0,0),(644,'ek3k-cnam-0067','2013-12-09',561,6,0,0,0),(645,'ek3k-cnam-0067','2013-12-10',605,6,0,0,0),(646,'ek3k-cnam-0067','2013-12-11',605,6,0,0,0),(647,'ek3k-cnam-0068','2013-12-05',212,5,0,0,0),(648,'ek3k-cnam-0068','2013-12-06',260,5,0,0,0),(649,'ek3k-cnam-0068','2013-12-07',260,5,0,0,0),(650,'ek3k-cnam-0068','2013-12-08',260,5,0,0,0),(651,'ek3k-cnam-0068','2013-12-09',301,5,0,0,0),(652,'ek3k-cnam-0068','2013-12-10',340,5,0,0,0),(653,'ek3k-cnam-0068','2013-12-11',340,5,0,0,0),(654,'ek3k-cnam-0069','2013-12-10',225,5,0,0,0),(655,'ek3k-cnam-0069','2013-12-11',225,5,0,0,0),(656,'ek3k-cnam-0070','2013-12-04',256,8,0,0,0),(657,'ek3k-cnam-0070','2013-12-05',276,8,0,0,0),(658,'ek3k-cnam-0070','2013-12-06',364,8,0,0,0),(659,'ek3k-cnam-0070','2013-12-07',364,8,0,0,0),(660,'ek3k-cnam-0070','2013-12-08',364,8,0,0,0),(661,'ek3k-cnam-0070','2013-12-09',394,10,0,0,0),(662,'ek3k-cnam-0070','2013-12-10',394,10,0,0,0),(663,'ek3k-cnam-0070','2013-12-11',394,10,0,0,0),(664,'ek3k-cnam-0071','2013-12-05',209,4,0,0,0),(665,'ek3k-cnam-0071','2013-12-06',229,5,0,0,0),(666,'ek3k-cnam-0071','2013-12-07',229,5,0,0,0),(667,'ek3k-cnam-0071','2013-12-08',229,5,0,0,0),(668,'ek3k-cnam-0071','2013-12-09',291,5,0,0,0),(669,'ek3k-cnam-0071','2013-12-10',346,5,0,0,0),(670,'ek3k-cnam-0071','2013-12-11',348,5,0,0,0),(671,'ek3k-cnam-0072','2013-12-06',278,4,0,0,0),(672,'ek3k-cnam-0072','2013-12-07',278,4,0,0,0),(673,'ek3k-cnam-0072','2013-12-08',278,4,0,0,0),(674,'ek3k-cnam-0072','2013-12-09',323,4,0,0,0),(675,'ek3k-cnam-0072','2013-12-10',349,4,0,0,0),(676,'ek3k-cnam-0072','2013-12-11',352,4,0,0,0),(677,'ek3k-cnam-0073','2013-12-04',269,5,0,0,0),(678,'ek3k-cnam-0073','2013-12-05',299,5,0,0,0),(679,'ek3k-cnam-0073','2013-12-06',425,5,0,0,0),(680,'ek3k-cnam-0073','2013-12-07',425,5,0,0,0),(681,'ek3k-cnam-0073','2013-12-08',425,5,0,0,0),(682,'ek3k-cnam-0073','2013-12-09',516,6,0,0,0),(683,'ek3k-cnam-0073','2013-12-10',581,6,0,0,0),(684,'ek3k-cnam-0073','2013-12-11',589,6,0,0,0),(685,'ek3k-cnam-0074','2013-12-09',277,5,0,0,0),(686,'ek3k-cnam-0074','2013-12-10',333,5,0,0,0),(687,'ek3k-cnam-0074','2013-12-11',333,5,0,0,0),(688,'ek3k-cnam-0075','2013-12-09',244,6,0,0,0),(689,'ek3k-cnam-0075','2013-12-10',261,6,0,0,0),(690,'ek3k-cnam-0075','2013-12-11',261,6,0,0,0),(691,'ek3k-cnam-0091','2013-12-11',148,4,0,0,0),(692,'ek3k-cnam-0098','2013-12-10',130,4,0,0,0),(693,'ek3k-cnam-0098','2013-12-11',130,4,0,0,0);

-- 5b - insert data from current server ...
INSERT  INTO `glpi_plugin_monitoring_hostcounters_tmp_grouped`(`hostname`,`date`,`cutPages`,`retractedPages`,`printerChanged`,`paperChanged`,`binEmptied`) 
SELECT 
  hostname
  , DATE(DATE) AS DATE
  , MAX(cutPages) AS cutPages
  , MAX(retractedPages) AS retractedPages
  , MAX(printerChanged) AS printerChanged
  , MAX(paperChanged) AS paperChanged
  , MAX(binEmptied) AS binEmptied
FROM `glpi_plugin_monitoring_hostcounters_tmp`
GROUP BY hostname, DATE(DATE);

-- 6 - analyse table to find out inconsistancies (decreasing counters ...)
-- This query allow to display the days when printer has been changed (cut pages counter decreased or heavily increased (> 500 pages) !)
SELECT 
  t.hostname
  , t.DATE AS _day
  , t.cutPages AS _day_printerChanged
  , tu.DATE AS _dayBefore
  , tu.cutPages AS _dayBefore_cutPages
FROM `glpi_plugin_monitoring_hostcounters_tmp_grouped` AS t
   JOIN `glpi_plugin_monitoring_hostcounters_tmp_grouped` AS tu
      ON tu.hostname=t.hostname AND DATE(tu.date)=DATE(DATE_SUB(t.date, INTERVAL 1 DAY))
WHERE
  t.cutPages < tu.cutPages
  OR
  t.cutPages > tu.cutPages+500
  ;


-- 7 - update grouped table for paper changed, printer changed and bin emptied counters ...
-- Mainly hand update ... automation may be very dangerous !
-- If previous query showed a printer changed on 2013-19-22 for computer ek3k-cnam-0002,
-- then increment printer changed counter from 2013-19-22 up to now !
UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0002' AND DATE > '2013-11-20';
UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0002' AND DATE > '2013-11-22';
UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0002' AND DATE > '2013-11-25';

UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0039' AND DATE > '2013-11-22';

UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0019' AND DATE > '2013-12-30';

UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0116' AND DATE > '2014-01-24';

UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0140' AND DATE > '2014-01-14';

UPDATE `glpi_plugin_monitoring_hostcounters_tmp_grouped`
SET printerChanged = printerChanged+1
WHERE hostname='ek3k-cnam-0014' AND DATE > '2013-12-29';

-- 8 - empty and then update tables (execution time : < 7 sec / 27915 rows)
TRUNCATE TABLE `glpi_plugin_monitoring_hostcounters`;
TRUNCATE TABLE `glpi_plugin_monitoring_hostdailycounters`;
-- TRUNCATE TABLE `glpi_plugin_monitoring_import_logs`;

INSERT INTO glpi_plugin_monitoring_hostcounters ( `hostname`, `date`, `counter`, `value` ) 
SELECT `hostname`, `date`, 'cPagesTotal' AS counter, cutPages AS VALUE
FROM `glpi_plugin_monitoring_hostcounters_tmp_grouped`

UNION SELECT `hostname`, `date`, 'cRetractedTotal' AS counter, retractedPages AS VALUE
FROM `glpi_plugin_monitoring_hostcounters_tmp_grouped`

UNION SELECT `hostname`, `date`, 'cPrinterChanged' AS counter, printerChanged AS VALUE
FROM `glpi_plugin_monitoring_hostcounters_tmp_grouped`

UNION SELECT `hostname`, `date`, 'cPaperChanged' AS counter, paperChanged AS VALUE
FROM `glpi_plugin_monitoring_hostcounters_tmp_grouped`

UNION SELECT `hostname`, `date`, 'cBinEmptied' AS counter, binEmptied AS VALUE
FROM `glpi_plugin_monitoring_hostcounters_tmp_grouped`

ORDER BY hostname, DATE ASC, counter;