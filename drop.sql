USE GD1C2020
GO

IF (SCHEMA_ID('CUARENTENA2020') IS NOT NULL) 
BEGIN
	drop table CUARENTENA2020.Estadia_X_Habitacion
	drop table CUARENTENA2020.VentaEstadia
	drop table CUARENTENA2020.CompraEstadia
	drop table CUARENTENA2020.VentaPasaje
	drop table CUARENTENA2020.Pasaje
	drop table CUARENTENA2020.Butaca
	drop table CUARENTENA2020.TipoButaca 
	drop table CUARENTENA2020.Estadia
	drop table CUARENTENA2020.Habitacion
	drop table CUARENTENA2020.TipoHabitacion
	drop table CUARENTENA2020.CompraPasaje
	drop table CUARENTENA2020.Vuelo 
	drop table CUARENTENA2020.Venta
	drop table CUARENTENA2020.Cliente
	drop table CUARENTENA2020.Compra
	drop table CUARENTENA2020.Avion 
	drop table CUARENTENA2020.Ruta
	drop table CUARENTENA2020.Ciudad 
	drop table CUARENTENA2020.Hotel 
	drop table CUARENTENA2020.Empresa 
	drop table CUARENTENA2020.Sucursal
	drop schema CUARENTENA2020
END

IF (SCHEMA_ID('CUARENTENA2020_BI') IS NOT NULL) 
BEGIN
	drop table CUARENTENA2020_BI.Hechos_Pasaje
	drop table CUARENTENA2020_BI.Hechos_Estadia
	drop table CUARENTENA2020_BI.Avion
	drop table CUARENTENA2020_BI.Ciudad
	drop table CUARENTENA2020_BI.Cliente
	drop table CUARENTENA2020_BI.Proveedor
	drop table CUARENTENA2020_BI.Ruta
	drop table CUARENTENA2020_BI.Tipo_habitacion
	drop table CUARENTENA2020_BI.Tipo_Pasaje
	drop schema CUARENTENA2020_BI
END
