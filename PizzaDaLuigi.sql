create database PizzeriaDaLuigi

create table pizza
(
	codice int identity(1,1),
	Nome varchar(25) not null,
	Prezzo numeric(4,2) not null,
	constraint [PK_Pizza] primary key (codice),
	constraint [chk_prezzo] check (prezzo > 0)
)
--drop table pizza
create table Ingrediente
(
	codice int identity(1,1),
	nome varchar(25) not null,
	costo numeric(3,2) not null,
	scorte int not null,
	constraint [PK_Ingrediente] primary key (codice),
	constraint [chk_costo] check (costo > 0)
)
--drop table IngredientePizza
create table IngredientePizza
(
	CodicePizza int,
	CodiceIngrediente int,
	constraint [FK_Pizza] foreign key (CodicePizza) 
	references pizza(codice)
	on delete cascade
	on update cascade,
	constraint [FK_Ingrediente] foreign key (CodiceIngrediente)
	references Ingrediente(codice)
	on delete cascade
	on update cascade
)

--indice
create index nomePizza_NDX
on Pizza (Codice)
create index ingredinete_NDX
on Ingrediente (Codice)

create unique index pizza_ndx
on pizza(codice, nome, prezzo)

create unique index ingrediente_ndx
on Ingrediente (codice, nome, costo,scorte)

insert into pizza values
('Margherita', 5),
('Bufala',7),
('Diavola',6),
('Quattro Stagioni',6.5),
('Porcini',7),
('Dionis',7),
('Ortolana',8),
('Patate e Salsiccia',6),
('Pomodori',6),
('Quattro Formaggi',7.50),
('Caprese',7.50),
('Zeus',7.50)

insert into Ingrediente values
('Farina',0.5,1000),
('Pomodoro', 0.2,2000 ),
('Mozzarella',0.7 ,3032 ),
('Mozzarella di Bufala',1 ,200 ),
('Spianata Piccante', 1.5,11 ),
('Funghi',1 , 244),
('Carciofi',2 ,23 ),
('Cotto',1 , 324),
('Olive',0.2,4332 ),
('Funghi Porcini',2 ,33 ),
('Stracchino',1 , 322),
('Speck', 0.9, 224),
('Rucola',1 ,433 ),
('Grana',0.5 ,432 ),
('Verdure di stagione', 1, 4343),
('Patate', 0.3,342 ),
('Salciccia', 2, 67),
('Pomodorini',1 ,324 ),
('Ricotta',4 , 453),
('Provola',5 ,33 ),
('Gorgonzola',6 ,33 ),
('Pomodoro Fresco',1 ,455 ),
('Basilico',0.1 , 324),
('Bresaola',3 , 353)

create procedure [InsertPizza]
@Codice int,
@Nome varchar(25),
@Prezzo numeric(4,2)
as begin
insert into pizza(codice,nome,prezzo)
values(@codice, @nome, @prezzo)
end
execute InsertPizza @Codice=1,@Nome='Margerita',@Prezzo= 6.5
--
create procedure [InsertIngrediente]
@codice int,
@nome varchar(25),
@Costo numeric(3,2),
@Scorte int
as 
begin
insert into Ingrediente(Codice,nome,costo,scorte)
values (@codice,@nome,@Costo,@Scorte)
end
execute [InsertIngrediente] 1,'Pomodoro',1,122
--
create procedure [InsertIngredientePizza]
@CodicePizza int,
@CodiceIngrediente int
as
begin insert into IngredientePizza (CodiceIngrediente,CodicePizza)
values (@CodiceIngrediente,@CodicePizza)
end

execute [InsertIngredientePizza]@codicePizza= 1, @codiceIngrediente =1
--

select p.Nome, i.nome
from pizza p
 join IngredientePizza ipz
on p.codice = ipz.CodicePizza
join Ingrediente i
on ipz.CodiceIngrediente = i.codice
where p.codice = 11
--

create procedure DeletePizzaIngrediente
@CodicePizza int ,
@CodiceIngrediente int 
as begin
begin transaction
begin try
delete from IngredientePizza
where CodicePizza = @CodicePizza
and CodiceIngrediente = @CodiceIngrediente
IF @@ERROR > 0
		ROLLBACK TRANSACTION

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT ERROR_LINE(), ERROR_MESSAGE()
		ROLLBACK TRANSACTION 
	END CATCH
END
exec DeletePizzaIngrediente 1,1

--lista pizze ordine alfabetico
create function PizzeAlfabetico()
returns table
as return
select nome, Prezzo 
from pizza


select * from dbo.PizzeAlfabetico()
order by Nome asc

--lista pizze (n,p) contentente ingrediente (p: codice ingrediente)
create function PizzeConIngrediente(@ingrediente int)
returns table
as return
select p.Nome, p.Prezzo
from pizza p
 join IngredientePizza ipz
on p.codice = ipz.CodicePizza
and
ipz.CodiceIngrediente = @ingrediente


select * from dbo.PizzeConIngrediente(2)
-- lista pizze che non contiene un certo ingrediente(p: codice ingrediente)
create function PizzeSenzaIngrediente(@ingrediente int )
returns table
as return(
select p.Nome, p.Prezzo
from pizza p
except
select  p.Nome, p.Prezzo
from pizza p
join IngredientePizza ipz
on p.codice = ipz.CodicePizza
and
ipz.CodiceIngrediente = @ingrediente
)


select * from dbo.PizzeSenzaIngrediente(2)

-- calcolo numero pizze conteneti un ingrediente (p: codice ingrediente)
--TODO
create function PizzeCalcoloConIngrediente(@ingrediente int)
returns int
as 
begin
declare @result int
select @result = count(distinct nome)
from pizza p
join IngredientePizza ipz
on p.codice = ipz.CodicePizza
and
 ipz.CodiceIngrediente = @ingrediente
return @result
end

select dbo.PizzeCalcoloConIngrediente(1) as value

-- calcolo numero pizze non contenenti un ingrediente (p: codice ingrediente)
create function PizzeCalcoloSenzaIngrediente(@ingrediente int)
returns int
as 
begin
declare @result int
select @result = count(*)
from dbo.PizzeSenzaIngrediente(@ingrediente)

return @result
end

select dbo.PizzeCalcoloSenzaIngrediente(3) as value
--check up
-- calcolo numero ingredienti contenuti in una pizza (p: codice pizza)
create function NumeroIngredientiPizza(@codicePizza int )
RETURNS INT
AS
BEGIN
declare @result int
select @result = count(*)
from pizza p
join IngredientePizza ipz
on p.codice = ipz.CodicePizza
and
ipz.CodiceIngrediente = @codicePizza
return @result
END

select dbo.NumeroIngredientiPizza(1) as value
--Realizzare una view che rappresenta il menù con tutte le pizze 

create view [MenuPizze] as (
Select p.nome,i.nome as'Ingrediente', p.prezzo as 'Prezzo Pizza'
FROM Pizza p
	JOIN IngredientePizza ipz
	ON ipz.codicepizza =p.Codice
	JOIN Ingrediente i
	ON i.Codice = ipz.CodiceIngrediente
);
SELECT * FROM MenuPizze

