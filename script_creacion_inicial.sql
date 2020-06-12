USE [GD1C2020]
GO
/****** Object:  StoredProcedure [dbo].[pr_crear_tablas]    Script Date: 10/6/2020 18:49:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('pr_crear_tablas') IS NULL
BEGIN
    EXEC('CREATE PROCEDURE pr_crear_tablas AS SET NOCOUNT ON;')
END
GO

ALTER PROCEDURE [dbo].[pr_crear_tablas] 
AS

BEGIN
    IF (SCHEMA_ID('CUARENTENA2020') IS NULL) 
    BEGIN
        EXEC ('CREATE SCHEMA [CUARENTENA2020] AUTHORIZATION [dbo]')
    END
----------------------------------------------------------------------------------------    
    CREATE TABLE CUARENTENA2020.Sucursal(
        sucursal_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        sucursal_dir NVARCHAR(255) NULL,
        sucursal_mail NVARCHAR(255) NULL,
        sucursal_telefono DECIMAL(18,0) NULL
    )

    INSERT INTO CUARENTENA2020.Sucursal SELECT DISTINCT SUCURSAL_DIR,SUCURSAL_MAIL,SUCURSAL_TELEFONO FROM gd_esquema.Maestra WHERE SUCURSAL_DIR IS NOT NULL
----------------------------------------------------------------------------------------
    CREATE TABLE CUARENTENA2020.Empresa (
        empresa_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
        empresa_razon_social nvarchar(255) NOT NULL,
    )

    INSERT INTO CUARENTENA2020.Empresa SELECT DISTINCT EMPRESA_RAZON_SOCIAL FROM gd_esquema.Maestra
----------------------------------------------------------------------------------------        
    CREATE TABLE CUARENTENA2020.Hotel (
        hotel_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
        hotel_calle nvarchar(50),
        hotel_nro_calle DECIMAL(18, 0),
        hotel_cantidad_estrellas DECIMAL(18, 0),
     )

    INSERT INTO CUARENTENA2020.Hotel SELECT DISTINCT HOTEL_CALLE,HOTEL_CANTIDAD_ESTRELLAS,HOTEL_NRO_CALLE FROM gd_esquema.Maestra WHERE HOTEL_CALLE IS NOT NULL
----------------------------------------------------------------------------------------    
	CREATE TABLE CUARENTENA2020.Ciudad (
		ciudad_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		ciudad_nombre nvarchar(255)
	)
	INSERT INTO CUARENTENA2020.Ciudad 
		SELECT DISTINCT RUTA_AEREA_CIU_ORIG FROM gd_esquema.Maestra WHERE RUTA_AEREA_CIU_ORIG IS NOT NULL
		UNION
		SELECT DISTINCT RUTA_AEREA_CIU_DEST FROM gd_esquema.Maestra WHERE RUTA_AEREA_CIU_DEST IS NOT NULL
----------------------------------------------------------------------------------------	
	CREATE TABLE CUARENTENA2020.Ruta (
		ruta_aerea_codigo INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		ruta_aerea_ciu_orig INT,
		ruta_aerea_ciu_dest INT
	)
    SET IDENTITY_INSERT CUARENTENA2020.Ruta ON
    INSERT INTO CUARENTENA2020.Ruta 
		SELECT DISTINCT 
			RUTA_AEREA_CODIGO,
			(SELECT ciudad_id from CUARENTENA2020.Ciudad where ciudad_nombre = RUTA_AEREA_CIU_ORIG),
			(SELECT ciudad_id from CUARENTENA2020.Ciudad where ciudad_nombre = RUTA_AEREA_CIU_DEST) 
		FROM gd_esquema.Maestra 
		WHERE RUTA_AEREA_CODIGO IS NOT NULL
	SET IDENTITY_INSERT CUARENTENA2020.Ruta OFF
----------------------------------------------------------------------------------------
    CREATE TABLE CUARENTENA2020.Avion (
        avion_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        avion_identificador nvarchar(50),    
        avion_modelo nvarchar(50) 
    )
    
    INSERT INTO CUARENTENA2020.Avion 
		SELECT DISTINCT AVION_IDENTIFICADOR,AVION_MODELO 
		FROM gd_esquema.Maestra 
		WHERE AVION_IDENTIFICADOR IS NOT NULL
----------------------------------------------------------------------------------------
    CREATE TABLE CUARENTENA2020.Compra(
        compra_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        compra_fecha DATETIME2(3) NULL,
        compra_empresa INT NULL REFERENCES CUARENTENA2020.Empresa,
    )

	SET IDENTITY_INSERT CUARENTENA2020.Compra ON
    INSERT INTO CUARENTENA2020.Compra 
		SELECT DISTINCT 
			COMPRA_NUMERO, 
			COMPRA_FECHA, 
			e.empresa_id
		FROM gd_esquema.Maestra m
		join CUARENTENA2020.Empresa e on e.empresa_razon_social = m.EMPRESA_RAZON_SOCIAL
		where COMPRA_NUMERO is not null
	SET IDENTITY_INSERT CUARENTENA2020.Compra OFF
----------------------------------------------------------------------------------------    
	CREATE TABLE CUARENTENA2020.Cliente(
        cliente_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        cliente_apellido NVARCHAR(255) NULL,
        cliente_nombre NVARCHAR(255) NULL,
        cliente_dni DECIMAL(18,0) NULL,
        cliente_fecha_nac DATETIME2(3) NULL,
        cliente_mail NVARCHAR(255) NULL,
        cliente_telefono INT NULL,
    )
    INSERT INTO CUARENTENA2020.Cliente 
		SELECT DISTINCT CLIENTE_APELLIDO,CLIENTE_NOMBRE,CLIENTE_DNI,CLIENTE_FECHA_NAC,CLIENTE_MAIL,CLIENTE_TELEFONO 
		FROM gd_esquema.Maestra
		where CLIENTE_DNI is not null
----------------------------------------------------------------------------------------
    CREATE TABLE CUARENTENA2020.Venta(
	    venta_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		venta_fecha DATETIME2(3),
		venta_cliente INT REFERENCES CUARENTENA2020.Cliente,
        venta_sucursal INT REFERENCES CUARENTENA2020.Sucursal,
    )

	SET IDENTITY_INSERT CUARENTENA2020.Venta ON
    INSERT INTO CUARENTENA2020.Venta 
		SELECT distinct 
			FACTURA_NRO,
			FACTURA_FECHA,
			c.cliente_id,
			s.sucursal_id
		FROM gd_esquema.Maestra m
		join CUARENTENA2020.Cliente c on c.cliente_dni = m.CLIENTE_DNI
		join CUARENTENA2020.Sucursal s on s.sucursal_dir = m.SUCURSAL_DIR
		where FACTURA_NRO is not null
	SET IDENTITY_INSERT CUARENTENA2020.Venta OFF
----------------------------------------------------------------------------------------
    
    CREATE TABLE CUARENTENA2020.Vuelo (
        vuelo_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        vuelo_fecha_salida DATETIME2(3) NOT NULL,
        vuelo_fecha_llegada DATETIME2(3) NOT NULL,
        id_ruta INT REFERENCES CUARENTENA2020.Ruta,
        id_avion INT REFERENCES CUARENTENA2020.Avion
    )

	SET IDENTITY_INSERT CUARENTENA2020.Vuelo ON
    INSERT INTO CUARENTENA2020.Vuelo 
		SELECT distinct
			VUELO_CODIGO,
			VUELO_FECHA_SALUDA,
			VUELO_FECHA_LLEGADA ,
			RUTA_AEREA_CODIGO,
			a.avion_id
		FROM gd_esquema.Maestra m
		join CUARENTENA2020.Avion a on a.avion_identificador = m.AVION_IDENTIFICADOR
		where VUELO_CODIGO is not null
	SET IDENTITY_INSERT CUARENTENA2020.Vuelo OFF
----------------------------------------------------------------------------------------
    CREATE TABLE CUARENTENA2020.CompraPasaje(
        compra_pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        vuelo_id INT REFERENCES CUARENTENA2020.Vuelo
    )

	SET IDENTITY_INSERT CUARENTENA2020.CompraPasaje ON
	insert into CUARENTENA2020.CompraPasaje
		select distinct 
			COMPRA_NUMERO, 
			VUELO_CODIGO
		from gd_esquema.Maestra
		where 
			COMPRA_NUMERO is not null 
			and VUELO_CODIGO is not null
	SET IDENTITY_INSERT CUARENTENA2020.CompraPasaje OFF
----------------------------------------------------------------------------------------		
		
    
    CREATE TABLE CUARENTENA2020.Habitacion(
        habitacion_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),    
        habitacion_numero DECIMAL(18,0) NULL,
        habitacion_piso DECIMAL(18,0) NULL,
        habitacion_frente NVARCHAR(50) NULL,
        habitacion_costo DECIMAL(18,2) NULL,
        habitacion_precio DECIMAL(18,2) NULL,
        tipo_habitacion_codigo DECIMAL(18,0) NULL,
        tipo_habitacion_desc NVARCHAR(50) NULL,
        hotel_id INT REFERENCES CUARENTENA2020.Hotel
    )
    
    INSERT INTO CUARENTENA2020.Habitacion SELECT HABITACION_NUMERO,HABITACION_PISO,HABITACION_FRENTE,HABITACION_COSTO,HABITACION_PRECIO,TIPO_HABITACION_CODIGO,TIPO_HABITACION_DESC FROM gd_esquema.Maestra
----------------------------------------------------------------------------------------
    
    CREATE TABLE CUARENTENA2020.Estadia(
        estadia_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        estadia_codigo DECIMAL(18,0),
        estadia_cantidad_noches DECIMAL(18,0) NULL,
        estadia_fecha_ini DATETIME2(3) NULL,
        id_hotel INT REFERENCES CUARENTENA2020.Hotel,
        id_habitacion INT REFERENCES CUARENTENA2020.Habitacion
    )
    
    INSERT INTO CUARENTENA2020.Estadia SELECT ESTADIA_CODIGO,ESTADIA_CANTIDAD_NOCHES,ESTADIA_FECHA_INI FROM gd_esquema.Maestra
----------------------------------------------------------------------------------------    
    CREATE TABLE CUARENTENA2020.Butaca (
        butaca_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        BUTACA_NUMERO DECIMAL(18, 0),
        ID_avion INT REFERENCES CUARENTENA2020.Avion,
        BUTACA_TIPO nvarchar(255) NOT NULL
     )

    INSERT INTO CUARENTENA2020.Butaca SELECT BUTACA_NUMERO,BUTACA_TIPO FROM gd_esquema.Maestra
----------------------------------------------------------------------------------------    
    CREATE TABLE CUARENTENA2020.Pasaje(
        pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        pasaje_codigo DECIMAL(18, 0) NOT NULL,
        pasaje_costo DECIMAL(18, 2) NOT NULL,
        pasaje_precio DECIMAL(18, 2) NOT NULL,
        compra_id INT REFERENCES CUARENTENA2020.CompraPasaje,
        butaca_id INT REFERENCES CUARENTENA2020.Butaca
     )
     
     INSERT INTO CUARENTENA2020.Pasaje SELECT PASAJE_CODIGO,PASAJE_COSTO,PASAJE_PRECIO FROM gd_esquema.Maestra
----------------------------------------------------------------------------------------    
    CREATE TABLE CUARENTENA2020.VentaPasaje(
        id_ven_pas INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        precio DECIMAL(18,2),
        id_com_pas INT REFERENCES CUARENTENA2020.CompraPasaje,
        id_venta INT REFERENCES CUARENTENA2020.Venta
    )
    
    CREATE TABLE CUARENTENA2020.CompraEstadia(
        compra_estadia_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        id_estadia INT REFERENCES CUARENTENA2020.Estadia
    )
    
    CREATE TABLE CUARENTENA2020.VentaEstadia(
        id_ven_est INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        precio DECIMAL(18,2),
        id_com_est INT REFERENCES CUARENTENA2020.CompraEstadia,
        id_venta INT REFERENCES CUARENTENA2020.Venta
    )
    
    CREATE TABLE CUARENTENA2020.Estadia_X_Habitacion(
        id_habitacion INT REFERENCES CUARENTENA2020.Habitacion,
        id_estadia INT REFERENCES CUARENTENA2020.Estadia
    )
END
GO

EXEC pr_crear_tablas;
go