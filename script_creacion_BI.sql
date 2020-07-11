USE [GD1C2020]
GO


CREATE SCHEMA [CUARENTENA2020_BI] AUTHORIZATION [dbo]
GO

--------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Proveedor(
	empresa_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    empresa_razon_social nvarchar(255) NOT NULL,
)
INSERT INTO CUARENTENA2020_BI.Proveedor
SELECT empresa_id,empresa_razon_social FROM CUARENTENA2020.Empresa
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

INSERT INTO CUARENTENA2020_BI.Cliente (cliente_id,cliente_apellido,cliente_nombre,cliente_dni,cliente_fecha_nac,cliente_mail,cliente_telefono,cliente_edad)
SELECT cliente_id,cliente_apellido,cliente_nombre,cliente_dni,cliente_fecha_nac,cliente_mail,cliente_telefono, DATEDIFF(yy,cliente_fecha_nac,GETDATE()) FROM CUARENTENA2020.Cliente

--------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Avion(
		avion_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        avion_identificador nvarchar(50),    
        avion_modelo nvarchar(50) 

)

INSERT INTO CUARENTENA2020_BI.Avion
SELECT avion_id,avion_identificador,avion_modelo FROM CUARENTENA2020.Avion
--------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Ciudad (
		ciudad_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		ciudad_nombre nvarchar(255)
)

INSERT INTO CUARENTENA2020_BI.Ciudad
	SELECT ciudad_nombre FROM CUARENTENA2020.Ciudad
---------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Ruta (
		ruta_id INT PRIMARY KEY IDENTITY(1,1),
		ruta_aerea_codigo DECIMAL(18,0) NOT NULL,
		ruta_aerea_ciu_orig NVARCHAR(255),
		ruta_aerea_ciu_dest NVARCHAR(255)
	)

INSERT INTO CUARENTENA2020_BI.Ruta
	SELECT ruta_aerea_codigo, c1.ciudad_id, c2.ciudad_id
	FROM CUARENTENA2020.Ruta r
	JOIN CUARENTENA2020.Ciudad c1 on c1.ciudad_id = r.ruta_aerea_ciu_orig
	JOIN CUARENTENA2020.Ciudad c2 on c2.ciudad_id = r.ruta_aerea_ciu_dest

----------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Tipo_Habitacion(
        tipo_habitacion_codigo DECIMAL(18,0) PRIMARY KEY NOT NULL IDENTITY(1,1),  
        tipo_habitacion_desc NVARCHAR(50) NULL,
    )
SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Habitacion ON
INSERT INTO CUARENTENA2020_BI.Tipo_Habitacion
SELECT tipo_habitacion_codigo,tipo_habitacion_desc
FROM CUARENTENA2020.TipoHabitacion
SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Habitacion OFF
-------------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Tipo_Pasaje(
		pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        BUTACA_TIPO nvarchar(255) NOT NULL
)

INSERT INTO CUARENTENA2020_BI.Tipo_Pasaje
	SELECT tipo_butaca_descripcion
	FROM CUARENTENA2020.TipoButaca
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

CREATE TABLE CUARENTENA2020.Hechos_Pasaje(
		ciudad_id INT REFERENCES CUARENTENA2020_BI.Ciudad,
		ruta_id INT REFERENCES CUARENTENA2020_BI.Ruta,
		avion_id INT REFERENCES CUARENTENA2020_BI.Avion,
		empresa_id INT REFERENCES CUARENTENA2020_BI.Proveedor,
		cliente_id INT REFERENCES CUARENTENA2020_BI.Cliente,
		pasaje_id INT REFERENCES CUARENTENA2020_BI.Tipo_Pasaje,
		anio NUMERIC(4),
		mes NUMERIC(2),
		PRECIO_PROM_COMPRA DECIMAL(18,2),
		PRECIO_PROM_VENTA DECIMAL(18,2),
		CANT_PASAJES_VENDIDOS INT,
		GANANCIAS_PASAJE DECIMAL(18,2),
		PRIMARY KEY(ciudad_id,ruta_id,avion_id,empresa_id,cliente_id,pasaje_id,anio,mes)
)

------------------------------------------------------------------------------------