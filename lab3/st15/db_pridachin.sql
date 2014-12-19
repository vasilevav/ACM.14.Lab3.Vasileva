-- phpMyAdmin SQL Dump
-- version 4.1.14
-- http://www.phpmyadmin.net
--
-- Хост: 127.0.0.1
-- Время создания: Дек 19 2014 г., 12:08
-- Версия сервера: 5.6.17
-- Версия PHP: 5.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES cp1251 */;

--
-- База данных: `db_pridachin`
--

-- --------------------------------------------------------

--
-- Структура таблицы `mytable`
--

CREATE TABLE IF NOT EXISTS `mytable` (
  `ID` int(11) NOT NULL,
  `Name` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Attribute1` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Attribute2` tinytext COLLATE cp1251_general_cs NOT NULL,
  `Attribute3` tinytext COLLATE cp1251_general_cs NOT NULL,
  `UniqueAttribute` int(11) DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_general_cs;

--
-- Дамп данных таблицы `mytable`
--

INSERT INTO `mytable` (`ID`, `Name`, `Attribute1`, `Attribute2`, `Attribute3`, `UniqueAttribute`) VALUES
(1, 'u1', '1', '2', '3', 1);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
