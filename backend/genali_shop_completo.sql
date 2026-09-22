
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `genali_shop` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `genali_shop`;
DROP TABLE IF EXISTS `Products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `categoria` varchar(255) NOT NULL,
  `precio` float NOT NULL DEFAULT '0',
  `stock` int NOT NULL DEFAULT '0',
  `tallas` varchar(255) DEFAULT NULL,
  `imagen` varchar(255) DEFAULT NULL,
  `esFavorito` tinyint(1) NOT NULL DEFAULT '0',
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  `descripcion` text,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `Products` WRITE;
/*!40000 ALTER TABLE `Products` DISABLE KEYS */;
INSERT INTO `Products` VALUES (9,'Camiseta Oficial Selección','Fútbol',750,120,'S, M, L, XL','producto_1790020636374.jpeg',1,'2026-09-21 08:04:05','2026-09-21 19:57:16','Camiseta oficial temporada 2026, tela transpirable.',1),(11,'Vestido Casual Rosado','Vestido Dama',650,60,'XS, S, M, L','producto_1790020612874.jpeg',0,'2026-09-21 08:04:05','2026-09-21 19:56:52','Vestido casual elegante, ideal para toda ocasión.',1),(12,'Gorra New York','Accesorios',350,45,'Única','producto_1790020583866.jpeg',0,'2026-09-21 08:04:05','2026-09-21 19:56:23','Gorra ajustable estilo urbano.',1),(13,'Perfume Floral Elegante','Perfumería',900,30,'50ml, 100ml','producto_1790020662506.jpeg',1,'2026-09-21 08:04:05','2026-09-21 19:57:42','Fragancia floral duradera y delicada.',1),(14,'Zapatos de Vestir Caballero','Caballero',1400,40,'39, 40, 41, 42, 43','producto_1790020712041.webp',0,'2026-09-21 08:04:05','2026-09-21 19:58:32','Zapatos formales de cuero para caballero.',1),(15,'Blusa Manga Larga','Vestido Dama',480,55,'S, M, L','producto_1790020731205.jpg',0,'2026-09-21 08:04:05','2026-09-21 19:58:51','Blusa ligera de manga larga, varios colores.',1),(16,'Conjunto Niña Primavera','Niña',550,35,'2, 4, 6, 8','producto_1790020751173.avif',0,'2026-09-21 08:04:05','2026-09-21 19:59:11','Conjunto de dos piezas para niña.',1),(17,'Camiseta Deportiva Dry-Fit','Camiseta Deportiva',420,70,'S, M, L, XL','producto_1790020773055.jpeg',1,'2026-09-21 08:04:05','2026-09-21 19:59:33','Camiseta deportiva de secado rápido.',1),(18,'Sandalias Casuales','Calzado',600,50,'36, 37, 38, 39, 40','producto_1790020799422.jpeg',0,'2026-09-21 08:04:05','2026-09-21 19:59:59','Sandalias cómodas para el verano.',1),(19,'Camisa del barca','Camisa Futbol',2000,20,'L','producto_1790014339405.jpeg',1,'2026-09-21 18:12:19','2026-09-21 18:12:19','',1);
/*!40000 ALTER TABLE `Products` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `Sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Sales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `producto` varchar(255) NOT NULL,
  `talla` varchar(255) DEFAULT NULL,
  `cantidad` int NOT NULL DEFAULT '1',
  `empleado` varchar(255) DEFAULT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `Sales` WRITE;
/*!40000 ALTER TABLE `Sales` DISABLE KEYS */;
INSERT INTO `Sales` VALUES (1,'Gorra Genali','Única',2,NULL,'2026-09-21 05:51:53','2026-09-21 05:51:53'),(2,'Camiseta Oficial Selección','M',1,'genesismartniez@gmail.com','2026-09-21 07:20:21','2026-09-21 07:20:21');
/*!40000 ALTER TABLE `Sales` ENABLE KEYS */;
UNLOCK TABLES;
DROP TABLE IF EXISTS `Users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(255) NOT NULL,
  `apellido` varchar(255) DEFAULT NULL,
  `correo` varchar(255) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `createdAt` datetime NOT NULL,
  `updatedAt` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `correo` (`correo`),
  UNIQUE KEY `correo_2` (`correo`),
  UNIQUE KEY `correo_3` (`correo`),
  UNIQUE KEY `correo_4` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;
INSERT INTO `Users` VALUES (1,'Genesis','Martinez','genesismartniez@gmail.com','$2b$10$.So6UQxDSETKVpSYcpxyM.t8fCsB9M.XX8LAQc7w5urDAeuLc74Um','2026-09-11 23:37:38','2026-09-11 23:37:38'),(9,'Emily','Martínez','emilyprueba@gmail.com','$2b$10$DrFT.1E1ygNnDrJhyIlzae3yhpoZBkpdM6U2f/MizVSCLEiqdOP1q','2026-09-14 05:06:50','2026-09-14 05:06:50'),(10,'Joel','Reyes','jr4419543@gmail.com','$2b$10$g8ljev.tlM9bl34zd1ALru8fJC6tf3mj9FyXuhEZFsYSa2yESXqzq','2026-09-21 05:54:41','2026-09-21 05:54:41');
/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

