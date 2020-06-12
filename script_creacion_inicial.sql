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

	INSERT INTO CUARENTENA2020.Hotel 
		SELECT DISTINCT 
			HOTEL_CALLE,
			HOTEL_NRO_CALLE,
			HOTEL_CANTIDAD_ESTRELLAS 
		FROM gd_esquema.Maestra 
		WHERE HOTEL_CALLE IS NOT NULL
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
		ruta_aerea_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
		ruta_aerea_codigo INT NOT NULL,
		ruta_aerea_ciu_orig INT,
		ruta_aerea_ciu_dest INT
	)

	INSERT INTO CUARENTENA2020.Ruta 
		SELECT DISTINCT 
			RUTA_AEREA_CODIGO,
			(SELECT ciudad_id from CUARENTENA2020.Ciudad where ciudad_nombre = RUTA_AEREA_CIU_ORIG),
			(SELECT ciudad_id from CUARENTENA2020.Ciudad where ciudad_nombre = RUTA_AEREA_CIU_DEST) 
		FROM gd_esquema.Maestra 
		WHERE RUTA_AEREA_CODIGO IS NOT NULL
		order by RUTA_AEREA_CODIGO

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
		(
			compra_id,
			compra_fecha,
			compra_empresa 
		)
		SELECT DISTINCT 
			COMPRA_NUMERO, 
			COMPRA_FECHA,
			e.empresa_id
		FROM gd_esquema.Maestra m
		join CUARENTENA2020.Empresa e on e.empresa_razon_social = m.EMPRESA_RAZON_SOCIAL
		where COMPRA_NUMERO is not null

	SET IDENTITY_INSERT CUARENTENA2020.Compra OFF

	/*
		CUARENTENA2020.Compra 
		Tiene una entrada por cada compra que realizo la agencia a alguna empresa
	*/
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
		SELECT CLIENTE_APELLIDO,CLIENTE_NOMBRE,CLIENTE_DNI,CLIENTE_FECHA_NAC,CLIENTE_MAIL,CLIENTE_TELEFONO 
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
		(
			venta_id,
			venta_fecha,
			venta_cliente,
			venta_sucursal
		)
		SELECT distinct
			FACTURA_NRO,
			FACTURA_FECHA,
			c.cliente_id,
			s.sucursal_id
		FROM gd_esquema.Maestra m
		join CUARENTENA2020.Cliente c on c.cliente_dni = m.CLIENTE_DNI and c.cliente_fecha_nac = m.CLIENTE_FECHA_NAC
		join CUARENTENA2020.Sucursal s on s.sucursal_dir = m.SUCURSAL_DIR
		where FACTURA_NRO is not null

	SET IDENTITY_INSERT CUARENTENA2020.Venta OFF

	/*
		Aca use dni y fecha de nacimiento porque el dni no es unico
	*/
----------------------------------------------------------------------------------------
    
	CREATE TABLE CUARENTENA2020.Vuelo (
		vuelo_codigo INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		vuelo_fecha_salida DATETIME2(3) NOT NULL,
		vuelo_fecha_llegada DATETIME2(3) NOT NULL,
		vuelo_ruta INT,
		vuelo_avion INT REFERENCES CUARENTENA2020.Avion
	)

	SET IDENTITY_INSERT CUARENTENA2020.Vuelo ON
	INSERT INTO CUARENTENA2020.Vuelo
		(
			vuelo_codigo,
			vuelo_fecha_salida ,
			vuelo_fecha_llegada,
			vuelo_ruta,
			vuelo_avion
		)
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
		compra_pasaje_vuelo INT REFERENCES CUARENTENA2020.Vuelo
	)

	SET IDENTITY_INSERT CUARENTENA2020.CompraPasaje ON
	insert into CUARENTENA2020.CompraPasaje
		(
			compra_pasaje_id,
			compra_pasaje_vuelo
		)
		select distinct 
			COMPRA_NUMERO, 
			VUELO_CODIGO
		from gd_esquema.Maestra
		where 
			COMPRA_NUMERO is not null 
			and VUELO_CODIGO is not null
	SET IDENTITY_INSERT CUARENTENA2020.CompraPasaje OFF
----------------------------------------------------------------------------------------
	CREATE TABLE CUARENTENA2020.TipoHabitacion(
		tipo_habitacion_codigo INT PRIMARY KEY NOT NULL IDENTITY(1,1),  
		tipo_habitacion_desc NVARCHAR(50) NULL,
	)

	SET IDENTITY_INSERT CUARENTENA2020.TipoHabitacion ON
	INSERT INTO CUARENTENA2020.TipoHabitacion 
		(
			tipo_habitacion_codigo, 
			tipo_habitacion_desc
		)
		SELECT distinct
			TIPO_HABITACION_CODIGO,
			TIPO_HABITACION_DESC 
		FROM gd_esquema.Maestra
		where TIPO_HABITACION_CODIGO is not null
	SET IDENTITY_INSERT CUARENTENA2020.TipoHabitacion OFF
----------------------------------------------------------------------------------------
	CREATE TABLE CUARENTENA2020.Habitacion(
		habitacion_id INT PRIMARY KEY NOT NULL IDENTITY(1,1), 
		habitacion_hotel INT REFERENCES CUARENTENA2020.Hotel,
		habitacion_numero DECIMAL(18,0) NOT NULL,
		habitacion_piso DECIMAL(18,0) NOT NULL,
		habitacion_frente NVARCHAR(50) NOT NULL,
		habitacion_costo DECIMAL(18,2) NOT NULL,
		habitacion_precio DECIMAL(18,2) NOT NULL,
		habitacion_tipo INT REFERENCES CUARENTENA2020.TipoHabitacion
	)
    

	INSERT INTO CUARENTENA2020.Habitacion
		SELECT distinct
			h.hotel_id,
			HABITACION_NUMERO,
			HABITACION_PISO,
			HABITACION_FRENTE,
			HABITACION_COSTO,
			HABITACION_PRECIO,
			TIPO_HABITACION_CODIGO
		FROM gd_esquema.Maestra m
		join CUARENTENA2020.Hotel h on h.hotel_calle = m.HOTEL_CALLE and h.hotel_nro_calle = m.HOTEL_NRO_CALLE 
		where 
			HABITACION_NUMERO is not null
			and h.hotel_id is not null

