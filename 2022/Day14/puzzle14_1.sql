IF OBJECT_ID ( 'dbo.cave', 'U' ) IS NOT NULL   
    DROP TABLE dbo.cave;  
GO  
  
CREATE TABLE dbo.cave 
    ( x int not null,
	  y int not null,
    point char(1) default('.') );  
GO  
ALTER TABLE dbo.cave ADD CONSTRAINT
	PK_cave PRIMARY KEY CLUSTERED 
	(
	x,
	y
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
go

set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2

select 
identity(int,0,1) id,
line
into tmp_input2
FROM OPENROWSET(BULK  '\\metcalfd\c$\adventofcode\2022\Day14\input.txt', 
                         FORMATFILE='\\metcalfd\c$\adventofcode\2022\Day14\input.fmt', firstrow=1) test
--select * from tmp_input2
declare @i int = 0, @maxx int = 0, @maxy int = 0, @minx int = 1000, @miny int = 1000
while @i <= (select max(id) from tmp_input2)
begin
	if exists(select 1 from sys.tables where name = 'tmp_12') drop table tmp_12
	select identity(int,1,1) id, * into tmp_12 from string_split((select replace(replace(replace(line,' -> ','|'),char(13),''),char(10),'') from tmp_input2 where id = @i),'|') 
	if exists(select 1 from sys.tables where name = 'tmp_22') drop table tmp_22
	select t1.id, t1.value valuel, t2.value valuer into tmp_22
	from tmp_12 t1  join tmp_12 t2 on (t1.id + 1 = t2.id)

	/*
	if exists(select 1 from sys.tables where name = 'tmp_12') drop table tmp_12
	select identity(int,1,1) id, * into tmp_12 from string_split((select replace(replace(replace(line,' -> ','|'),char(13),''),char(10),'') from tmp_input2 where id = 48),'|') 
	if exists(select 1 from sys.tables where name = 'tmp_22') drop table tmp_22
	select t1.id, t1.value valuel, t2.value valuer into tmp_22
	from tmp_12 t1  join tmp_12 t2 on (t1.id + 1 = t2.id)
	select * from tmp_12
	select * from tmp_22
	*/

	declare @numline int, @numlines int
	set @numline = 1
	set @numlines = (select max(id) from tmp_22)
	while @numline <= @numlines
	begin
		declare @startx int, @starty int, @endx int, @endy int

		select @startx = convert(int,left(valuel,charindex(',',valuel)-1)), @starty = substring(valuel,charindex(',',valuel)+1,3) ,  @endx = convert(int,left(valuer,charindex(',',valuer)-1)), @endy = substring(valuer,charindex(',',valuer)+1,3)  from tmp_22 where id = @numline
		
		--select valuel, @startx startx, @starty starty, valuer,  @endx endx, @endy endy from tmp_22 where id = 3
		if @startx > @maxx set @maxx = @startx
		if @startx < @minx set @minx = @startx
		if @endx > @maxx set @maxx = @endx
		if @endx < @minx set @minx = @endx
		if @starty > @maxy set @maxy = @starty
		if @starty < @miny set @miny = @starty
		if @endy > @maxy set @maxy = @endy
		if @endy < @miny set @miny = @endy
		declare @sql varchar(max)
		if @endx > @startx  --horizontal line
		begin
			while @startx <= @endx
			begin
				set @sql = convert(varchar(max),(
				select  'insert into cave(x,y,point) values(' + convert(varchar(3),@startx) + ',' + convert(varchar(3),@starty) + ',''#'')' 
				   for xml path('')))
				begin try
				exec(@sql)
				end try
				begin catch
				--print 'already exists'
				end catch
				set @startx = @startx + 1
			end
		end
		else 
			begin
				if @endx < @startx  --horizontal line
				begin
					while @startx >= @endx
					begin
						set @sql = convert(varchar(max),(
						select  'insert into cave(x,y,point) values(' + convert(varchar(3),@startx) + ',' + convert(varchar(3),@starty) + ',''#'')' 
						   for xml path('')))
						begin try
						exec(@sql)
						end try
						begin catch
						--print 'already exists'
						end catch
						set @startx = @startx - 1
					end
				end
			end
		if @starty < @endy  --vertical line
		begin
			while @starty <= @endy
			begin
				set @sql = convert(varchar(max),(
				select  'insert into cave(x,y,point) values(' + convert(varchar(3),@startx) + ',' + convert(varchar(3),@starty) + ',''#'')' 
				   for xml path('')))
				begin try
				exec(@sql)
				end try
				begin catch
				--print 'already exists'
				end catch
				set @starty = @starty + 1
			end
		end
		else
		begin
			if @starty > @endy  --vertical line
			begin
				while @starty >= @endy
				begin
					set @sql = convert(varchar(max),(
					select  'insert into cave(x,y,point) values(' + convert(varchar(3),@startx) + ',' + convert(varchar(3),@starty) + ',''#'')' 
					   for xml path('')))
					begin try
					exec(@sql)
					end try
					begin catch
				
					end catch
					set @starty = @starty - 1
				end
			end
		end
		set @numline = @numline + 1
	end
	set @i = @i + 1
end
select @maxx, @maxy, @minx, @miny



declare @x int = 0, @y int = 0
while @x <= @maxx
begin
	set @y = 0
	print @x
	while @y <= 200
	begin
		insert into cave(x,y,point)
		select @x, @y, '.' point where not exists(
		select 1 from cave where x = @x and y = @y)
		set @y = @y + 1
	end
	set @x = @x + 1
end

select min(x), min(y), max(x), max(y) from cave
where point = '#'

select o.y,
	STUFF((select ' ' + point from cave i
	where i.y = o.y and i.x between 443 and 507
	for xml path(''),type).value(N'.[1]', N'nvarchar(max)'), 1, 2, N'') row
from cave o
where o.y between 0 and 178
group by o.y
order by o.y

declare @count int = 0;

declare @resting bit = 1;
while exists(select * from cave where x = 0 and y = 178 and point = '.') and @resting=1
begin
    declare @sandx int = 500,  @sandy int = 0
    set @resting = 0;
    while exists(select 1 from cave where y = @sandy + 1 and @resting = 0) 
	begin
		if exists (select 1 from cave where y = @sandy + 1 and x = @sandx and point = '.') 
			 set @sandy = @sandy +  1
		else 
			begin
				if exists(select 1 from cave where y = @sandy + 1 and x = @sandx - 1  and point = '.') 
					begin
						set @sandy = @sandy + 1;
						set @sandx = @sandx - 1;
					end
				else 
					begin
						if exists(select 1 from cave where y = @sandy + 1 and x = @sandx + 1 and point = '.') 
							begin
								set @sandy = @sandy + 1;
								set @sandx = @sandx + 1;
							end
						else 
							begin
								update cave set point = 'o' where x = @sandx and y = @sandy;
								set @resting = 1;
								set @count = @count + 1;
							end
					end
			end
	end
end

select o.y,
	STUFF((select ' ' + point from cave i
	where i.y = o.y and i.x between 443 and 507
	for xml path(''),type).value(N'.[1]', N'nvarchar(max)'), 1, 2, N'') row
from cave o
where o.y between 0 and 178
group by o.y
order by o.y

select * from cave

select count(*) part1 from cave where point = 'o'



