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

if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
replace(replace(inst,char(13),''),char(10),'') inst --,
--iif(isnumeric(SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst)))=1,convert(int,SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst))),0) reg
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day13\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day13\input.fmt', firstrow=1) test
where replace(replace(inst,char(13),''),char(10),'') <> ''

if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2

select identity(int,1,1) id, l1.inst instleft, l2.inst instright, 1 correct
into tmp_input2
from (
select row_number() over (order by id) id, inst from (		
select id, iif(id % 2=0, 2,1) item, inst from tmp_input) list1
where item = 1) l1 join 

(select row_number() over (order by id) id, inst from (		
select id, iif(id % 2=0, 2,1) item, inst from tmp_input) list1
where item = 2) l2 on (l1.id = l2.id)

set nocount on
declare @counter int = 1, @maxcounter int = (select max(id) from tmp_input2), @a varchar(205), @b varchar(205)
while @counter <= @maxcounter
begin
select @a = instleft, @b = instright from tmp_input2 where id = @counter
--select @counter, @a, @b
if dbo.compare(@a, @b) > 0
	begin 
		update tmp_input2 set correct = 0 where id = @counter
	end
set @counter = @counter + 1
end

	
select sum(id) part1 from tmp_input2 where correct = 1