if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

create table tmp_input(id int identity(1,1), col1 varchar(1) not null,  col2 varchar(1) not null,  col3 varchar(1) not null,  col4 varchar(1) not null,  col5 varchar(1) not null,  col6 varchar(1) not null,  col7 varchar(1) not null,  col8 varchar(1) not null,  col9 varchar(1) not null)

declare @counter int
set @counter = 1
set nocount on
while @counter <= 92
begin
	insert into tmp_input(col1,col2,col3,col4,col5,col6,col7,col8,col9)
	values('','','','','','','','','')
	set @counter = @counter + 1
end
set nocount off
insert into tmp_input(col1,col2,col3,col4,col5,col6,col7,col8,col9)
select 
replace(replace(trim(col1),'[',''),']','') col1,
replace(replace(trim(col2),'[',''),']','') col2,
replace(replace(trim(col3),'[',''),']','') col3,
replace(replace(trim(col4),'[',''),']','') col4,
replace(replace(trim(col5),'[',''),']','') col5,
replace(replace(trim(col6),'[',''),']','') col6,
replace(replace(trim(col7),'[',''),']','') col7,
replace(replace(trim(col8),'[',''),']','') col8,
left(replace(replace(replace(trim(col9),'[',''),']',''),char(10),''),1) col9
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day05\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day05\input.fmt', firstrow=1) test

ALTER TABLE dbo.tmp_input ADD CONSTRAINT
	PK_tmp_input PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	
if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2
					 

select identity(int,1,1) id, howmany, 'col'+colfrom colfrom, 'col'+colto colto
into tmp_input2
						FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day05\instructions.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day05\instructions.fmt', firstrow=1) test


ALTER TABLE dbo.tmp_input2 ADD CONSTRAINT
	PK_tmp_input2 PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

select * from tmp_input
select * from tmp_input2

declare @instruction int, @maxinstruction int, @howmany int, @movement int, @fromvalue varchar(1), @sql nvarchar(max), @colfrom varchar(10), @colto varchar(10)
set @instruction = 1
set @maxinstruction = (select max(id) from tmp_input2)
while @instruction <= 1-- @maxinstruction
begin
set @movement = 1
set @howmany = (select howmany from tmp_input2 where id = @instruction)
set @colfrom = (select replace(replace(colfrom,char(13),''),char(10),'') from tmp_input2 where id = @instruction)
set @colto = (select replace(replace(colto,char(13),''),char(10),'') from tmp_input2 where id = @instruction)
print @howmany
print @colfrom
print @colto
	while @howmany >= @movement
	begin
	DECLARE @ParmDefinition NVARCHAR(500);  
	set @sql = (select 'select @fromvalue=' + @colfrom + ' from tmp_input where id = (select min(id) + ' + convert(varchar(2),@howmany) + ' from tmp_input where ascii(' + @colfrom + ') between 65 and 90)')
	print @sql
	SET @ParmDefinition = N'@fromvalue VARCHAR(1) OUTPUT';  
	EXECUTE sp_executesql @sql, @ParmDefinition, @fromvalue=@fromvalue OUTPUT;  
	print @fromvalue
	set @sql = (select 'update tmp_input set ' + @colfrom + ' = '''' from tmp_input where id = isnull((select min(id)  + ' + convert(varchar(2),@howmany) + ' from tmp_input where ASCII(' + @colfrom + ') between 65 and 90),100)')
	print @sql
	exec (@sql)
	set @sql = (select 'update tmp_input set ' + @colto + ' = ''' + @fromvalue + ''' from tmp_input where id = isnull((select min(id) from tmp_input where ASCII(' + @colto + ') between 65 and 90),101) - 1')
	print @sql
	exec (@sql)
	set @howmany = @howmany - 1
	end
set @instruction = @instruction +1
end

 
 SELECT (select col1 from tmp_input where id = (select min(id) from tmp_input where ascii(col1) between 65 and 90))  +
  (select col2 from tmp_input where id = (select min(id) from tmp_input where ascii(col2) between 65 and 90))  +
   (select col3 from tmp_input where id = (select min(id) from tmp_input where ascii(col3) between 65 and 90))  +
    (select col4 from tmp_input where id = (select min(id) from tmp_input where ascii(col4) between 65 and 90))  +
	 (select col5 from tmp_input where id = (select min(id) from tmp_input where ascii(col5) between 65 and 90))  +
	  (select col6 from tmp_input where id = (select min(id) from tmp_input where ascii(col6) between 65 and 90))  +
	   (select col7 from tmp_input where id = (select min(id) from tmp_input where ascii(col7) between 65 and 90))  +
	    (select col8 from tmp_input where id = (select min(id) from tmp_input where ascii(col8) between 65 and 90))  +
		(select col9 from tmp_input where id = (select min(id) from tmp_input where ascii(col9) between 65 and 90))  