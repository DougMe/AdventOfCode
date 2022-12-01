if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input 
select IDENTITY(int,1,1) id,convert(int,value) calories, converT(int, null) elf
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day01\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day01\input.fmt', firstrow=1) test
ALTER TABLE dbo.tmp_input ADD CONSTRAINT
	PK_tmp_input PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
declare @counter int, @maxcounter int, @elf int, @calories int
set @counter = 1
set @maxcounter = (select max(id) from tmp_input)
set @elf = 1
while @counter <= @maxcounter
begin
set @calories = (select calories from tmp_input where id = @counter)
if @calories > 0 update tmp_input set elf = @elf where id = @counter else set @elf = @elf + 1
set @counter  = @counter + 1
end

---part 1 answer
select max(totalcalories) from (
select elf, sum(calories) totalcalories from tmp_input group by elf) calc

--part 2 answer
select sum(totalcalories) from (
select top 3 elf, sum(calories) totalcalories from tmp_input group by elf order by totalcalories desc) calc
