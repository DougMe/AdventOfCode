
USE AOC
GO

CREATE or alter FUNCTION dbo.calctailpos
(
	-- Add the parameters for the function here
	@hx int,
	@hy int,
	@tx int,
	@ty int
)
RETURNS 
@results TABLE 
(
	-- Add the column definitions for the TABLE variable here
	tx int,
	ty int
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	if abs(@hx - @tx) > 1 or abs(@hy - @ty) > 1 
	begin
		--print 'greater than 1'
		while 1=1
		begin
		--2,0
		if @hx - @tx = 2 and @hy - @ty = 0 
			begin
			set @tx = @tx + 1
			set @ty = @ty + 0
			break;
		end
		--2,1
		if @hx - @tx = 2 and @hy - @ty = 1 
			begin
			set @tx = @tx + 1
			set @ty = @ty + 1
			break;
		end
		--2,-1
		if @hx - @tx = 2 and @hy - @ty = -1 
			begin
			set @tx = @tx + 1
			set @ty = @ty - 1
			break;
		end

		--0,2
		if @hx - @tx = 0 and @hy - @ty = 2
			begin
			set @tx = @tx + 0
			set @ty = @ty + 1
			break;
		end
		--1,2
		if @hx - @tx = 1 and @hy - @ty = 2 
			begin
			set @tx = @tx + 1
			set @ty = @ty + 1
			break;
		end
		-- -1,2
		if @hx - @tx = -1 and @hy - @ty = 2 
			begin
			set @tx = @tx - 1
			set @ty = @ty + 1
			break;
		end
		
		
		-- -2,0
		if @hx - @tx = -2 and @hy - @ty = 0 
			begin
			set @tx = @tx - 1
			set @ty = @ty + 0
			break;
		end
		-- -2,1
		if @hx - @tx = -2 and @hy - @ty = 1 
			begin
			set @tx = @tx - 1
			set @ty = @ty + 1
			break;
		end
		-- -2,-1
		if @hx - @tx = -2 and @hy - @ty = -1 
			begin
			set @tx = @tx - 1
			set @ty = @ty - 1
			break;
		end

		--0,-2
		if @hx - @tx = 0 and @hy - @ty = -2
			begin
			set @tx = @tx + 0
			set @ty = @ty - 1
			break;
		end
		--1,-2
		if @hx - @tx = 1 and @hy - @ty = -2 
			begin
			set @tx = @tx + 1
			set @ty = @ty - 1
			break;
		end
		-- -1,-2
		if @hx - @tx = -1 and @hy - @ty = -2 
			begin
			set @tx = @tx - 1
			set @ty = @ty - 1
			break;
		end
		-- 2,2
		if @hx - @tx = 2 and @hy - @ty = 2 
			begin
			set @tx = @tx + 1
			set @ty = @ty + 1
			break;
		end
		-- -2,-2
		if @hx - @tx = -2 and @hy - @ty = -2 
			begin
			set @tx = @tx - 1
			set @ty = @ty - 1
			break;
		end
		-- 2,-2
		if @hx - @tx = 2 and @hy - @ty = -2 
			begin
			set @tx = @tx + 1
			set @ty = @ty - 1
			break;
		end
		-- -2,2
		if @hx - @tx = -2 and @hy - @ty = 2 
			begin
			set @tx = @tx - 1
			set @ty = @ty + 1
			break;
		end
		break;
		end
	end
	insert into @results(tx,ty) values(@tx,@ty)
	RETURN 
END
go



set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
dir,
amt
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day09\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day09\input.fmt', firstrow=1) test

--select * from tmp_input

if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2

create table tmp_input2(id int identity(1,1), hx int not null default(0),hy int not null default(0), tx int not null default(0),ty int not null default(0),
CONSTRAINT [PK_tmp_input2] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

declare @hx int = 146, @hy int = 146, @tx int = 146, @ty int = 146, @counter int = 1, @maxcounter int
set @maxcounter = (Select max(id) from tmp_input)
insert into tmp_input2 (hx,hy,tx,ty)
values(@hx,@hy,@tx,@ty)
while @counter <= @maxcounter
begin
	declare @moveamt int, @dir nvarchar(1), @innercounter int
	set @innercounter = 1
	set @moveamt = (select amt from tmp_input where id = @counter)
	set @dir = (select dir from tmp_input where id = @counter)
	while @innercounter <= @moveamt
	begin
	--insert into tmp_input2(hx,hy,tx,ty)
	select @hx = @hx + case @dir when 'R' then 1 
								when 'D' then 0
								when 'U' then 0
								when 'L' then -1
								else 0 end,
			@hy = @hy + case @dir when 'R' then 0 
								when 'D' then -1
								when 'U' then 1
								when 'L' then 0
								else 0 end
	select @tx = tx, @ty = ty from dbo.calctailpos(@hx,@hy,@tx,@ty)

	insert into tmp_input2 (hx,hy,tx,ty)
	values(@hx,@hy,@tx,@ty)

	set @innercounter = @innercounter + 1
	end
set @counter = @counter + 1
end

select count(*) uniquetailpositionspart1 from (
select tx, ty, count(*) uniquetailpositions from tmp_input2 group by tx, ty) p1

if exists(select 1 from sys.tables where name = 'tmp_input3')
drop table tmp_input3

create table tmp_input3 (id int identity(1,1), 
						hx int default(146), hy int default(146),
						k1x int default(146), k1y int default(146),
						k2x int default(146), k2y int default(146),
						k3x int default(146), k3y int default(146),
						k4x int default(146), k4y int default(146),
						k5x int default(146), k5y int default(146),
						k6x int default(146), k6y int default(146),
						k7x int default(146), k7y int default(146),
						k8x int default(146), k8y int default(146),
						tx int default(146), ty int default(146))

declare @counter2 int, @maxcounter2 int
set @counter2 = 1
set @maxcounter2 = (Select max(id) from tmp_input)
set @hx = 146
set @hy = 146
set @tx = 146
set @ty = 146
declare @k1x int = 146, @k1y int = 146,
@k2x int = 146, @k2y int = 146,
@k3x int = 146, @k3y int = 146,
@k4x int = 146, @k4y int = 146,
@k5x int = 146, @k5y int = 146,
@k6x int = 146, @k6y int = 146,
@k7x int = 146, @k7y int = 146,
@k8x int = 146, @k8y int = 146

insert into tmp_input3(hx,hy,k1x,k1y,k2x,k2y,k3x,k3y,k4x,k4y,k5x,k5y,k6x,k6y,k7x,k7y,k8x,k8y,tx,ty)
values(@hx,@hy
,@k1x,@k1y
,@k2x,@k2y
,@k3x,@k3y
,@k4x,@k4y
,@k5x,@k5y
,@k6x,@k6y
,@k7x,@k7y
,@k8x,@k8y
,@tx, @ty)
while @counter2 <= @maxcounter2
begin
	set @innercounter = 1
	set @moveamt = (select amt from tmp_input where id = @counter2)
	set @dir = (select dir from tmp_input where id = @counter2)
	while @innercounter <= @moveamt
	begin
	 
	select @hx = @hx + case @dir when 'R' then 1 
								when 'D' then 0
								when 'U' then 0
								when 'L' then -1
								else 0 end,
			@hy = @hy + case @dir when 'R' then 0 
								when 'D' then -1
								when 'U' then 1
								when 'L' then 0
								else 0 end
	select @k1x = tx, @k1y = ty from dbo.calctailpos(@hx,@hy,@k1x,@k1y)
	select @k2x = tx, @k2y = ty from dbo.calctailpos(@k1x,@k1y,@k2x,@k2y)
	select @k3x = tx, @k3y = ty from dbo.calctailpos(@k2x,@k2y,@k3x,@k3y)
	select @k4x = tx, @k4y = ty from dbo.calctailpos(@k3x,@k3y,@k4x,@k4y)
	select @k5x = tx, @k5y = ty from dbo.calctailpos(@k4x,@k4y,@k5x,@k5y)
	select @k6x = tx, @k6y = ty from dbo.calctailpos(@k5x,@k5y,@k6x,@k6y)
	select @k7x = tx, @k7y = ty from dbo.calctailpos(@k6x,@k6y,@k7x,@k7y)
	select @k8x = tx, @k8y = ty from dbo.calctailpos(@k7x,@k7y,@k8x,@k8y)
	select @tx = tx, @ty = ty from dbo.calctailpos(@k8x,@k8y,@tx,@ty)

	insert into tmp_input3(hx,hy,k1x,k1y,k2x,k2y,k3x,k3y,k4x,k4y,k5x,k5y,k6x,k6y,k7x,k7y,k8x,k8y,tx,ty)
	values(@hx,@hy
	,@k1x,@k1y
	,@k2x,@k2y
	,@k3x,@k3y
	,@k4x,@k4y
	,@k5x,@k5y
	,@k6x,@k6y
	,@k7x,@k7y
	,@k8x,@k8y
	,@tx, @ty)

	set @innercounter = @innercounter + 1
	end

set @counter2 = @counter2 + 1
end

select count(*) uniquetailpositionspart2 from (
select tx, ty, count(*) uniquetailpositions from tmp_input3 group by tx, ty) p2

select min(hx) hxmin, max(hx) hxmax, min(hy) hymin, max(hy) hymax, min(tx) txmin, max(tx) txmax, min(ty) tymin, max(ty) tymax
from tmp_input3

---fun addtion plot the rope paths spatially----

if exists(select 1 from sys.tables where name = 'tmp_input4')
drop table tmp_input4

create table tmp_input4(id int identity(1,1), gg GEOMETRY)

declare @counter3 int, @maxcounter3 int
set @counter3 = 7000
set @maxcounter3 = (select max(id) from tmp_input3)

while @counter3 <= @maxcounter3
begin
insert into tmp_input4(gg)
values((select geometry::STGeomFromText('MULTIPOINT((' + convert(varchar(3),hx) + ' ' + convert(varchar(3),hy) + '),(' +
	convert(varchar(3),k1x) + ' ' + convert(varchar(3),k1y)  + '),(' +
	convert(varchar(3),k2x) + ' ' + convert(varchar(3),k2y)  + '),(' +
	convert(varchar(3),k3x) + ' ' + convert(varchar(3),k3y)  + '),(' +
	convert(varchar(3),k4x) + ' ' + convert(varchar(3),k4y)  + '),(' +
	convert(varchar(3),k5x) + ' ' + convert(varchar(3),k5y)  + '),(' +
	convert(varchar(3),k6x) + ' ' + convert(varchar(3),k6y)  + '),(' +
	convert(varchar(3),k7x) + ' ' + convert(varchar(3),k7y)  + '),(' +
	convert(varchar(3),k8x) + ' ' + convert(varchar(3),k8y)  + '),(' +
	convert(varchar(3),tx) + ' ' + convert(varchar(3),ty)+ '))', 0) 
	from tmp_input3 where id = @counter3))

set @counter3 = @counter3 + 1
end

select * from tmp_input4