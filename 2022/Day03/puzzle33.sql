if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2

select 
identity(int,1,1) id,
t1.rucksack rucksack1,
t2.rucksack rucksack2,
t3.rucksack rucksack3,
'' badge
into tmp_input2
FROM tmp_input t3
join tmp_input t2 on (t3.id = t2.id + 1)
join tmp_input t1 on (t3.id = t1.id + 2)
where t3.id % 3 = 0

ALTER TABLE dbo.tmp_input2 ADD CONSTRAINT
	PK_tmp_input2 PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	declare @counter int, @maxcounter int, @comp1 varchar(max)
	set @counter = 1
	set @maxcounter = (select max(id) from tmp_input2)

	while @counter <= @maxcounter
	begin
	set @comp1 = (select rucksack1 from tmp_input2 where id = @counter)
		declare @str char(1), @pos int
		set @pos = 0
		print @comp1
		while @pos <= len(@comp1)
		begin
		set @str = SUBSTRING(@comp1, @pos, 1)
		print @str
		if exists(select 1 from tmp_input2 where id = @counter 
					and rucksack2 COLLATE Latin1_General_CS_AS like '%' + @str + '%'
					and rucksack3 COLLATE Latin1_General_CS_AS like '%' + @str + '%'
					)
		begin
			update tmp_input2 set badge = @str where id = @counter
			print @str
			break
		end
		set @pos = @pos + 1
		end
	set @counter = @counter + 1
	end


select  sum(isnull(iif(ASCII(badge)<97,ascii(badge)-38,ascii(badge)-96),0)) value from tmp_input2	



