if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
input
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day06\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day06\input.fmt', firstrow=1) test

declare @counter int, @maxcounter int

set @counter = 14
set @maxcounter = (select len(input) from tmp_input)

while @counter <= @maxcounter
begin
declare @counttbl as table (input char(1) not null)
declare @innercounter int
	set @innercounter = 0
	delete from @counttbl
	while @innercounter <= 13
	begin
	insert into @counttbl(input)
	select SUBSTRING(input,@counter-@innercounter,1) from tmp_input
	set @innercounter = @innercounter + 1
	end
	if not exists(select input, count(*) from @counttbl group by input having count(*) > 1)
	begin
	select @counter  firstmessage
	break;
end
set @counter = @counter + 1
end

								 
