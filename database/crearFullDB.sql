-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema dbfacturacion
-- -----------------------------------------------------
-- drop database dbfacturacion;
-- -----------------------------------------------------
-- Schema dbfacturacion
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `dbfacturacion` DEFAULT CHARACTER SET utf8mb3 ;
USE `dbfacturacion` ;

-- -----------------------------------------------------
-- Table `dbfacturacion`.`maesuc`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dbfacturacion`.`maesuc` (
  `codS` INT NOT NULL,
  `direccion` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`codS`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;

-- -----------------------------------------------------
-- Table `dbfacturacion`.`trfactura`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dbfacturacion`.`trfactura` (
  `codF` INT NOT NULL AUTO_INCREMENT,
  `codS` INT NOT NULL,
  `fecha` DATE NOT NULL,
  `dni` CHAR(8) NOT NULL,
  `nombre` VARCHAR(250) NOT NULL,
  `igv` FLOAT NOT NULL,
  `total` FLOAT NOT NULL,
  PRIMARY KEY (`codF`),
  INDEX `fkCliente_idx` (`dni` ASC) VISIBLE,
  INDEX `fkSucursal_idx` (`codS` ASC) VISIBLE,
  CONSTRAINT `fkSucursal`
    FOREIGN KEY (`codS`)
    REFERENCES `dbfacturacion`.`maesuc` (`codS`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `dbfacturacion`.`maemed`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dbfacturacion`.`maemed` (
  `codM` INT NOT NULL,
  `nombre` VARCHAR(250) NOT NULL,
  `controlado` TINYINT(1) NOT NULL,
  `precio` FLOAT NOT NULL,
  PRIMARY KEY (`codM`),
  UNIQUE INDEX `codM_UNIQUE` (`codM` ASC) VISIBLE,
  UNIQUE INDEX `nombre_UNIQUE` (`nombre` ASC) VISIBLE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `dbfacturacion`.`detalle`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dbfacturacion`.`detalle` (
  `codF` INT NOT NULL,
  `codM` INT NOT NULL,
  `codS` INT NOT NULL,
  `cantidad` INT NULL DEFAULT NULL,
  `coste` FLOAT NULL DEFAULT NULL,
  INDEX `fkFact_idx` (`codF` ASC) VISIBLE,
  INDEX `fkMed_idx` (`codM` ASC) VISIBLE,
  INDEX `fkSucursal_idx` (`codS` ASC) VISIBLE,
  CONSTRAINT `fkFactura`
    FOREIGN KEY (`codF`)
    REFERENCES `dbfacturacion`.`trfactura` (`codF`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fkMedicamento`
    FOREIGN KEY (`codM`)
    REFERENCES `dbfacturacion`.`maemed` (`codM`)
    ON DELETE RESTRICT,
  CONSTRAINT `fkSucursalDetalle`
    FOREIGN KEY (`codS`)
    REFERENCES `dbfacturacion`.`trfactura` (`codS`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `dbfacturacion`.`trstock`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `dbfacturacion`.`trstock` (
  `codS` INT NOT NULL,
  `codM` INT NOT NULL,
  `stock` INT NOT NULL,
  PRIMARY KEY (`codS`, `codM`),
  INDEX `fkMed` (`codM` ASC) VISIBLE,
  CONSTRAINT `fkMed`
    FOREIGN KEY (`codM`)
    REFERENCES `dbfacturacion`.`maemed` (`codM`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT,
  CONSTRAINT `fkSuc`
    FOREIGN KEY (`codS`)
    REFERENCES `dbfacturacion`.`maesuc` (`codS`)
    ON DELETE RESTRICT
    ON UPDATE RESTRICT)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

USE dbfacturacion;

/* Ver Listado de productos en sucursal (RF-VS01) */
/*Este procedimiento muestra el inventario de una sucursal en particular, 
  toma como entrada el código de la sucursal donde va a buscar medicamentos*/
DELIMITER $$ 
CREATE PROCEDURE ver_inventario(in suc INT) 
BEGIN 
  SELECT m.codM, m.nombre, m.controlado, m.precio, s.stock  
    FROM maemed m
      INNER JOIN trstock s
        ON m.codM = s.codM
        WHERE s.codS = suc;
END$$ 
DELIMITER ;


/* Crear factura (RF-?) */
/*Este procedimiento crea una nueva factura, el código se coloca automáticamente, 
  toma como entrada la sucursal donde se está ejecutando la venta,
  la fecha en la que se crea la factura y el dni y nombre del cliente. 
  El igv y total se colocan automáticamente como 0*/
DELIMITER $$ 
CREATE PROCEDURE crear_factura(in dni CHAR(8),in cliente VARCHAR(250),in sucursal INT,in fecha DATE)
BEGIN 
  INSERT INTO trFactura(codS, fecha, dni, nombre, igv, total) 
    VALUES (sucursal, fecha, dni, cliente, 0, 0);
END$$ 
DELIMITER ;

-- SELECT * FROM trFactura 

/* Ver listado/historial de Boletas (RF-HB11) */
/*Este procedimiento muestra las boletas y sus datos*/
DELIMITER $$ 
CREATE PROCEDURE ver_historial(in suc INT) 
BEGIN 
  SELECT f.codF,f.fecha,f.dni, f.nombre, f.total, f.codS 
    FROM trfactura f
      INNER JOIN maesuc s
        ON f.codS = suc
        WHERE s.codS = suc
      GROUP BY f.codF
      ORDER BY f.codF;
END$$ 
DELIMITER ;

/* Busqueda de medicamento en sucursal (RF-BCN03) */
/*Este procedimeinto busca coincidencias en una sucursal específica,
  toma como entrada la palabra a buscar y la sucursal donde se busca*/
DELIMITER $$ 
CREATE PROCEDURE buscar_med(in nom VARCHAR(250), suc INT) 
BEGIN 
  SELECT m.*, s.stock 
    FROM maemed m
      INNER JOIN trstock s
        ON m.codM = s.codM
      WHERE 
        nombre LIKE CONCAT("%",nom,"%")
      AND
        s.codS = suc;
END$$ 
DELIMITER ;

/* Busqueda boleta por fecha (RF-BBF12) */
/*Este procedimiento muestra las facturas hechas en una fecha
  específica, la cual toma como entrada*/
DELIMITER $$ 
CREATE PROCEDURE factFecha(in f DATE) 
BEGIN 
  SELECT f.codF,f.fecha,f.dni, f.nombre, f.total, f.codS
    FROM trfactura f
      INNER JOIN maesuc s
        ON f.codS = s.codS
      WHERE f.fecha = f
      ORDER BY f.codF;
END$$ 
DELIMITER ;

/* Busqueda boleta por cliente (RF-BBC13) */
/*Este procedimiento muestra las facturas según un cliente
  específico, el cual toma como entrada*/
DELIMITER $$ 
CREATE PROCEDURE factCliente(in cliente CHAR(8)) 
BEGIN 
  SELECT f.codF,f.fecha,f.dni, f.nombre, f.total, f.codS
    FROM trfactura f
      INNER JOIN maesuc s
        ON f.codS = s.codS
      WHERE f.dni = cliente
      ORDER BY f.codF;
END$$ 
DELIMITER ;

/* Busqueda de boleta por código (RF-BBCB14) */
/*Este procedimiento muestra una factura específica
  tomando como entrada su código*/
DELIMITER $$ 
CREATE PROCEDURE factCod(in codigo INT) 
BEGIN 
  SELECT f.codF,f.fecha,f.dni, f.nombre, f.total, f.codS 
    FROM trfactura f
    INNER JOIN maesuc s
        ON f.codS = s.codS
      WHERE f.codF = codigo;
END$$ 
DELIMITER ;

/* Ver Detalle (RF-IBVD15) */
/*Este procedimiento muestra el detalle de una factura
  específica, toma el código como entrada*/
DELIMITER $$ 
CREATE PROCEDURE factDetalle(cod_fact INT) 
BEGIN 
  SELECT m.nombre, d.cantidad, m.precio,d.coste
  FROM trfactura f 
  JOIN detalle d ON f.codF = d.codF
  JOIN maemed m ON m.codM = d.codM
  WHERE f.codF = cod_fact;
END$$ 
DELIMITER ;

/* Ver cabecera (RF-IBVD15) */
DELIMITER $$
CREATE PROCEDURE factCabecera(cod_fact INT)
BEGIN 
  SELECT f.codF, f.fecha, f.dni, f.nombre, f.total, f.igv
  FROM trfactura f 
  WHERE f.codF = cod_fact;
END$$ 
DELIMITER ;



/* Sumar monto a la factura/boleta(RF-CPTP08) */
/*Este procedimiento aumentará el total a pagar en la factura
  Este procedimiento se dispara automáticamente*/
DELIMITER $$ 
CREATE PROCEDURE sum_fact(in cf INT, coste FLOAT) 
BEGIN
  UPDATE trFactura
  SET total = (total + coste)
  WHERE codF = cf;
END$$ 
DELIMITER ;

/* Actualizar IGV (RF-CPM07) */
/*Este procedimiento recalcula el IGV en una boleta
  Este procedimiento se dispara automáticamente*/
DELIMITER $$ 
CREATE PROCEDURE act_igv(in cf INT) 
BEGIN
  UPDATE trFactura
  SET igv = ROUND(total*0.18,2)
  WHERE codF = cf;
END$$ 
DELIMITER ;

/* Restar medicamento del stock(RF-PE02) */
/*Este procedimiento reduce el stock de un medicamento en una sucursal
  Este procedimiento se dispara automáticamente*/
DELIMITER $$ 
CREATE PROCEDURE resMed(in cm INT, cs INT, cant INT) 
BEGIN
  UPDATE trStock 
  SET stock = (stock - cant)
  WHERE codM = cm
    AND codS = cs;
END$$ 
DELIMITER ;

/* Agregar medicamentos en la factura (RF-AMB05) (RF-CPM07) */
/*Este procedimiento permite agregar un producto al detalle de la factura,
  se le debe ingresar el código de la factura, el código del medicamento,
  y la cantidad a vender, se debe ingresar un medicamento que esté en la
  misma sucursal en la que se ha creado la factura*/
DELIMITER $$ 
CREATE PROCEDURE addMed(in cf INT, cm INT, cant INT) 
BEGIN
  DECLARE pr FLOAT;
  DECLARE cs INT;
  SELECT precio INTO pr FROM maemed WHERE codM = cm;
  SELECT codS INTO cs FROM trFactura WHERE codF = cf;
  SET pr = ROUND(pr*cant,2);
  INSERT INTO detalle VALUES (cf, cm, cs, cant, pr);
END$$ 
DELIMITER ;

/* Restar monto de la factura(RF-EPB06) */
/*Este procedimiento reducirá el total a pagar en la factura
  Este procedimiento se dispara automáticamente*/
DELIMITER $$ 
CREATE PROCEDURE res_fact(in cf INT, coste FLOAT) 
BEGIN
  UPDATE trFactura
  SET total = (total - coste)
  WHERE codF = cf;
END$$ 
DELIMITER ;

/* Devolver medicamento al stock(RF-EPB06) */
/*Este procedimiento aumenta el stock de un medicamento en una sucursal
  Este procedimiento se dispara automáticamente*/
DELIMITER $$ 
CREATE PROCEDURE devMed(in cm INT, cs INT, cant INT) 
BEGIN
  UPDATE trStock 
  SET stock = (stock + cant)
  WHERE codM = cm
    AND codS = cs;
END$$ 
DELIMITER ;

/* Quitar un medicamento de la Factura */
/*Este procedimiento permite quitar un medicamento del detalle de la
  factura, se le debe ingresar el código de la factura y del medicamento
  a quitar.
  OJO MUY IMPORTANTE: Este procedimiento quitará TODAS las unidades del
  medicamento de la factura, no una, no dos, TODAS*/
DELIMITER $$ 
CREATE PROCEDURE quitMed(in cf INT, cm INT) 
BEGIN
  DECLARE cs INT;
  SELECT codS INTO cs FROM trFactura WHERE codF = cf;
  DELETE FROM detalle 
    WHERE
      codf = cf
    AND
      codM = cm
    AND
      codS = cs;
END$$ 
DELIMITER ;

/*IMPORTANTE CORRER PRIMERO LA CREACIÓN DE PROCEDIMIENTOS*/
/*DE LO CONTRARIO ESTE SCRIPT NO FUNCIONARÁ*/

/* Al añadir un producto al detalle de factura */
/* Cada que se añada un producto a una factura pasarán tres cosas */
/* Se sumará el coste de los productos añadidos a la factura */
/* Se recalculará el IGV de la factura */
/* Se reducirá el medicamento del stock correspondiente */
DELIMITER $$
CREATE TRIGGER sumar_factura AFTER INSERT ON detalle FOR EACH ROW 
BEGIN
	call sum_fact(NEW.codF,NEW.coste);
	call act_igv(NEW.codF);
	call resMed(NEW.codM,NEW.codS,NEW.cantidad);
END$$
DELIMITER;

/* Al quitar un producto del detalle de factura */
/* Cada que se quite un producto de una factura pasarán tres cosas */
/* Se restará el coste de los productos removidos de la factura */
/* Se recalculará el IGV de la factura */
/* Se devolverá el medicamento al stock correspondiente */
DELIMITER $$
CREATE TRIGGER restar_factura AFTER DELETE ON detalle FOR EACH ROW 
BEGIN
	call res_fact(OLD.codF,OLD.coste);
	call act_igv(OLD.codF);
	call devMed(OLD.codM, OLD.codS, OLD.cantidad);
END$$

/* Ver el listado de sucursales */
DELIMITER $$ 
CREATE PROCEDURE ver_sucursales() 
BEGIN 
  SELECT * FROM maesuc;
END$$ 
DELIMITER ;

/* Ver una sola sucursal */
DELIMITER $$ 
CREATE PROCEDURE ver_sucursal(idS INT) 
BEGIN 
  SELECT * FROM maesuc 
  WHERE codS = idS ;
END$$ 
DELIMITER ;


/*IMPORTANTE CORRER PRIMERO LA CREACIÓN DE PROCEDIMIENTOS Y TRIGGERS*/
/*DE LO CONTRARIO ESTE SCRIPT NO FUNCIONARÁ CORRECTAMENTE*/

/* Inserts de medicamentos */
INSERT INTO maemed VALUES (1, 'Bismutol 262 Mg Tableta Masticable | SOBRE X2 TABS 1 UN', 1, 1.06);
INSERT INTO maemed VALUES (2, 'Vitapyrena Forte Antigripal Sabor Miel y Limón | GRANULADO 1 UN', 0, 2.29);
INSERT INTO maemed VALUES (3, 'Vick Vaporub Ungüento tópico | 12 G 1 UN', 0, 2.43);
INSERT INTO maemed VALUES (4, 'Multi-bioticos Caramelos duros con sabor a Menta y Miel sin Azúcar | SOBRE 1 UN', 0, 2.54);
INSERT INTO maemed VALUES (5, 'Multi-bioticos Caramelos duros con sabor a Chicha sin Azúcar | SOBRE 1 UN', 1, 2.54);
INSERT INTO maemed VALUES (6, 'Vick Baby Balm Bálsamo para bebé | 12 G 1 UN', 0, 2.95);
INSERT INTO maemed VALUES (7, 'Multi-bioticos Pastilla dura con sabor a Mentol y Eucaliptol | PASTILLAS MASTICABLES 1 UN', 0, 2.56);
INSERT INTO maemed VALUES (8, 'Vick Vaporub Ungüento tópico | POTE 50 G', 0, 8.50);
INSERT INTO maemed VALUES (9, 'BabyBalm Vick Bálsamo | POTE 50 G', 0, 9.80);
INSERT INTO maemed VALUES (10, 'Vitapyrena forte 500mg+10mg Polvo Solución Oral | CAJA 5 UN', 1, 12.80);

/* Inserts de sucursales */
INSERT INTO maesuc VALUES (1, 'Av. Ejercito 245');
INSERT INTO maesuc VALUES (2, 'Av. Dolores 028');
INSERT INTO maesuc VALUES (3, 'Av. Estados Unidos 293');

/* Inserts de stock en sucursal 1 */
INSERT INTO trstock VALUES (1, 1, 47);
INSERT INTO trstock VALUES (1, 3, 56);
INSERT INTO trstock VALUES (1, 5, 19);
INSERT INTO trstock VALUES (1, 7, 25);
INSERT INTO trstock VALUES (1, 9, 32);
INSERT INTO trstock VALUES (1, 10, 21);

/* Inserts de stock en sucursal 2 */
INSERT INTO trstock VALUES (2, 2, 25);
INSERT INTO trstock VALUES (2, 4, 18);
INSERT INTO trstock VALUES (2, 6, 32);
INSERT INTO trstock VALUES (2, 8, 47);
INSERT INTO trstock VALUES (2, 10, 59);

/* Inserts de stock en sucursal 3 */
INSERT INTO trstock VALUES (3, 1, 21);
INSERT INTO trstock VALUES (3, 2, 87);
INSERT INTO trstock VALUES (3, 6, 23);
INSERT INTO trstock VALUES (3, 7, 45);
INSERT INTO trstock VALUES (3, 9, 18);


/* Facturas predeterminadas */
call crear_factura("71405548", "Leonardo Amado D.",1, "2023-05-09");
call crear_factura("71405549", "Leonardo Amado E.",1, "2023-05-09");
call crear_factura("71405550", "Leonardo Amado F.",1, "2023-05-09");
call crear_factura("71405548", "Leonardo Amado D.",2, "2023-05-10");
call crear_factura("71405550", "Leonardo Amado E.",3, "2023-05-10");
call crear_factura("71405549", "Leonardo Amado F.",2, "2023-05-11");

-- in dni CHAR(8),in nom VARCHAR(250),in sucursal INT,in fecha DATE, out cod_F INT

/* Detalle de Factura 1 predeterminado */
call addMed(1, 3, 6);
call addMed(1, 5, 4);

/* Detalle de Factura 2 predeterminado */
call addMed(2, 7, 2);
call addMed(2, 10, 3);

/* Detalle de Factura 3 predeterminado */
call addMed(3, 9, 2);
call addMed(3, 10, 1);

/* Detalle de Factura 4 predeterminado */
call addMed(4, 4, 7);
call addMed(4, 8, 3);

/* Detalle de Factura 5 predeterminado */
call addMed(5, 1, 2);
call addMed(5, 6, 4);

/* Detalle de Factura 6 predeterminado */
call addMed(6, 8, 2);
call addMed(6, 10, 1);
