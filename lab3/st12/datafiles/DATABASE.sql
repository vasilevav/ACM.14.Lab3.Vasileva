-- MySQL dump 10.13  Distrib 5.6.17, for Win64 (x86_64)
--
-- Host: localhost    Database: db
-- ------------------------------------------------------
-- Server version	5.6.17

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
-- Table structure for table `myitems`
--

DROP TABLE IF EXISTS `myitems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `myitems` (
  `ID` int(11) NOT NULL,
  `Название` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Жесткость` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Прогиб` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Ширина` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Система_закладных` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Форма` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Сердечник` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Супердоска` int(11) DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_general_cs;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `myitems`
--

LOCK TABLES `myitems` WRITE;
/*!40000 ALTER TABLE `myitems` DISABLE KEYS */;
INSERT INTO `myitems` VALUES (1,'Mystery','Twin Flex','Camber','Стандартная','The Channel','Directional Shape','Ultrafly Core',0),(2,'Vapor','Жесткая доска','Flying-V','wide','ICS','Camber','Ultrafly with Multizone ESD',0),(3,'Antler','средняя','Flying-V','стандартная','ICS','Scoop','Jumper Cables',0),(4,'Custom X','Жесткая доска','традиционный','стандартная и wide','ICS','Directional','Dragonfly with Multizone EGD',1);
/*!40000 ALTER TABLE `myitems` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-11-21  8:06:56