----------------------------------------------------------------------------------------
    
	CREATE TABLE CUARENTENA2020.Estadia(
		estadia_codigo INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		estadia_cantidad_noches DECIMAL(18,0) NULL,
		estadia_fecha_ini DATETIME2(3) NULL,
		id_hotel INT REFERENCES CUARENTENA2020.Hotel
	)
    
	SET IDENTITY_INSERT CUARENTENA2020.Estadia ON
	INSERT INTO CUARENTENA2020.Estadia
		(
			estadia_codigo,
			estadia_cantidad_noches,
			estadia_fecha_ini,
			id_hotel
		)
		SELECT distinct
			ESTADIA_CODIGO,
			ESTADIA_CANTIDAD_NOCHES,
			ESTADIA_FECHA_INI,
			h.hotel_id
		FROM gd_esquema.Maestra m
		join cuarentena2020.Hotel h on h.hotel_calle = m.HOTEL_CALLE and h.hotel_nro_calle = m.HOTEL_NRO_CALLE
		where ESTADIA_CODIGO is not null
	SET IDENTITY_INSERT CUARENTENA2020.Estadia OFF
----------------------------------------------------------------------------------------    
	CREATE TABLE CUARENTENA2020.TipoButaca (
		tipo_butaca_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		tipo_butaca_descripcion nvarchar(255) NOT NULL
	)

	INSERT INTO CUARENTENA2020.TipoButaca 
		SELECT distinct BUTACA_TIPO 
		FROM gd_esquema.Maestra
		where BUTACA_TIPO is not null
----------------------------------------------------------------------------------------    
	CREATE TABLE CUARENTENA2020.Butaca (
		butaca_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		butaca_numero DECIMAL(18, 0),
		butaca_avion INT REFERENCES CUARENTENA2020.Avion,
		butaca_tipo INT REFERENCES CUARENTENA2020.TipoButaca
	)

	INSERT INTO CUARENTENA2020.Butaca 
		SELECT distinct 
			BUTACA_NUMERO,
			a.avion_id,
			tb.tipo_butaca_id
		FROM gd_esquema.Maestra m
		join CUARENTENA2020.Avion a on a.avion_identificador = m.AVION_IDENTIFICADOR
		join CUARENTENA2020.TipoButaca tb on tb.tipo_butaca_descripcion = m.BUTACA_TIPO

----------------------------------------------------------------------------------------    
	CREATE TABLE CUARENTENA2020.Pasaje(
		pasaje_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		pasaje_codigo DECIMAL(18, 0) NOT NULL,
		pasaje_costo DECIMAL(18, 2) NOT NULL,
		pasaje_precio DECIMAL(18, 2) NOT NULL,
		pasaje_compra_id INT REFERENCES CUARENTENA2020.CompraPasaje,
		pasaje_butaca_nro INT
	)
     
	INSERT INTO CUARENTENA2020.Pasaje 
		SELECT distinct
			PASAJE_CODIGO,
			PASAJE_COSTO,
			PASAJE_PRECIO,
			COMPRA_NUMERO,
			BUTACA_NUMERO
		FROM gd_esquema.Maestra m
		where PASAJE_CODIGO is not null

----------------------------------------------------------------------------------------    
	CREATE TABLE CUARENTENA2020.VentaPasaje(
		id_com_pas INT REFERENCES CUARENTENA2020.CompraPasaje,
		id_venta INT REFERENCES CUARENTENA2020.Venta
	)

	insert into CUARENTENA2020.VentaPasaje
		select distinct
			COMPRA_NUMERO,
			FACTURA_NRO
		from gd_esquema.Maestra m
		join CUARENTENA2020.CompraPasaje cp on cp.compra_pasaje_id = m.COMPRA_NUMERO
		where COMPRA_NUMERO is not null and FACTURA_NRO is not null

----------------------------------------------------------------------------------------
	CREATE TABLE CUARENTENA2020.CompraEstadia(
		compra_estadia_id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		compra_estadia_codigo INT REFERENCES CUARENTENA2020.Estadia
	)
	SET IDENTITY_INSERT CUARENTENA2020.CompraEstadia ON
	insert into CUARENTENA2020.CompraEstadia
		(
			compra_estadia_id,
			compra_estadia_codigo
		)
		select distinct 
			COMPRA_NUMERO, 
			ESTADIA_CODIGO
		from gd_esquema.Maestra
		where 
			COMPRA_NUMERO is not null 
			and ESTADIA_CODIGO is not null
	SET IDENTITY_INSERT CUARENTENA2020.CompraEstadia OFF

----------------------------------------------------------------------------------------
    
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
GO

--Indices 

CREATE INDEX index_avion 
ON [CUARENTENA2020].[Avion] (avion_id , avion_identificador)
GO

CREATE INDEX index_Cliente 
ON [CUARENTENA2020].[Cliente] (cliente_dni , cliente_mail)
GO

CREATE INDEX index_empresa
ON [CUARENTENA2020].[empresa] (empresa_razon_social)
GO

CREATE INDEX index_hotel
ON [CUARENTENA2020].[hotel] (hotel_cantidad_estrellas)
GO
