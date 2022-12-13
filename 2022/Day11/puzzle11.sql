
USE AOC
GO

if exists(select 1 from sysobjects where name = 'split')
drop function dbo.split
go

CREATE FUNCTION [dbo].[split]
    (
      @delimited NVARCHAR(MAX),
      @delimiter NVARCHAR(100)
    ) 
 RETURNS @t TABLE (id INT IDENTITY(1,1), val NVARCHAR(MAX))
AS
BEGIN
  DECLARE @xml XML
  SET @xml = N'<t>' + REPLACE(@delimited,@delimiter,'</t><t>') + '</t>'

  INSERT INTO @t(val)
  SELECT  r.value('.','varchar(MAX)') as item
  FROM  @xml.nodes('/t') as records(r)
  RETURN
END
go


set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
inst
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day11\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day11\input.fmt', firstrow=1) test


if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2

select id, sum(iif(left(inst,6)='Monkey',1,0)) over (order by id) monkeyn,
inst 
into tmp_input2
from tmp_input

if exists(select 1 from sys.tables where name = 'tmp_input3')
drop table tmp_input3
select identity(int,1,1) id, monkeyn, row_number() over (partition by monkeyn order by id) step, inst into tmp_input3 
from tmp_input2 where inst is not null
order by id

if exists(select 1 from sys.tables where name = 'tmp_input4')
drop table tmp_input4

declare @counter int, @maxcounter int, @monkeyn int
set @counter = 1
set @monkeyn = 1
set @maxcounter = (select max(id) from tmp_input3)
while @counter <= @maxcounter
begin
if not exists(select 1 from sys.tables where name = 'tmp_input4')
select identity(int,1,1) id, @monkeyn-1 monkeyn,
	replace((select  replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 2),'  Starting items: ','') items,
	replace((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 3),'  Operation: new =','') operation,
	ltrim(right((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 4),2)) test,
	right((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 5),1) trueresult,
	right((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 6),1) falseresult
	into tmp_input4

else
insert into tmp_input4(monkeyn,items,operation,test,trueresult, falseresult)
select @monkeyn-1 monkeyn, 
	replace((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 2),'  Starting items: ','') items,
	replace((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 3),'  Operation: new =','') operation,
	ltrim(right((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 4),2)) test,
	right((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 5),1) trueresult,
	right((select replace(replace(inst,char(13),''),char(10),'') from tmp_input3 where monkeyn = @monkeyn and step = 6),1) falseresult
	
set @counter = @counter + 6
set @monkeyn = @monkeyn + 1
end

declare @rounds int = 20, @round int = 1, @monkey int = 0, @maxmonkeys int
set @maxmonkeys = (select max(monkeyn) from tmp_input4)

alter table tmp_input4 add numitems int not null default(0)
delete from tmp_input4 where items is null
select * from tmp_input4

while @round <= @rounds
begin
	set @monkey = 0
	while @monkey <= @maxmonkeys
	begin
	declare @itemn int = 1, @maxitems int, @items varchar(200)
	declare @worries as table(id int, val int)
	delete from @worries
	set @items = (select items from tmp_input4 where monkeyn = @monkey)
	print 'item=' + @items
	if @items <> ''
	insert into @worries(id, val) select id, val from dbo.split(@items,',')
	set @maxitems = isnull((select max(id) from @worries),0)
	
	while @itemn <= @maxitems
	begin
		declare @item int, @sql varchar(max), @worry varchar(20), @worryn int
		declare @operation as table(val int)
		delete from @operation
		set @item = (select val from @worries where id = @itemn)
		print 'item=' + convert(varchar(10),@item)
		set @sql = (select 'select ' + replace(operation,'old', @item) from tmp_input4 where monkeyn = @monkey)
		insert into @operation(val) exec(@sql)
		set @worry = convert(varchar(20),(select val from @operation)/3.0)
		set @worryn = convert(int,SUBSTRING(@worry, 1, charindex('.',@worry)-1))
		if @worryn % (select test from tmp_input4 where monkeyn = @monkey) = 0
		update tmp_input4 set items = iif(ltrim(rtrim(items))='',items,items+', ') + convert(varchar(10),@worryn) where monkeyn = (select trueresult from tmp_input4 where monkeyn = @monkey)
		else
		update tmp_input4 set items = iif(ltrim(rtrim(items))='',items,items+', ') + convert(varchar(10),@worryn) where monkeyn = (select falseresult from tmp_input4 where monkeyn = @monkey)
		update tmp_input4 set numitems = numitems + 1 from tmp_input4 where monkeyn = @monkey
		set @itemn = @itemn + 1
	end
	update tmp_input4 set items = '' where monkeyn = @monkey
	set @monkey = @monkey + 1
	end
set @round = @round + 1
end

select max(top1) * max(top2) part1 from (
select (select numitems where id =1) top1,(select numitems where id =2) top2 from (
select top 2 row_number() over (order by numitems desc) id, numitems from tmp_input4) final ) a

