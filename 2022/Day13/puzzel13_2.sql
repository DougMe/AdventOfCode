use aoc
go

--EXECUTE sp_configure 'show advanced options', 1;  
--GO  
---- To update the currently configured value for advanced options.  
--RECONFIGURE;  
--GO  
---- To enable the feature.  
--EXECUTE sp_configure 'xp_cmdshell', 0;  
--GO  
---- To update the currently configured value for this feature.  
--RECONFIGURE;  
--GO  

create or alter function dbo.compare(@a varchar(205), @b varchar(205))
returns int
as
begin


declare @i int, @llength int, @rlength int, @vl varchar(205), @vr varchar(205)
set @i = -1
set @llength = isnull((select max([key]) from (select [key],[value],[type] from openjson(iif(isnumeric(@a)=1,'[' + @a + ']',@a))) a),0)
set @rlength = isnull((select max([key]) from (select [key],[value],[type] from openjson(iif(isnumeric(@b)=1,'[' + @b + ']',@b))) b),0)

while @i < @llength and @i < @rlength
begin
	set @vl = (select [value] from (select [key],[value],[type] from openjson(iif(isnumeric(@a)=1,'[' + @a + ']',@a))) a where [key] = @i+1)
	set @vr = (select [value] from (select [key],[value],[type] from openjson(iif(isnumeric(@b)=1,'[' + @b + ']',@b))) b where [key] = @i+1)

	if @vl is null and @vr is not null return -1
	if @vl is not null and @vr is null return 1

	if (isnumeric(@vl) = 1 and isnumeric(@vr) = 1)
		begin
		 if @vl <> @vr return convert(int,@vl) - convert(int,@vr)
		end
	 else 
		begin
		  declare @result int
		  if ISNUMERIC(@vl) = 1 set @vl = '[' + @vl + ']'
		  if ISNUMERIC(@vr) = 1 set @vr = '[' + @vr + ']'
		  if @@NESTLEVEL < 32 set @result = dbo.compare(@vl, @vr) else return 0
		  if @result <> 0 return @result;
		end
	set @i = @i + 1
end

return len(@a) - len(@b)

end
go

if exists(select 1 from sys.tables where name = 'tmp_inputest')
drop table tmp_inputest

select 
row_number() over (order by inst) id,
replace(replace(inst,char(13),''),char(10),'') inst --,
--iif(isnumeric(SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst)))=1,convert(int,SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst))),0) reg
into tmp_inputest
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day13\input2.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day13\input.fmt', firstrow=1) test
where replace(replace(inst,char(13),''),char(10),'') <> ''


set nocount on
declare @swapped int = 1, @bubblesortn int = 1
while @swapped = 1
begin
	declare @counter int = 1, @maxcounter int = (select max(id) from tmp_inputest), @a varchar(205), @b varchar(205)
	set @swapped = 0
	while @counter < @maxcounter
	begin
	set @a = (select inst from tmp_inputest where id = @counter)
	set @b = (select inst from tmp_inputest where id = @counter + 1)
	set @counter = @counter + 1
	--select @counter, @a, @b
	if dbo.compare(@a, @b) > 0
		begin 
			set @swapped = 1
			update t set id = 1000 from tmp_inputest t where id = @counter
			update t set id = id + 1 from tmp_inputest t where id = @counter - 1
			update t set id = @counter - 1 from tmp_inputest t where id = 1000
		end
	end
	print @bubblesortn
	set @bubblesortn = @bubblesortn + 1
end

select * from tmp_inputest order by id
select min(id) * max(id) part2 from (
	select id, inst from tmp_inputest where inst in ('[2]','[6]')) c

	
	--select dbo.compare('[[[]]]','[[]]')
	--select * from openjson('[[[]]]')
	--select * from openjson('[[]]')
