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
    tipo_habitacion_codigo INT PRIMARY KEY NOT NULL IDENTITY(1,1),  
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
--------------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Hechos_Estadia(
	empresa_id INT REFERENCES CUARENTENA2020_BI.Proveedor,
	tipo_habitacion_codigo INT REFERENCES CUARENTENA2020_BI.Tipo_Habitacion,
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

INSERT INTO CUARENTENA2020_BI.Hechos_Estadia
	SELECT 
		c.compra_empresa,
		h.habitacion_tipo,
		v.venta_cliente,
		year(v.venta_fecha) as anio,
		month(v.venta_fecha) as mes,
		avg(h.habitacion_costo) as precio_prom_compra,
		avg(h.habitacion_precio) as precio_prom_venta,
		case
			when h.habitacion_tipo = 1001 then 1 --Base Simple
			when h.habitacion_tipo = 1002 then 2 --Base Doble
			when h.habitacion_tipo = 1003 then 3 --Base Triple
			when h.habitacion_tipo = 1004 then 4 --Base Cuadruple
			when h.habitacion_tipo = 1005 then 1 --King
			else 0 --tipo no contemplado
		end as CANT_CAMAS_VENDIDAS,
		count(*) as CANT_HAB_VENDIDAS,
		sum(h.habitacion_precio - h.habitacion_costo) as GANANCIAS_ESTADIA

	FROM CUARENTENA2020.Estadia e
	JOIN CUARENTENA2020.CompraEstadia ce on ce.compra_estadia_codigo = e.estadia_codigo
	JOIN CUARENTENA2020.Compra c on c.compra_id = ce.compra_estadia_id
	JOIN CUARENTENA2020.Estadia_X_Habitacion eh on eh.id_estadia = e.estadia_codigo
	JOIN CUARENTENA2020.Habitacion h on h.habitacion_id = eh.id_habitacion
	JOIN CUARENTENA2020.VentaEstadia ve on ve.id_estadia = e.estadia_codigo
	JOIN CUARENTENA2020.Venta v on v.venta_id = ve.id_venta
	group by
		c.compra_empresa,
		h.habitacion_tipo,
		v.venta_cliente,
		year(v.venta_fecha),
		month(v.venta_fecha)


----------------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Hechos_Pasaje(
	ruta_codigo INT, -- esta no es FK porque no es unico el codigo
	avion_id INT REFERENCES CUARENTENA2020_BI.Avion,
	empresa_id INT REFERENCES CUARENTENA2020_BI.Proveedor,
	cliente_id INT REFERENCES CUARENTENA2020_BI.Cliente,
	tipo_pasaje_id INT REFERENCES CUARENTENA2020_BI.Tipo_Pasaje,
	anio NUMERIC(4),
	mes NUMERIC(2),
	PRECIO_PROM_COMPRA DECIMAL(18,2),
	PRECIO_PROM_VENTA DECIMAL(18,2),
	CANT_PASAJES_VENDIDOS INT,
	GANANCIAS_PASAJE DECIMAL(18,2),
	PRIMARY KEY(ruta_codigo,avion_id,empresa_id,cliente_id,tipo_pasaje_id)
)

INSERT INTO CUARENTENA2020_BI.Hechos_Pasaje
	SELECT 
		v.vuelo_ruta,
		v.vuelo_avion,
		c.compra_empresa,
		venta.venta_cliente,
		p.pasaje_tipo_butaca,
		year(venta.venta_fecha) as anio,
		month(venta.venta_fecha) as mes,
		AVG(p.pasaje_costo) as PRECIO_PROM_COMPRA,
		AVG(p.pasaje_precio) as PRECIO_PROM_VENTA,
		count(*) as CANT_PASAJES_VENDIDOS,
		sum(p.pasaje_precio - p.pasaje_costo) as GANANCIAS_PASAJE
	FROM CUARENTENA2020.Pasaje p
	JOIN CUARENTENA2020.Compra c on c.compra_id = p.pasaje_compra_id
	JOIN CUARENTENA2020.CompraPasaje cp on cp.compra_pasaje_id = p.pasaje_compra_id
	JOIN CUARENTENA2020.VentaPasaje vp on vp.id_pasaje = p.pasaje_codigo 
	JOIN CUARENTENA2020.Venta venta on venta.venta_id = vp.id_venta
	JOIN CUARENTENA2020.Vuelo v on v.vuelo_codigo = cp.compra_pasaje_vuelo
	--en cada fila quedan agrupados los que son del mismo mes/ruta/avion/empresa/cliente/tipo_butaca
	group by 
		year(venta.venta_fecha),
		month(venta.venta_fecha),
		v.vuelo_ruta,
		v.vuelo_avion,
		c.compra_empresa,
		venta.venta_cliente,
		p.pasaje_tipo_butaca
------------------------------------------------------------------------------------
GO

CREATE VIEW Ganancias_2018
AS
SELECT anio,mes, GANANCIAS_PASAJE FROM CUARENTENA2020_BI.Hechos_Pasaje WHERE anio = 2018;
GO

CREATE VIEW [Pasajes Vendidos A Clientes Apellidados Moreno]
AS
SELECT cliente_nombre,cliente_apellido,CANT_PASAJES_VENDIDOS 
FROM CUARENTENA2020_BI.Hechos_Pasaje h JOIN CUARENTENA2020_BI.Cliente c ON h.cliente_id = c.cliente_id
WHERE cliente_apellido = 'Moreno'
GO

CREATE VIEW [Cantidad de camas vendidas a clientes mayores de 20]
AS
SELECT cliente_nombre,cliente_apellido,cliente_edad, CANT_CAMAS_VENDIDAS
FROM CUARENTENA2020_BI.Hechos_Estadia h JOIN CUARENTENA2020_BI.Cliente c ON h.cliente_id = c.cliente_id
WHERE cliente_edad > 20
GO