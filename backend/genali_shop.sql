-- ============================================================
--  Base de datos: genali_shop  (Variedades Genali)
--  Para MySQL 8.0  ·  ejecutar completo en MySQL Workbench
-- ============================================================

CREATE DATABASE IF NOT EXISTS `genali_shop`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE `genali_shop`;

-- ------------------------------------------------------------
--  Tabla: users
-- ------------------------------------------------------------
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id`         INT NOT NULL AUTO_INCREMENT,
  `nombre`     VARCHAR(255) NOT NULL,
  `apellido`   VARCHAR(255) NOT NULL,
  `correo`     VARCHAR(255) NOT NULL,
  `contrasena` VARCHAR(255) NOT NULL,
  `createdAt`  DATETIME NOT NULL,
  `updatedAt`  DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ------------------------------------------------------------
--  Datos (contraseñas ya vienen hasheadas con bcrypt)
-- ------------------------------------------------------------
INSERT INTO `users` (`id`,`nombre`,`apellido`,`correo`,`contrasena`,`createdAt`,`updatedAt`) VALUES
 (1,'Genesis','Martinez','genesismartniez@gmail.com','$2b$10$.So6UQxDSETKVpSYcpxyM.t8fCsB9M.XX8LAQc7w5urDAeuLc74Um','2026-09-11 23:37:38','2026-09-11 23:37:38'),
 (2,'Genesis','Martinez','genesismrtniez@gmail.com','$2b$10$TE0U6BhnHCYYfP2lPA94zOWOuvlAWrf1o0Eau.Q7Vdcy/EUZrxNZa','2026-09-11 23:58:29','2026-09-11 23:58:29'),
 (3,'hena','heni','prueba1@test.com','$2b$10$Gj7PrO/D5JIm.UfSL8gz8O5VCkGNRUDoOHSMdF0U78EK35Eo9rRQC','2026-09-12 04:06:20','2026-09-12 04:06:20'),
 (4,'prueha','pruea','prueba@gmail.com','$2b$10$Vbg244EnLVAKIftQ/jKQ9.FoWj.1MNCeicV6OhXWDeC.RneyxlONe','2026-09-12 04:10:41','2026-09-12 04:10:41'),
 (5,'Genesis','Martinez','prueba23@gmai.com','$2b$10$ZaXwABCmEd5P9WSyx.GXIedt2tHmNc.1.l843L1hNv0YkTWIziwvK','2026-09-12 05:41:27','2026-09-12 05:41:27'),
 (6,'gene','gene','prueba23@gmail.com','$2b$10$k9j8u7qYSqx.yA.OlH/RF.abZJCm3Xwzcn0.R6hwiUjD6i/fshi7S','2026-09-12 05:43:20','2026-09-12 05:43:20'),
 (7,'gene','gene','prubeba300@gmai.com','$2b$10$KDZJJyVRIhL9.GNigWavFunSOoRWiOqs1EJ3E/uKFSOWYou2vGtIq','2026-09-12 05:45:15','2026-09-12 05:45:15'),
 (8,'Emily','Martínez','genesis.prueba@gmail.com','$2b$10$tQGWHH58cIPdFWJyocFLyu5sb9QZqTIsvcQVhKwxJ7Fr8L5khoU86','2026-09-14 05:06:09','2026-09-14 05:06:09'),
 (9,'Emily','Martínez','emilyprueba@gmail.com','$2b$10$DrFT.1E1ygNnDrJhyIlzae3yhpoZBkpdM6U2f/MizVSCLEiqdOP1q','2026-09-14 05:06:50','2026-09-14 05:06:50');

-- Verificación rápida
SELECT id, nombre, apellido, correo FROM `users`;
