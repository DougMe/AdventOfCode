if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
rucksack,
left(rucksack,len(rucksack)/2) comp1,
right(rucksack,len(rucksack)/2) comp2,
'' commontype
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day03\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day03\input.fmt', firstrow=1) test
ALTER TABLE dbo.tmp_input ADD CONSTRAINT
	PK_tmp_input PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	declare @counter int, @maxcounter int, @comp1 varchar(max)
	set @counter = 1
	set @maxcounter = (select max(id) from tmp_input)

	while @counter <= @maxcounter
	begin
	set @comp1 = (select comp1 from tmp_input where id = @counter)
		declare @str char(1), @pos int
		set @pos = 0
		print @comp1
		while @pos <= len(@comp1)
		begin
		set @str = SUBSTRING(@comp1, @pos, 1)
		print @str
		if exists(select 1 from tmp_input where id = @counter and comp2 COLLATE Latin1_General_CS_AS like '%' + @str + '%')
		begin
			update tmp_input set commontype = @str where id = @counter
			print @str
			break
		end
		set @pos = @pos + 1
		end
	set @counter = @counter + 1
	end


select  sum(isnull(iif(ASCII(commontype)<97,ascii(commontype)-38,ascii(commontype)-96),0)) value from tmp_input	