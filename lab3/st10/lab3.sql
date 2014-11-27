-- phpMyAdmin SQL Dump
-- version 3.4.11.1deb2+deb7u1
-- http://www.phpmyadmin.net
--
-- Хост: localhost
-- Время создания: Ноя 25 2014 г., 13:07
-- Версия сервера: 5.5.38
-- Версия PHP: 5.4.4-14+deb7u14

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- База данных: `lab3`
--

-- --------------------------------------------------------

--
-- Структура таблицы `st10_object`
--

CREATE TABLE IF NOT EXISTS `st10_object` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(32) CHARACTER SET utf8 NOT NULL DEFAULT 'default',
  `date_added` datetime NOT NULL,
  `date_changed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `date_added` (`date_added`)
) ENGINE=InnoDB  DEFAULT CHARSET=cp866;

-- --------------------------------------------------------

--
-- Структура таблицы `st10_object_property`
--

CREATE TABLE IF NOT EXISTS `st10_object_property` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `object_id` int(11) NOT NULL,
  `code` varchar(64) CHARACTER SET utf8 NOT NULL,
  `value` varchar(255) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`id`),
  KEY `object_id` (`object_id`),
  KEY `property_code` (`code`)
) ENGINE=InnoDB  DEFAULT CHARSET=cp866;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
