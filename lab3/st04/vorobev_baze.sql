-- phpMyAdmin SQL Dump
-- version 4.2.7
-- http://www.phpmyadmin.net
--
-- Host: localhost:8889
-- Generation Time: Jan 15, 2015 at 08:30 PM
-- Server version: 5.6.17-debug-log
-- PHP Version: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `vorobev_baze`
--

-- --------------------------------------------------------

--
-- Table structure for table `g_koop`
--

CREATE TABLE IF NOT EXISTS `g_koop` (
  `name` text NOT NULL,
  `marka` text,
  `number` int(10) DEFAULT NULL,
  `schet` int(50) DEFAULT NULL,
  `nochnoevremya` varchar(50) DEFAULT 'net'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `g_koop`
--

INSERT INTO `g_koop` (`name`, `marka`, `number`, `schet`, `nochnoevremya`) VALUES
('Nikita', 'Mazda', 123, 6543, 'net'),
('Volodya', 'Deo', 1246, 9576, 'net'),
('Masha', 'Kia', 675, 128574, 'da'),
('Afanasii', 'Volga', 876, 124854, 'da');

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
