IF OBJECT_ID ( 'dbo.sensors', 'U' ) IS NOT NULL   
    DROP TABLE dbo.sensors;  
GO  
  
CREATE TABLE dbo.sensors 
    ( row int not null,
	  x int not null,
	  y int not null,
    BorS char(1) not null);  
GO  
ALTER TABLE dbo.sensors ADD CONSTRAINT
	PK_sensors PRIMARY KEY CLUSTERED 
	(row,bors
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go

set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2

select 
identity(int,0,1) id,
line
into tmp_input2
FROM OPENROWSET(BULK  '\\metcalfd\c$\adventofcode\2022\Day15\input.txt', 
                         FORMATFILE='\\metcalfd\c$\adventofcode\2022\Day15\input.fmt', firstrow=1) test

select * from tmp_input2

declare @i int = 0, @maxx int = 0, @maxy int = 0, @minx int = 1000000, @miny int = 10000000
while @i <= (select max(id) from tmp_input2)
begin
	if exists(select 1 from sys.tables where name = 'tmp_12') drop table tmp_12
	select identity(int,1,1) id, * into tmp_12 from string_split((select replace(replace(line,char(13),''),char(10),'') from tmp_input2 where id = @i),':') 
	if exists(select 1 from sys.tables where name = 'tmp_22') drop table tmp_22
	select 'S' BorS, trim(replace(value,'Sensor at ','')) value into tmp_22  from string_split((select replace(replace(value,char(13),''),char(10),'') from tmp_12 where value like 'Sensor%'),',') 
	insert into tmp_22(BorS,value)
	select 'B' BorS, trim(replace(value,' closest beacon is at ','')) value  from string_split((select replace(replace(value,char(13),''),char(10),'') from tmp_12 where value like '%closest beacon%'),',') 

	begin try
	insert into sensors(row, x,y,BorS)
	select @i, (select replace(value,'x=','') from tmp_22 where BorS = 'S' and value like 'x%') x, (select replace(value,'y=','') from tmp_22 where BorS = 'S' and value like 'y%') y, 'S' BorS
	
	insert into sensors(row, x,y,BorS)
	select @i, (select replace(value,'x=','') from tmp_22 where BorS = 'B' and value like 'x%') x, (select replace(value,'y=','') from tmp_22 where BorS = 'B' and value like 'y%') y, 'B' BorS
	end try

	begin catch

	end catch
	set @i = @i + 1
end
if exists(select 1 from sys.tables where name = 'options')
drop table options
create table options(x int not null primary key)

declare @y int = 2000000, @row int = 0, @rows int = (select max(row) from sensors), @sx int, @bx int, @sy int, @by int
while @row <= @rows
begin
	print @row
	select @sx = x, @sy = y from sensors where row = @row and BorS = 'S'
	select @bx = x, @by = y from sensors where row = @row and BorS = 'B'
	declare @distance int = abs(@sx - @bx) + abs(@sy - @by) - abs(@sy - @y), @x int 
	print @distance
	set @x = @sx - @distance
	--while @x <= @x + @distance
	--begin
	--	if (@bx <> @x or @by <> @y) insert into options(x) values(@x)
	--	set @x = @x + 1
	--end
	;with cte(x)
	as (select @x x where @x <= @sx + @distance
		union all
		select c.x + 1 x from cte c
		where c.x + 1 <= @sx + @distance
	)
		insert into options(x)
		select s.x from cte s left join options o on (s.x = o.x) where (@bx <> s.x or @by <> @y) and o.x is null group by s.x
		OPTION(maxrecursion 0)
	set @row = @row + 1
end

select count(*) part1 from options