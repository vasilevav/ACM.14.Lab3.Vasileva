-- MySQL dump 10.13  Distrib 5.6.17, for Win64 (x86_64)
--
-- Host: localhost    Database: data
-- ------------------------------------------------------
-- Server version	5.6.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `table`
--

DROP TABLE IF EXISTS `table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `table` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(45) DEFAULT NULL,
  `SurName` varchar(45) DEFAULT NULL,
  `Age` varchar(45) DEFAULT NULL,
  `Sth` varchar(45) DEFAULT NULL,
  `Status` varchar(1) DEFAULT NULL,
  `Sth1` varchar(45) DEFAULT NULL,
  `Sth2` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `ID_UNIQUE` (`ID`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `table`
--

LOCK TABLES `table` WRITE;
/*!40000 ALTER TABLE `table` DISABLE KEYS */;
INSERT INTO `table` VALUES (1,'╨Ы╤О╤Б╨╕\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','╨е╨░╤А╤В╤Д╨╕╨╗╨╕╤П\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','17\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','╨Ч╨░╨║╨╗╨╕╨╜╨░╤В╨╡╨╗╤М╨╜╨╕╤Ж╨░ ╨┤╤Г╤Е╨╛╨▓\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','-','',''),(2,'╨Э╨░╤Ж╤Г\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','╨Ф╤А╨░╨│╨╜╨╕╨╗\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','???\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','╨Я╨░╤Д╨╛╤Б!!!\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n','+','╨Ъ╤А╤Г╤В ╨╜╨░╤Б╤В╨╛╨╗╤М╨║╨╛ ╤З╤В╨╛ ╨╕╨╝╨╡╨╡╤В\n','╨┤╨╛╨┐╨╛╨╗╨╜╨╕╤В╨╡╨╗╤М╨╜╤Л╨╡ ╨┐╨╛╨╗╤П\n'),(3,'╨б╨░╤А╨░\n\n\n\n\n\n\n\n','╨Ъ╨╡╤А╤А╨╕╨│╨░╨╜\n\n\n\n\n\n\n\n','26\n\n\n\n\n\n\n\n','╨Ъ╨╛╤А╨╛╨╗╨╡╨▓╨░ ╨║╨╗╨╕╨╜╨║╨╛╨▓\n\n\n\n\n\n\n\n','-','',''),(4,'╨е╤Н╨┐╨┐╨╕\n\n','╨Ш╨║╤Б╨╕╨┤\n\n','6\n\n','╨б╨╕╨╜╨╕╨╣ ╨║╨╛╤В╨╕╨║ ╤Б ╨║╤А╤Л╨╗╤М╤П╨╝╨╕\n\n','-','','');
/*!40000 ALTER TABLE `table` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-11-18  8:06:51
