USE [GD1C2020]
GO
/****** Script for SelectTopNRows command from SSMS  ******/
SELECT b1.[butaca_id]
      ,b1.[butaca_avion]
      ,b1.[butaca_numero]
      ,b1.[butaca_tipo]
  FROM [GD1C2020].[CUARENTENA2020].[Butaca] b1
  join (
	select 
		b.butaca_avion,
		b.butaca_numero
	from CUARENTENA2020.Butaca b
	group by b.butaca_avion, butaca_numero
	having count(*) > 1
  ) b2 on b2.butaca_avion = b1.butaca_avion and b2.butaca_numero = b1.butaca_numero
  order by b1.butaca_avion, b1.butaca_numero