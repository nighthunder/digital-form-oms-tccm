-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 01, 2021 at 10:28 AM
-- Server version: 10.4.21-MariaDB
-- PHP Version: 7.3.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vodan_br_bd_2021`
--

-- --------------------------------------------------------

--
-- Table structure for table `tb_questionnaire`
--

CREATE TABLE `tb_questionnaire` (
  `questionnaireID` int(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `questionnaireStatusID` int(10) DEFAULT NULL,
  `IsBasedOn` int(10) DEFAULT NULL,
  `createdBy` int(10) DEFAULT NULL,
  `version` varchar(50) DEFAULT NULL,
  `lastModification` timestamp NOT NULL DEFAULT current_timestamp(),
  `creationDate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_questionnaire`
--

INSERT INTO `tb_questionnaire` (`questionnaireID`, `description`, `questionnaireStatusID`, `IsBasedOn`, `createdBy`, `version`, `lastModification`, `creationDate`) VALUES
(1, 'WHO COVID-19 Rapid Version CRF', 1, NULL, NULL, '1.0', '2021-11-17 21:06:57', '2021-11-17 21:08:01'),
(2, 'Pesquisa de teste 2', 3, NULL, NULL, '2.0', '2021-11-17 23:16:07', '2021-12-01 09:28:13'),
(14, 'teste', 2, NULL, NULL, '0.0', '2021-11-30 20:38:20', '2021-11-30 20:38:20'),
(5, 'nova pesquisa', 1, NULL, NULL, '0.0', '2021-11-24 00:25:22', '2021-11-24 00:25:22'),
(6, 'Questionário 2', 2, NULL, NULL, '0.0', '2021-11-24 00:31:02', '2021-11-24 00:31:02'),
(16, 'teste', 2, NULL, NULL, '0.0', '2021-12-01 02:48:38', '2021-12-01 02:48:38'),
(8, 'Outra pesquisa', 2, NULL, NULL, '0.0', '2021-11-24 00:47:34', '2021-11-24 00:47:34'),
(13, 'pesquisa criada agora', 2, NULL, NULL, '0.0', '2021-11-28 21:51:48', '2021-11-28 21:51:48');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tb_questionnaire`
--
ALTER TABLE `tb_questionnaire`
  ADD PRIMARY KEY (`questionnaireID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tb_questionnaire`
--
ALTER TABLE `tb_questionnaire`
  MODIFY `questionnaireID` int(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
