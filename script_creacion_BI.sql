USE [GD1C2020]
GO


CREATE SCHEMA [CUARENTENA2020_BI] AUTHORIZATION [dbo]

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

---------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Ruta (
		ruta_id INT PRIMARY KEY IDENTITY(1,1),
		ruta_aerea_codigo DECIMAL(18,0) NOT NULL,
		ruta_aerea_ciu_orig NVARCHAR(255),
		ruta_aerea_ciu_dest NVARCHAR(255)
	)

----------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Tipo_Habitacion(
        tipo_habitacion_codigo DECIMAL(18,0) PRIMARY KEY NOT NULL IDENTITY(1,1),  
        tipo_habitacion_desc NVARCHAR(50) NULL,
		habitacion_numero DECIMAL(18,0),
        habitacion_piso DECIMAL(18,0),
        habitacion_frente NVARCHAR(50),
		habitacion_costo DECIMAL(18,2),
        habitacion_precio DECIMAL(18,2),
    )
SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Habitacion ON
INSERT INTO CUARENTENA2020_BI.Tipo_Habitacion
SELECT tipo_habitacion_codigo,tipo_habitacion_desc,habitacion_numero,habitacion_piso,habitacion_frente,habitacion_costo,habitacion_precio
FROM CUARENTENA2020.Habitacion h JOIN CUARENTENA2020.TipoHabitacion t ON t.tipo_habitacion_codigo = h.habitacion_tipo
SET IDENTITY_INSERT CUARENTENA2020_BI.Tipo_Habitacion OFF
-------------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Tipo_Pasaje(
		pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        BUTACA_NUMERO DECIMAL(18, 0),
        BUTACA_TIPO nvarchar(255) NOT NULL,
		pasaje_codigo DECIMAL(18, 0) NOT NULL,
        pasaje_costo DECIMAL(18, 2) NOT NULL,
        pasaje_precio DECIMAL(18, 2) NOT NULL

)

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