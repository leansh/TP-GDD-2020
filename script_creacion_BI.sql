USE [GD1C2020]
GO

CREATE SCHEMA [CUARENTENA2020_BI] AUTHORIZATION [dbo]

--------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Proveedor(
	empresa_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    empresa_razon_social nvarchar(255) NOT NULL,
)

--------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Cliente(
cliente_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        cliente_apellido NVARCHAR(255) NULL,
        cliente_nombre NVARCHAR(255) NULL,
        cliente_dni DECIMAL(18,0) NULL,
        cliente_fecha_nac DATETIME2(3) NULL,
		cliente_edad INT NULL,
        cliente_mail NVARCHAR(255) NULL,
        cliente_telefono INT NULL,
)

--------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Fecha(
		fecha_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		anio NUMERIC(4),
		mes NUMERIC(2)
)

--------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Avion(
		avion_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        avion_identificador nvarchar(50),    
        avion_modelo nvarchar(50) 

)

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

CREATE TABLE CUARENTENA2020_BI.TipoHabitacion(
        tipo_habitacion_codigo DECIMAL(18,0) PRIMARY KEY NOT NULL IDENTITY(1,1),  
        tipo_habitacion_desc NVARCHAR(50) NULL,
		habitacion_numero DECIMAL(18,0),
        habitacion_piso DECIMAL(18,0),
        habitacion_frente NVARCHAR(50),
    )

-----------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Habitacion(
        habitacion_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        habitacion_costo DECIMAL(18,2),
        habitacion_precio DECIMAL(18,2),
		tipo_habitacion_codigo DECIMAL(18,0) REFERENCES CUARENTENA2020_BI.TipoHabitacion
    )

-------------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Tipo_Pasaje(
		tipo_pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        BUTACA_NUMERO DECIMAL(18, 0),
        BUTACA_TIPO nvarchar(255) NOT NULL

)

--------------------------------------------------------------------------------
CREATE TABLE CUARENTENA2020_BI.Pasaje(
		pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        pasaje_codigo DECIMAL(18, 0) NOT NULL,
        pasaje_costo DECIMAL(18, 2) NOT NULL,
        pasaje_precio DECIMAL(18, 2) NOT NULL,
		tipo_pasaje_id INT REFERENCES CUARENTENA2020_BI.Tipo_Pasaje
)

--------------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020_BI.Hechos_Estadia(
		fecha_id INT REFERENCES CUARENTENA2020_BI.Fecha,
		empresa_id INT REFERENCES CUARENTENA2020_BI.Proveedor,
		habitacion_id INT REFERENCES CUARENTENA2020_BI.Habitacion,
		cliente_id INT REFERENCES CUARENTENA2020_BI.Cliente,
		PRECIO_PROM_COMPRA DECIMAL(18,2),
		PRECIO_PROM_VENTA DECIMAL(18,2),
		CANT_CAMAS_VENDIDAS INT,
		CANT_HAB_VENDIDAS INT,
		GANANCIAS_ESTADIA DECIMAL(18,2)
)

----------------------------------------------------------------------------------

CREATE TABLE CUARENTENA2020.Hechos_Pasaje(
		ciudad_id INT REFERENCES CUARENTENA2020_BI.Ciudad,
		ruta_id INT REFERENCES CUARENTENA2020_BI.Ruta,
		avion_id INT REFERENCES CUARENTENA2020_BI.Avion,
		empresa_id INT REFERENCES CUARENTENA2020_BI.Proveedor,
		cliente_id INT REFERENCES CUARENTENA2020_BI.Cliente,
		pasaje_id INT REFERENCES CUARENTENA2020_BI.Pasaje,
		PRECIO_PROM_COMPRA DECIMAL(18,2),
		PRECIO_PROM_VENTA DECIMAL(18,2),
		CANT_PASAJES_VENDIDOS INT,
		GANANCIAS_PASAJE DECIMAL(18,2)
)

------------------------------------------------------------------------------------