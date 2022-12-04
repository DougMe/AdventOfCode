if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
sec1min,
sec1max,
sec2min,
sec2max
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day04\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day04\input.fmt', firstrow=1) test
ALTER TABLE dbo.tmp_input ADD CONSTRAINT
	PK_tmp_input PRIMARY KEY CLUSTERED 
	(
	id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	select count(*) part1 from tmp_input where (sec1min >= sec2min and sec1max <= sec2max) or (sec2min >= sec1min and sec2max <= sec1max)

	select  count(*) part2 from tmp_input where sec1min between sec2min and sec2max or
								 sec1max between sec2min and sec2max or
								 sec2min between sec1min and sec1max or
								 sec2max between sec1min and sec1max

								 
