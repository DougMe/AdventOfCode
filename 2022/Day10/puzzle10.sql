
USE AOC
GO


set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
inst,
iif(isnumeric(SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst)))=1,convert(int,SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst))),0) reg
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day10\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day10\input.fmt', firstrow=1) test

update tmp_input set reg  = 1 where id = 1
if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2


	select t.id, t.inst, t.reg, sum(iif(left(t.inst,4) = 'addx',2,1)) over (order by t.id)  cycle,sum(reg) over (order by t.id) total
	into tmp_input2
	from tmp_input t 
	
	select ((select sum(reg) from tmp_input2 where cycle < 20) * 20) +
	((select sum(reg) from tmp_input2 where cycle < 60) * 60) +
	((select sum(reg) from tmp_input2 where cycle < 100) * 100) +
	((select sum(reg) from tmp_input2 where cycle < 140) * 140) +
	((select sum(reg) from tmp_input2 where cycle < 	180) * 180) +
	((select sum(reg) from tmp_input2 where cycle < 220) * 220 ) part1
	
	if exists(select 1 from sys.tables where name = 'tmp_input3')
drop table tmp_input3

create table tmp_input3(cycle int not null, reg int, inst int)

	declare @counter int, @maxcounter int, @reg int, @inst varchar(4), @cycle int, @newreg int
	set @counter = 1
	set @cycle = 1
	set @reg = 0
	set @maxcounter = (select max(id) from tmp_input)
	while @counter <= @maxcounter
	begin
	set @newreg = (select reg from tmp_input where id = @counter)
		
	if @newreg <> 0 and @counter > 1
	begin
		insert into tmp_input3(cycle,reg,inst)
		values(@cycle,@reg,@newreg)
		set @cycle = @cycle + 1
		insert into tmp_input3(cycle,reg,inst)
		values (@cycle, @reg, @newreg)
	    set @cycle = @cycle + 1
			set @reg = @reg + @newreg
	
	end
	else 
	begin
		set @reg = @reg + @newreg
		insert into tmp_input3(cycle,reg,inst)
		values (@cycle, @reg, @newreg)
	    set @cycle = @cycle +1
	end

	set @counter = @counter + 1
	end

	select ((select reg from tmp_input3 where cycle = 20) * 20) +
	((select reg from tmp_input3 where cycle = 60) * 60) +
	((select reg from tmp_input3 where cycle = 100) * 100) +
	((select reg from tmp_input3 where cycle = 140) * 140) +
	((select reg from tmp_input3 where cycle = 180) * 180) +
	((select reg from tmp_input3 where cycle = 220) * 220) part1

		if exists(select 1 from sys.tables where name = 'tmp_input4')
drop table tmp_input4

	select cycle, reg, pixelx, (sum(iif(pixelx = 0, 1, 0)) over (order by cycle) - 1) * -1 pixely, iif(pixelx between (reg - 1) and (reg + 1), 1, 0) pixelon  
	into tmp_input4
	from (
	select *, (row_number() over (order by cycle) - 1) % 40 pixelx from tmp_input3) crt

	--select * from tmp_input4

		if exists(select 1 from sys.tables where name = 'tmp_input5')
drop table tmp_input5

	create table tmp_input5(id int identity(1,1), label varchar(50), gg geometry)

	insert into tmp_input5(label,gg)
	select 'Black','POLYGON((' + convert(varchar(5),pixelx) + '.0 ' + convert(varchar(5),pixely) + '.0, ' 
											+ convert(varchar(5),pixelx) + '.5 ' + convert(varchar(3),pixely) + '.0, ' 
											+ convert(varchar(5),pixelx) + '.5 ' + convert(varchar(5),pixely) + '.5, ' 
											+ convert(varchar(3),pixelx) + '.0 ' + convert(varchar(5),pixely) + '.5, '
											 + convert(varchar(5),pixelx) + '.0 ' + convert(varchar(5),pixely) + '.0))'  gg
	from tmp_input4 where pixelon = 1

	--insert into tmp_input5(label,gg)
	--select 'Yellow','POLYGON((' + convert(varchar(5),pixelx) + '.0 ' + convert(varchar(5),pixely) + '.0, ' 
	--										+ convert(varchar(5),pixelx) + '.5 ' + convert(varchar(3),pixely) + '.0, ' 
	--										+ convert(varchar(5),pixelx) + '.5 ' + convert(varchar(5),pixely) + '.5, ' 
	--										+ convert(varchar(3),pixelx) + '.0 ' + convert(varchar(5),pixely) + '.5, '
	--										 + convert(varchar(5),pixelx) + '.0 ' + convert(varchar(5),pixely) + '.0))'  gg
	--from tmp_input4 where pixelon = 0

	select * from tmp_input5 order by id
