USE [GD1C2020]
GO


CREATE SCHEMA [CUARENTENA2020_BI] AUTHORIZATION [dbo]
GO

--------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Proveedor(
	empresa_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    empresa_razon_social nvarchar(255) NOT NULL,
)

SET IDENTITY_INSERT CUARENTENA2020_BI.Proveedor ON
INSERT INTO CUARENTENA2020_BI.Proveedor (empresa_id, empresa_razon_social)
	SELECT empresa_id,empresa_razon_social FROM CUARENTENA2020.Empresa
SET IDENTITY_INSERT CUARENTENA2020_BI.Proveedor OFF
--------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Cliente(
	cliente_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    cliente_apellido NVARCHAR(255) NULL,
    cliente_nombre NVARCHAR(255) NULL,
    cliente_dni DECIMAL(18,0) NULL,
    cliente_fecha_nac DATETIME2(3) NULL,
    cliente_mail NVARCHAR(255) NULL,
    cliente_telefono INT NULL,
	cliente_edad INT NULL,
)

SET IDENTITY_INSERT CUARENTENA2020_BI.Cliente ON
INSERT INTO CUARENTENA2020_BI.Cliente (cliente_id,cliente_apellido,cliente_nombre,cliente_dni,cliente_fecha_nac,cliente_mail,cliente_telefono,cliente_edad)
	SELECT cliente_id,cliente_apellido,cliente_nombre,cliente_dni,cliente_fecha_nac,cliente_mail,cliente_telefono, DATEDIFF(yy,cliente_fecha_nac,GETDATE()) FROM CUARENTENA2020.Cliente
SET IDENTITY_INSERT CUARENTENA2020_BI.Cliente OFF

--------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Avion(
	avion_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    avion_identificador nvarchar(50),    
    avion_modelo nvarchar(50) 
)

SET IDENTITY_INSERT CUARENTENA2020_BI.Avion ON
INSERT INTO CUARENTENA2020_BI.Avion (avion_id,avion_identificador,avion_modelo)
SELECT avion_id,avion_identificador,avion_modelo FROM CUARENTENA2020.Avion
SET IDENTITY_INSERT CUARENTENA2020_BI.Avion OFF
--------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Ciudad (
	ciudad_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	ciudad_nombre nvarchar(255)
)

SET IDENTITY_INSERT CUARENTENA2020_BI.Ciudad ON
INSERT INTO CUARENTENA2020_BI.Ciudad (ciudad_id, ciudad_nombre)
	SELECT ciudad_id, ciudad_nombre FROM CUARENTENA2020.Ciudad
SET IDENTITY_INSERT CUARENTENA2020_BI.Ciudad OFF
---------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Ruta (
	ruta_id INT PRIMARY KEY IDENTITY(1,1),
	ruta_aerea_codigo DECIMAL(18,0) NOT NULL,
	ruta_aerea_ciu_orig NVARCHAR(255),
	ruta_aerea_ciu_dest NVARCHAR(255)
)

SET IDENTITY_INSERT CUARENTENA2020_BI.Ruta ON
INSERT INTO CUARENTENA2020_BI.Ruta (ruta_id, ruta_aerea_codigo, ruta_aerea_ciu_orig, ruta_aerea_ciu_dest)
	SELECT r.ruta_aerea_id, r.ruta_aerea_codigo, c1.ciudad_id, c2.ciudad_id
	FROM CUARENTENA2020.Ruta r
	JOIN CUARENTENA2020.Ciudad c1 on c1.ciudad_id = r.ruta_aerea_ciu_orig
	JOIN CUARENTENA2020.Ciudad c2 on c2.ciudad_id = r.ruta_aerea_ciu_dest
SET IDENTITY_INSERT CUARENTENA2020_BI.Ruta OFF

----------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Tipo_Habitacion(
    tipo_habitacion_codigo DECIMAL(18,0) PRIMARY KEY NOT NULL IDENTITY(1,1),  
    tipo_habitacion_desc NVARCHAR(50) NULL,
)

SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Habitacion ON
INSERT INTO CUARENTENA2020_BI.Tipo_Habitacion (tipo_habitacion_codigo, tipo_habitacion_desc)
	SELECT tipo_habitacion_codigo,tipo_habitacion_desc
	FROM CUARENTENA2020.TipoHabitacion
SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Habitacion OFF
-------------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Tipo_Pasaje(
	tipo_pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
    butaca_tipo nvarchar(255) NOT NULL
)

SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Pasaje ON
INSERT INTO CUARENTENA2020_BI.Tipo_Pasaje (tipo_pasaje_id, butaca_tipo)
	SELECT tipo_butaca_id, tipo_butaca_descripcion
	FROM CUARENTENA2020.TipoButaca
SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Pasaje OFF

----------------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Fecha(
	fecha_id INT PRIMARY KEY NOT NULL IDENTITY(1,1), 
	fecha_anio NUMERIC(4),
	fecha_mes NUMERIC(2)
)

INSERT INTO	CUARENTENA2020_BI.Fecha
	SELECT distinct 
		year(c.compra_fecha) anio, 
		month(c.compra_fecha) mes
	FROM CUARENTENA2020.Compra c
	UNION
	SELECT distinct 
		year(v.venta_fecha), 
		month(v.venta_fecha)
	FROM CUARENTENA2020.Venta v
	order by anio, mes
--------------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Hechos_Estadia(
	empresa_id INT REFERENCES CUARENTENA2020_BI.Proveedor,
	tipo_habitacion_codigo DECIMAL(18,0) REFERENCES CUARENTENA2020_BI.Tipo_Habitacion,
	cliente_id INT REFERENCES CUARENTENA2020_BI.Cliente,
	anio NUMERIC(4),
	mes NUMERIC(2),
	PRECIO_PROM_COMPRA DECIMAL(18,2),
	PRECIO_PROM_VENTA DECIMAL(18,2),
	CANT_CAMAS_VENDIDAS INT,
	CANT_HAB_VENDIDAS INT,
	GANANCIAS_ESTADIA DECIMAL(18,2),
	PRIMARY KEY(empresa_id,tipo_habitacion_codigo,cliente_id,anio,mes)
)

----------------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Hechos_Pasaje(
	fecha_id INT REFERENCES CUARENTENA2020_BI.Fecha,
	ruta_id INT REFERENCES CUARENTENA2020_BI.Ruta,
	avion_id INT REFERENCES CUARENTENA2020_BI.Avion,
	empresa_id INT REFERENCES CUARENTENA2020_BI.Proveedor,
	cliente_id INT REFERENCES CUARENTENA2020_BI.Cliente,
	tipo_pasaje_id INT REFERENCES CUARENTENA2020_BI.Tipo_Pasaje,
	PRECIO_PROM_COMPRA DECIMAL(18,2),
	PRECIO_PROM_VENTA DECIMAL(18,2),
	CANT_PASAJES_VENDIDOS INT,
	GANANCIAS_PASAJE DECIMAL(18,2),
	PRIMARY KEY(ruta_id,avion_id,empresa_id,cliente_id,tipo_pasaje_id)
)

INSERT INTO CUARENTENA2020_BI.Hechos_Pasaje
	SELECT 
		--count(*)
		f.fecha_id,
		v.vuelo_ruta,
		v.vuelo_avion,
		c.compra_empresa,
		venta.venta_cliente,
		p.pasaje_tipo_butaca,
		AVG(p.pasaje_costo) PRECIO_PROM_COMPRA,
		AVG(p.pasaje_precio) PRECIO_PROM_VENTA,
		count(*) as CANT_PASAJES_VENDIDOS,
		sum(p.pasaje_precio - p.pasaje_costo) as GANANCIAS_PASAJE
	FROM CUARENTENA2020.Pasaje p
	JOIN CUARENTENA2020.Compra c on c.compra_id = p.pasaje_compra_id
	JOIN CUARENTENA2020.CompraPasaje cp on cp.compra_pasaje_id = p.pasaje_compra_id
	JOIN CUARENTENA2020.VentaPasaje vp on vp.id_pasaje = p.pasaje_codigo 
	JOIN CUARENTENA2020.Venta venta on venta.venta_id = vp.id_venta
	JOIN CUARENTENA2020_BI.Fecha f on f.fecha_anio = year(venta.venta_fecha) and f.fecha_mes = month(venta.venta_fecha)
	JOIN CUARENTENA2020.Vuelo v on v.vuelo_codigo = cp.compra_pasaje_vuelo
	--en cada fila quedan agrupados los que son del mismo mes/ruta/avion/empresa/cliente/tipo_butaca
	group by 
		f.fecha_id,
		v.vuelo_ruta,
		v.vuelo_avion,
		c.compra_empresa,
		venta.venta_cliente,
		p.pasaje_tipo_butaca



------------------------------------------------------------------------------------