if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input
--A Rock
--B Paper
--C Scissors
--X Rock 1
--Y Paper 2
--Z Scissors 3
--Lose 0
--Draw 3
--Win 6
select 
identity(int,1,1) [round],
case		when elf = 'A' and response = 'X' then (1 + 3)
			when elf = 'A' and response = 'Y' then (2 + 6)
			when elf = 'A' and response = 'Z' then (3 + 0)
			when elf = 'B' and response = 'X' then (1 + 0)
			when elf = 'B' and response = 'Y' then (2 + 3)
			when elf = 'B' and response = 'Z' then (3 + 6)
			when elf = 'C' and response = 'X' then (1 + 6)
			when elf = 'C' and response = 'Y' then (2 + 0)
			when elf = 'C' and response = 'Z' then (3 + 3)
			end
score
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day02\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day02\input.fmt', firstrow=1) test
ALTER TABLE dbo.tmp_input ADD CONSTRAINT
	PK_tmp_input PRIMARY KEY CLUSTERED 
	(
	[round]
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	select sum(score) from tmp_input