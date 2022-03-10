-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 10, 2022 at 08:19 PM
-- Server version: 10.4.22-MariaDB
-- PHP Version: 7.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vodan_bd_br_2021`
--

-- --------------------------------------------------------

--
-- Table structure for table `tb_questions`
--

CREATE TABLE `tb_questions` (
  `questionID` int(10) NOT NULL,
  `description` varchar(255) NOT NULL COMMENT '(pt-br) Descrição.\r\n(en) description.',
  `questionTypeID` int(10) NOT NULL COMMENT '(pt-br) Chave estrangeira para tabela tb_QuestionsTypes.\r\n(en) Foreign key for the tp_QuestionsTypes table.',
  `listTypeID` int(10) DEFAULT NULL,
  `questionGroupID` int(10) DEFAULT NULL,
  `subordinateTo` int(10) DEFAULT NULL,
  `isAbout` int(10) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tb_questions`
--

INSERT INTO `tb_questions` (`questionID`, `description`, `questionTypeID`, `listTypeID`, `questionGroupID`, `subordinateTo`, `isAbout`) VALUES
(1, 'Age', 5, NULL, 6, NULL, NULL),
(2, 'Altered consciousness/confusion', 8, 15, NULL, NULL, NULL),
(3, 'Angiotensin converting enzyme inhibitors (ACE inhibitors)', 8, 15, NULL, NULL, NULL),
(4, 'Angiotensin II receptor blockers (ARBs)', 8, 15, NULL, NULL, NULL),
(5, 'AVPU scale', 4, 2, NULL, NULL, NULL),
(6, 'BP (diastolic)', 5, NULL, NULL, NULL, NULL),
(7, 'BP (systolic)', 5, NULL, NULL, NULL, NULL),
(8, 'Chest pain', 8, 15, NULL, NULL, NULL),
(9, 'Conjunctivitis', 8, 15, NULL, NULL, NULL),
(10, 'Cough', 8, 15, NULL, NULL, NULL),
(11, 'Cough with sputum', 8, 15, NULL, NULL, NULL),
(12, 'Diarrhoea', 8, 15, NULL, NULL, NULL),
(13, 'Glasgow Coma Score (GCS /15)', 5, NULL, NULL, NULL, NULL),
(14, 'Heart rate', 5, NULL, NULL, NULL, NULL),
(15, 'Muscle aches (myalgia)', 8, 15, NULL, NULL, NULL),
(16, 'Non-steroidal anti-inflammatory (NSAID)', 8, 15, NULL, NULL, NULL),
(17, 'Other signs or symptoms', 8, 15, NULL, NULL, NULL),
(18, 'Oxygen saturation', 5, NULL, NULL, NULL, NULL),
(19, 'Respiratory rate', 5, NULL, NULL, NULL, NULL),
(20, 'Seizures', 8, 15, NULL, NULL, NULL),
(21, 'Severe dehydration', 8, 15, NULL, NULL, NULL),
(22, 'Shortness of breath', 8, 15, NULL, NULL, NULL),
(23, 'Sore throat', 8, 15, NULL, NULL, NULL),
(24, 'Sternal capillary refill time >2seconds', 8, 15, NULL, NULL, NULL),
(25, 'Temperature', 5, NULL, NULL, NULL, NULL),
(26, 'Vomiting/Nausea', 8, 15, NULL, NULL, NULL),
(27, 'Which sign or symptom', 7, NULL, NULL, NULL, NULL),
(28, 'Other signs or symptoms', 8, 15, 4, NULL, 17),
(29, 'Other signs or symptoms', 8, 15, 12, NULL, 17),
(30, 'Other complication', 8, 15, 3, NULL, NULL),
(31, 'Chest X-Ray /CT performed', 8, 15, 7, NULL, NULL),
(32, 'Was pathogen testing done during this illness episode', 8, 15, 7, NULL, NULL),
(33, 'Antifungal agent', 8, 15, 9, NULL, NULL),
(34, 'Antimalarial agent', 8, 15, 9, NULL, NULL),
(35, 'Antiviral', 8, 15, 9, NULL, NULL),
(36, 'Corticosteroid', 8, 15, 9, NULL, NULL),
(37, 'Experimental agent', 8, 15, 9, NULL, NULL),
(38, 'Bleeding (Haemorrhage)', 8, 15, 12, NULL, NULL),
(39, 'Oxygen therapy', 8, 15, 13, NULL, NULL),
(40, 'Oxygen saturation', 5, NULL, 5, NULL, 18),
(41, 'Oxygen saturation', 5, NULL, 14, NULL, 18),
(42, 'Other respiratory pathogen', 6, 11, 7, 32, NULL),
(43, 'Viral haemorrhagic fever', 6, 11, 7, 32, NULL),
(44, 'Coronavirus', 6, 11, 7, 32, NULL),
(45, 'Which coronavirus', 4, 3, 7, 44, NULL),
(46, 'Influenza virus', 6, 11, 7, 32, NULL),
(47, 'A history of self-reported feverishness or measured fever of ≥ 38 degrees Celsius', 1, NULL, 1, NULL, NULL),
(48, 'Clinical suspicion of ARI despite not meeting criteria above', 1, NULL, 1, NULL, NULL),
(49, 'Proven or suspected infection with pathogen of Public Health Interest', 1, NULL, 1, NULL, NULL),
(50, 'Ashtma', 8, 15, 2, NULL, NULL),
(51, 'Asplenia', 8, 15, 2, NULL, NULL),
(52, 'Chronic cardiac disease (not hypertension)', 8, 15, 2, NULL, NULL),
(53, 'Chronic kidney disease', 8, 15, 2, NULL, NULL),
(54, 'Chronic liver disease', 8, 15, 2, NULL, NULL),
(55, 'Chronic neurological disorder', 8, 15, 2, NULL, NULL),
(56, 'Chronic pulmonary disease', 8, 15, 2, NULL, NULL),
(57, 'Current smoking', 8, 15, 2, NULL, NULL),
(58, 'Diabetes', 8, 15, 2, NULL, NULL),
(59, 'HIV', 4, 6, 2, NULL, NULL),
(60, 'Hypertension', 8, 15, 2, NULL, NULL),
(61, 'Malignant neoplasm', 8, 15, 2, NULL, NULL),
(62, 'Other co-morbidities', 8, 15, 2, NULL, NULL),
(63, 'Dyspnoea (shortness of breath) OR Tachypnoea', 1, NULL, 1, NULL, NULL),
(64, 'Cough', 1, NULL, 1, NULL, NULL),
(65, 'Tuberculosis', 8, 15, 2, NULL, NULL),
(66, 'Acute renal injury', 8, 15, 3, NULL, NULL),
(67, 'Acute Respiratory Distress Syndrome', 8, 15, 3, NULL, NULL),
(68, 'Anaemia', 8, 15, 3, NULL, NULL),
(69, 'Bacteraemia', 8, 15, 3, NULL, NULL),
(70, 'Bleeding', 8, 15, 3, NULL, NULL),
(71, 'Bronchiolitis', 8, 15, 3, NULL, NULL),
(72, 'Cardiac arrest', 8, 15, 3, NULL, NULL),
(73, 'Cardiac arrhythmia', 8, 15, 3, NULL, NULL),
(74, 'Cardiomyopathy', 8, 15, 3, NULL, NULL),
(75, 'Endocarditis', 8, 15, 3, NULL, NULL),
(76, 'Liver dysfunction', 8, 15, 3, NULL, NULL),
(77, 'Meningitis/Encephalitis', 8, 15, 3, NULL, NULL),
(78, 'Myocarditis/Pericarditis', 8, 15, 3, NULL, NULL),
(79, 'Pancreatitis', 8, 15, 3, NULL, NULL),
(80, 'Pneumonia', 8, 15, 3, NULL, NULL),
(81, 'Shock', 8, 15, 3, NULL, NULL),
(82, 'Which corticosteroid route', 4, 4, 9, 36, NULL),
(83, 'Confusion', 8, 15, 4, NULL, NULL),
(84, 'Falciparum malaria', 6, 11, 7, 32, NULL),
(85, 'HIV', 6, 11, 7, 32, NULL),
(86, 'Infiltrates present', 8, 15, 7, 31, NULL),
(87, 'Maximum daily corticosteroid dose', 7, NULL, 9, 36, NULL),
(88, 'Non-Falciparum malaria', 6, 11, 7, 32, NULL),
(89, 'O2 flow', 4, 8, 13, 39, NULL),
(90, 'Oxygen interface', 4, 7, 13, 39, NULL),
(91, 'Site name', 7, NULL, 12, 38, NULL),
(92, 'Source of oxygen', 4, 14, 13, 39, NULL),
(93, 'Admission date at this facility', 2, NULL, 5, NULL, NULL),
(94, 'Height', 5, NULL, 5, NULL, NULL),
(95, 'Malnutrition', 8, 15, 5, NULL, NULL),
(96, 'Mid-upper arm circumference', 5, NULL, 5, NULL, NULL),
(97, 'Symptom onset (date of first/earliest symptom)', 2, NULL, 5, NULL, NULL),
(98, 'Weight', 5, NULL, 5, NULL, NULL),
(99, 'Which antifungal agent', 7, NULL, 9, 33, NULL),
(100, 'Which antimalarial agent', 7, NULL, 9, 34, NULL),
(101, 'Which antiviral', 4, 1, 9, 35, NULL),
(102, 'Which complication', 7, NULL, 3, 30, NULL),
(103, 'Which experimental agent', 7, NULL, 9, 37, NULL),
(104, 'Which other antiviral', 7, NULL, 9, 35, NULL),
(105, 'Which other pathogen of public health interest detected', 7, NULL, 7, 32, NULL),
(106, 'Other corona virus', 7, NULL, 7, 44, NULL),
(107, 'Date of Birth', 2, NULL, 6, NULL, NULL),
(108, 'Healthcare worker', 8, 15, 6, NULL, NULL),
(109, 'Laboratory Worker', 8, 15, 6, NULL, NULL),
(110, 'Grávida?', 9, 16, 6, NULL, NULL),
(111, 'Sex at Birth', 4, 13, 6, NULL, NULL),
(112, 'Oxygen saturation expl', 4, 10, 14, 41, NULL),
(113, 'Gestational weeks assessment', 5, NULL, 6, 110, NULL),
(114, 'ALT/SGPT measurement', 3, NULL, 8, NULL, NULL),
(115, 'APTT/APTR measurement', 3, NULL, 8, NULL, NULL),
(116, 'AST/SGOT measurement', 3, NULL, 8, NULL, NULL),
(117, 'Antibiotic', 8, 15, 9, NULL, NULL),
(118, 'ESR measurement', 3, NULL, 8, NULL, NULL),
(119, 'Intravenous fluids', 8, 15, 9, NULL, NULL),
(120, 'Oral/orogastric fluids', 8, 15, 9, NULL, NULL),
(121, 'Influenza virus type', 7, NULL, 7, 46, NULL),
(122, 'Ability to self-care at discharge versus before illness', 4, 12, 10, NULL, NULL),
(123, 'Outcome', 4, 9, 10, NULL, NULL),
(124, 'Outcome date', 2, NULL, 10, NULL, NULL),
(125, 'Which respiratory pathogen', 7, NULL, 7, 42, NULL),
(126, 'Which virus', 7, NULL, 7, 43, NULL),
(127, 'Abdominal pain', 8, 15, 12, NULL, NULL),
(128, 'Cough with haemoptysis', 8, 15, 12, NULL, NULL),
(129, 'Fatigue/Malaise', 8, 15, 12, NULL, NULL),
(130, 'Headache', 8, 15, 12, NULL, NULL),
(131, 'duration in weeks', 5, NULL, NULL, NULL, NULL),
(132, 'History of fever', 8, 15, 12, NULL, NULL),
(133, 'Inability to walk', 8, 15, 12, NULL, NULL),
(134, 'Joint pain (arthralgia)', 8, 15, 12, NULL, NULL),
(135, 'Lower chest wall indrawing', 8, 15, 12, NULL, NULL),
(136, 'Lymphadenopathy', 8, 15, 12, NULL, NULL),
(137, 'Runny nose (rhinorrhoea)', 8, 15, 12, NULL, NULL),
(138, 'Skin rash', 8, 15, 12, NULL, NULL),
(139, 'Skin ulcers', 8, 15, 12, NULL, NULL),
(140, 'Wheezing', 8, 15, 12, NULL, NULL),
(141, 'Oxygen saturation expl', 4, 10, 5, 40, NULL),
(142, 'Which sign or symptom', 7, NULL, 4, 28, 27),
(143, 'Which sign or symptom', 7, NULL, 12, 29, 27),
(144, 'Age (years)', 5, NULL, 6, NULL, 1),
(145, 'Creatine kinase measurement', 3, NULL, 8, NULL, NULL),
(146, 'Creatinine measurement', 3, NULL, 8, NULL, NULL),
(147, 'CRP measurement', 3, NULL, 8, NULL, NULL),
(148, 'D-dimer measurement', 3, NULL, 8, NULL, NULL),
(149, 'Extracorporeal (ECMO) support', 8, 15, 13, NULL, NULL),
(150, 'ICU or High Dependency Unit admission', 8, 15, 13, NULL, NULL),
(151, 'Inotropes/vasopressors', 8, 15, 13, NULL, NULL),
(152, 'Invasive ventilation', 8, 15, 13, NULL, NULL),
(153, 'Non-invasive ventilation', 9, 16, 13, NULL, NULL),
(154, 'Prone position', 8, 15, 13, NULL, NULL),
(155, 'Renal replacement therapy (RRT) or dialysis', 8, 15, 13, NULL, NULL),
(156, 'Ferritin measurement', 3, NULL, 8, NULL, NULL),
(157, 'Haematocrit measurement', 3, NULL, 8, NULL, NULL),
(158, 'Haemoglobin measurement', 3, NULL, 8, NULL, NULL),
(159, 'IL-6 measurement', 3, NULL, 8, NULL, NULL),
(160, 'INR measurement', 3, NULL, 8, NULL, NULL),
(161, 'Lactate measurement', 3, NULL, 8, NULL, NULL),
(162, 'LDH measurement', 3, NULL, 8, NULL, NULL),
(163, 'Platelets measurement', 3, NULL, 8, NULL, NULL),
(164, 'Potassium measurement', 3, NULL, 8, NULL, NULL),
(165, 'Procalcitonin measurement', 3, NULL, 8, NULL, NULL),
(166, 'Country', 4, 5, NULL, NULL, NULL),
(167, 'Date of enrolment', 2, NULL, NULL, NULL, NULL),
(168, 'Date of follow up', 2, NULL, NULL, NULL, NULL),
(169, 'PT measurement', 3, NULL, 8, NULL, NULL),
(170, 'Sodium measurement', 3, NULL, 8, NULL, NULL),
(171, 'Total bilirubin measurement', 3, NULL, 8, NULL, NULL),
(172, 'Troponin measurement', 3, NULL, 8, NULL, NULL),
(173, 'duration in days', 5, NULL, NULL, NULL, NULL),
(174, 'Urea (BUN) measurement', 3, NULL, 8, NULL, NULL),
(175, 'specific response', 7, NULL, NULL, NULL, NULL),
(176, 'Seizures', 8, 15, 3, NULL, 20),
(177, 'Chest pain', 8, 15, 4, NULL, 8),
(178, 'Seizures', 8, 15, 4, NULL, 20),
(179, 'Altered consciousness/confusion', 8, 15, 4, NULL, 2),
(180, 'Which NSAID', 7, NULL, 9, 16, NULL),
(181, 'Oxygen saturation expl', 4, 10, NULL, NULL, NULL),
(182, 'Vomiting/Nausea', 8, 15, 4, NULL, 26),
(183, 'Cough', 8, 15, 4, NULL, 10),
(184, 'Sore throat', 8, 15, 4, NULL, 23),
(185, 'Shortness of breath', 8, 15, 4, NULL, 22),
(186, 'Diarrhoea', 8, 15, 4, NULL, 12),
(187, 'Muscle aches (myalgia)', 8, 15, 4, NULL, 15),
(188, 'Conjunctivitis', 8, 15, 4, NULL, 9),
(189, 'Severe dehydration', 8, 15, 5, NULL, 21),
(190, 'AVPU scale', 4, 2, 5, NULL, 5),
(191, 'Heart rate', 5, NULL, 5, NULL, 14),
(192, 'BP (diastolic)', 5, NULL, 5, NULL, 6),
(193, 'Glasgow Coma Score (GCS /15)', 5, NULL, 5, NULL, 13),
(194, 'Respiratory rate', 5, NULL, 5, NULL, 19),
(195, 'BP (systolic)', 5, NULL, 5, NULL, 7),
(196, 'Sternal capillary refill time >2seconds', 8, 15, 5, NULL, 24),
(197, 'Cough with sputum production', 8, 15, 4, NULL, 11),
(198, 'Temperature', 5, NULL, 5, NULL, 25),
(199, 'Non-steroidal anti-inflammatory (NSAID)', 8, 15, 9, NULL, 16),
(200, 'Angiotensin converting enzyme inhibitors (ACE inhibitors)', 8, 15, 9, NULL, 3),
(201, 'Angiotensin II receptor blockers (ARBs)', 8, 15, 9, NULL, 4),
(202, 'Angiotensin converting enzyme inhibitors (ACE inhibitors)', 8, 15, 11, NULL, 3),
(203, 'Angiotensin II receptor blockers (ARBs)', 8, 15, 11, NULL, 4),
(204, 'Non-steroidal anti-inflammatory (NSAID)', 8, 15, 11, NULL, 16),
(205, 'Shortness of breath', 8, 15, 12, NULL, 22),
(206, 'Vomiting/Nausea', 8, 15, 12, NULL, 26),
(207, 'Altered consciousness/confusion', 8, 15, 12, NULL, 2),
(208, 'Diarrhoea', 8, 15, 12, NULL, 12),
(209, 'Muscle aches (myalgia)', 8, 15, 12, NULL, 15),
(210, 'Cough', 8, 15, 12, NULL, 10),
(211, 'Seizures', 8, 15, 12, NULL, 20),
(212, 'Age (months)', 5, NULL, 6, NULL, 1),
(213, 'Conjunctivitis', 8, 15, 12, NULL, 9),
(214, 'Chest pain', 8, 15, 12, NULL, 8),
(215, 'Sore throat', 8, 15, 12, NULL, 23),
(216, 'AVPU scale', 4, 2, 14, NULL, 5),
(217, 'Temperature', 5, NULL, 14, NULL, 25),
(218, 'Sternal capillary refill time >2seconds', 8, 15, 14, NULL, 24),
(219, 'BP (diastolic)', 5, NULL, 14, NULL, 6),
(220, 'Severe dehydration', 8, 15, 14, NULL, 21),
(221, 'Heart rate', 5, NULL, 14, NULL, 14),
(222, 'BP (systolic)', 5, NULL, 14, NULL, 7),
(223, 'Glasgow Coma Score (GCS /15)', 5, NULL, 14, NULL, 13),
(224, 'Respiratory rate', 5, NULL, 14, NULL, 19),
(225, 'Cough with sputum production', 8, 15, 12, NULL, 11),
(226, 'WBC count measurement', 3, NULL, 8, NULL, NULL),
(227, 'Which other co-morbidities', 7, NULL, 2, 62, NULL),
(228, 'Date of ICU/HDU admission', 2, NULL, 13, 150, NULL),
(229, 'ICU/HDU discharge date', 2, NULL, 13, 150, NULL),
(230, 'Date of ICU/HDU admission', 2, NULL, 13, 150, NULL),
(231, 'ICU/HDU discharge date', 2, NULL, 13, 150, NULL),
(232, 'Which antibiotic', 7, NULL, 9, 117, NULL),
(233, 'Total duration ICU/HCU', 5, NULL, 13, 150, 173),
(234, 'Total duration Oxygen Therapy', 5, NULL, 13, 39, 173),
(235, 'Total duration Non-invasive ventilation', 5, NULL, 13, 153, 173),
(236, 'Total duration Invasive ventilation', 5, NULL, 13, 152, 173),
(237, 'Total duration ECMO', 5, NULL, 13, 149, 173),
(238, 'Total duration Prone position', 5, NULL, 13, 154, 173),
(239, 'Total duration RRT or dyalysis', 5, NULL, 13, 155, 173),
(240, 'Total duration Inotropes/vasopressors', 5, NULL, 13, 151, 173),
(241, 'Systemic anticoagulation', 8, 15, 9, NULL, NULL),
(242, 'Facility Name', 7, NULL, NULL, NULL, NULL),
(243, 'Loss of smell', 8, 15, NULL, NULL, NULL),
(244, 'Loss of taste', 8, 15, NULL, NULL, NULL),
(245, 'FiO2 value', 10, NULL, 13, 152, NULL),
(246, 'PaO2 value', 10, NULL, 13, 152, NULL),
(247, 'PaCO2 value', 10, NULL, 13, 152, NULL),
(248, 'Plateau pressure value', 10, NULL, 13, 152, NULL),
(249, 'PEEP value', 10, NULL, 13, 152, NULL),
(250, 'Loss of smell daily', 8, 15, 4, NULL, 243),
(251, 'Loss of taste daily', 8, 15, 4, NULL, 244),
(252, 'Loss of smell signs', 8, 15, 12, NULL, 243),
(253, 'Loss of taste signs', 8, 15, 12, NULL, 244),
(254, 'Which antiviral', 4, 1, 11, NULL, 101),
(255, 'Which other antiviral', 7, NULL, 11, 254, 104);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
