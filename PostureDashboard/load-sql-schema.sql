DROP DATABASE IF EXISTS `secure_posture`;
CREATE DATABASE `secure_posture` DEFAULT CHARACTER SET utf8mb4;
USE `secure_posture`;

DROP TABLE IF EXISTS `tracking`;
CREATE TABLE `tracking` (
  `Time` DATE NOT NULL,
  `Customer` varchar(255) NOT NULL,
  `Environment` varchar(255) NOT NULL,
  `Security_Domain` varchar(255) NOT NULL,
  `Security_Control_id` varchar(10) NOT NULL,
  `Security_Control_Name` varchar(255) NOT NULL,
  `Security_Control_Rate` INT(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `non_tracking`;
CREATE TABLE `non_tracking` (
  `Time` DATE NOT NULL,
  `Customer` varchar(255) NOT NULL,
  `Environment` varchar(255) NOT NULL,
  `Security_Domain` varchar(255) NOT NULL,
  `Security_Control_id` varchar(10) NOT NULL,
  `Security_Control_Name` varchar(255) NOT NULL,
  `Security_Control_Rate` varchar(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP USER IF EXISTS 'sec-user'@'localhost';
CREATE USER 'sec-user'@'localhost' IDENTIFIED BY 'your_secret_password';
GRANT ALL PRIVILEGES ON secure_posture.* TO 'sec-user'@'localhost';
FLUSH PRIVILEGES;
