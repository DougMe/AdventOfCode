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
if exists(select 1 from sys.tables where name = 'ranges')
drop table ranges
create table ranges(id int identity(1,1),xmin int not null, xmax int not null)
ALTER TABLE dbo.ranges ADD CONSTRAINT
	PK_ranges PRIMARY KEY CLUSTERED 
	(xmin, xmax
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

declare @y int = 0, @row int = 0, @rows int = (select max(row) from sensors), @sx int, @bx int, @sy int, @by int
set @maxy = 4000000
while @y <= @maxy
begin
	truncate table dbo.ranges
	if @y % 100000 = 0 print @y
	insert into ranges(xmin, xmax)
	select sx - distance xmin, sx + distance xmax from (
	select abs(sx - bx) + abs(sy - [by]) - abs(sy - @y) distance, sx, bx from ( 
	select row, x sx,  y sy from sensors where BorS = 'S') s join (
	select row, x bx,  y [by] from sensors where BorS = 'B') b on (s.row = b.row)
	where abs(sx - bx) + abs(sy - [by]) - abs(sy - @y) >= 0) main
	union
	select bx xmin, bx xmax from (
	select row, x bx,  y [by] from sensors where BorS = 'B') b
	where [by] = @y
	order by xmin
	declare @minid int, @maxid int
	declare @guess int = 0
	set @minid = 1
	set @maxid = (Select max(id) from ranges)
	while @minid <= @maxid
	begin
		set  @guess = isnull((select iif(xmax is null, @guess, xmax + 1) from ranges where id = @minid and @guess between xmin and xmax),@guess)
		set @minid = @minid + 1
	end
	if @guess <= @maxy break;
	set @y = @y + 1
end

--select xmin, xmax from ranges where 0 between xmin and xmax order by xmin desc
--select * from ranges
select convert(bigint, @guess) * convert(bigint, 4000000) + convert(bigint,@y) part2, @guess guess, @maxy limit, @y row
