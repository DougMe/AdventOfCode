
USE AOC
GO

if exists(select 1 from sysobjects where name = 'split2')
drop function dbo.split2
go

CREATE FUNCTION [dbo].[split2]
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
if exists(select 1 from sys.tables where name = 'ttmp_input')
drop table ttmp_input

select 
identity(int,1,1) id,
inst
into ttmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day11\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day11\input.fmt', firstrow=1) test

if exists(select 1 from sys.tables where name = 'ttmp_input2')
drop table ttmp_input2

select id, sum(iif(left(inst,6)='Monkey',1,0)) over (order by id) monkeyn,
inst 
into ttmp_input2
from ttmp_input

if exists(select 1 from sys.tables where name = 'ttmp_input3')
drop table ttmp_input3
select identity(int,1,1) id, monkeyn, row_number() over (partition by monkeyn order by id) step, inst into ttmp_input3 
from ttmp_input2 where inst is not null
order by id

if not exists(select 1 from sys.table_types where name = 'monkey_inmem')
CREATE TYPE [monkey_inmem] AS TABLE(

    [monkeyn] [int] NOT NULL,
	[items] [varchar](500) NULL,
	[operation] [varchar](20) NULL,
	[test] [varchar](2) NULL,
	[trueresult] [varchar](1) NULL,
	[falseresult] [varchar](1) NULL,
	[numitems] [bigint] NOT NULL default(0),

      INDEX [IX_monkeyn] hash ([monkeyn])

            WITH ( BUCKET_COUNT = 8)  

)

WITH ( MEMORY_OPTIMIZED = ON )

declare @ttmp_input4 as monkey_inmem




declare @counter int, @maxcounter int, @monkeyn int
set @counter = 1
set @monkeyn = 1
set @maxcounter = (select max(id) from ttmp_input3)
while @counter <= @maxcounter
begin

insert into @ttmp_input4(monkeyn,items,operation,test,trueresult, falseresult)
select @monkeyn-1 monkeyn, 
	replace((select replace(replace(inst,char(13),''),char(10),'') from ttmp_input3 where monkeyn = @monkeyn and step = 2),'  Starting items: ','') items,
	replace((select replace(replace(inst,char(13),''),char(10),'') from ttmp_input3 where monkeyn = @monkeyn and step = 3),'  Operation: new =','') operation,
	ltrim(right((select replace(replace(inst,char(13),''),char(10),'') from ttmp_input3 where monkeyn = @monkeyn and step = 4),2)) test,
	right((select replace(replace(inst,char(13),''),char(10),'') from ttmp_input3 where monkeyn = @monkeyn and step = 5),1) trueresult,
	right((select replace(replace(inst,char(13),''),char(10),'') from ttmp_input3 where monkeyn = @monkeyn and step = 6),1) falseresult
	
set @counter = @counter + 6
set @monkeyn = @monkeyn + 1
end
delete from @ttmp_input4 where items is null

declare @rounds int = 10000, @round int = 1, @monkey int = 0, @maxmonkeys int
set @maxmonkeys = (select max(monkeyn) from @ttmp_input4)


select * from @ttmp_input4

declare @mods bigint, @c int
set @mods = 1
set @c = 0
while @c<= (select max(monkeyn) from @ttmp_input4)
begin
set @mods = @mods * (select test from @ttmp_input4 where monkeyn = @c)
set @c  = @c + 1
end
print 'mods = ' + convert(varchar(10),@mods)
while @round <= @rounds
begin
	if @round % 1000 = 0 print 'round=' + convert(varchar(5),@round)
	set @monkey = 0
	while @monkey <= @maxmonkeys
	begin
	--print 'monkey=' + convert(varchar(1),@monkey)
	declare @itemn int = 1, @maxitems int, @items varchar(max), @truemonkey int, @falsemonkey int, @op varchar(20), @test int
	declare @worries as table(id int, val bigint)
	delete from @worries
	select @items = items, @truemonkey = trueresult, @falsemonkey = falseresult, @op = operation, @test = test from @ttmp_input4 where monkeyn = @monkey
	--print 'item=' + @items
	if @items <> ''
	begin
	insert into @worries(id, val) select id, ltrim(val) from dbo.split2(@items,',')
	set @maxitems = isnull((select max(id) from @worries),0)
	
	while @itemn <= @maxitems
	begin
		declare @item bigint, @sql varchar(max), @worry varchar(20), @worryn bigint
		declare @operation as table(val bigint)
		delete from @operation
		set @item = (select val from @worries where id = @itemn)
		--print 'item=' + convert(varchar(15),@item)
		set @sql = 'select ' + replace(@op,'old', 'convert(bigint,' + convert(varchar(10),@item) + ')')
		--print 'begin insert'
		insert into @operation(val) exec(@sql)
		--print 'end insert'
		set @worryn = (select val from @operation) % @mods
		--declare @str1 varchar(10), @str2 varchar(10)
		--set @str1 = convert(varchar(10),(select val from @operation)) 
		--set @str2 = ' % ' + convert(Varchar(10),@mods)
		--print @str1 + @str2
		--print @worryn
		--set @worryn = convert(int,SUBSTRING(@worry, 1, charindex('.',@worry)-1))
		if @worryn % @test = 0
		update @ttmp_input4 set items = iif(ltrim(rtrim(items))='',items,items+', ') + convert(varchar(15),@worryn) where monkeyn = @truemonkey
		else
		update @ttmp_input4 set items = iif(ltrim(rtrim(items))='',items,items+', ') + convert(varchar(15),@worryn) where monkeyn = @falsemonkey
		update @ttmp_input4 set numitems = numitems + 1 from @ttmp_input4 where monkeyn = @monkey
		set @itemn = @itemn + 1
	end
	
	update @ttmp_input4 set items = '' where monkeyn = @monkey
	end
	set @monkey = @monkey + 1
	end
set @round = @round + 1
end

if exists(select 1 from sys.tables where name = 'ttmp_input4')
drop table ttmp_input4

select * into ttmp_input4 from @ttmp_input4

select convert(bigint,max(top1)) * convert(bigint,max(top2)) part2 from (
select (select numitems where id =1) top1,(select numitems where id =2) top2 from (
select top 2 row_number() over (order by numitems desc) id, numitems from ttmp_input4) final ) a

