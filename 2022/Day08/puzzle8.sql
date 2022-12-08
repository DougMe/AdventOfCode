
USE AOC
GO

set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
[row]
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day08\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day08\input.fmt', firstrow=1) test


ALTER TABLE [dbo].[tmp_array] DROP CONSTRAINT [DF__tmp_array__right__5887175A]
GO

ALTER TABLE [dbo].[tmp_array] DROP CONSTRAINT [DF__tmp_array__downs__5792F321]
GO

ALTER TABLE [dbo].[tmp_array] DROP CONSTRAINT [DF__tmp_array__lefts__569ECEE8]
GO

ALTER TABLE [dbo].[tmp_array] DROP CONSTRAINT [DF__tmp_array__upsco__55AAAAAF]
GO

ALTER TABLE [dbo].[tmp_array] DROP CONSTRAINT [DF__tmp_array__visib__54B68676]
GO

/****** Object:  Table [dbo].[tmp_array]    Script Date: 12/8/2022 12:14:00 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tmp_array]') AND type in (N'U'))
DROP TABLE [dbo].[tmp_array]
GO

/****** Object:  Table [dbo].[tmp_array]    Script Date: 12/8/2022 12:14:00 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tmp_array](
	[col] [int] NOT NULL,
	[row] [int] NOT NULL,
	[value] [nvarchar](1) NOT NULL,
	[visible] [bit] NULL,
	[upscore] [int] NULL,
	[leftscore] [int] NULL,
	[downscore] [int] NULL,
	[rightscore] [int] NULL,
	[scenicscore]  AS ((([upscore]*[leftscore])*[downscore])*[rightscore]),
 CONSTRAINT [PK_tmp_array] PRIMARY KEY CLUSTERED 
(
	[col] ASC,
	[row] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tmp_array] ADD  CONSTRAINT [DF__tmp_array__visib__54B68676]  DEFAULT ((0)) FOR [visible]
GO

ALTER TABLE [dbo].[tmp_array] ADD  CONSTRAINT [DF__tmp_array__upsco__55AAAAAF]  DEFAULT ((0)) FOR [upscore]
GO

ALTER TABLE [dbo].[tmp_array] ADD  CONSTRAINT [DF__tmp_array__lefts__569ECEE8]  DEFAULT ((0)) FOR [leftscore]
GO

ALTER TABLE [dbo].[tmp_array] ADD  CONSTRAINT [DF__tmp_array__downs__5792F321]  DEFAULT ((0)) FOR [downscore]
GO

ALTER TABLE [dbo].[tmp_array] ADD  CONSTRAINT [DF__tmp_array__right__5887175A]  DEFAULT ((0)) FOR [rightscore]
GO


	
declare @row int, @col int, @value nvarchar(1)
set @row = 1
while @row <= (select max(id) from tmp_input)
begin
	set @col = 1
	while @col <= (select len([row]) from tmp_input where id = @row)
	begin
	insert into tmp_array([row],[col],[value])
	values(@row, @col, (select SUBSTRING([row],@col, 1) [value] from tmp_input where id = @row))
	set @col = @col + 1
	end
	set @row = @row + 1
end

declare @visible bit, @totalvisible int, @viewcol int, @viewrow int, @viewvalue int, @edgestotal int
set @visible = 1
set @edgestotal = (((select max(col) from tmp_array) + (select max(row) from tmp_array)) * 2) - 4  --all edge trees are visible
set @totalvisible = 0
select max(col) maxcol from tmp_array 
select max(row) maxrow from tmp_array
print '---start looking---'
--top
set @viewcol = 2
while @viewcol <= (select max(col) from tmp_array) - 1
begin
	set @viewrow = 2
	while @viewrow <= (select max(row) from tmp_array) - 1
	begin
		--print @viewrow
		if not exists (select 1 from 
		(select value from tmp_array a 
		where col = @viewcol and row = @viewrow) curval
		join 
		(select value from tmp_array 
		where col = @viewcol and row < @viewrow
		) prevval on (curval.value <= prevval.value)
		) update tmp_array set visible = 1 where row = @viewrow and col = @viewcol
		declare @upscore int, @downscore int, @leftscore int, @rightscore int
		select @upscore = @viewrow - isnull(max(up.row),(select min(row) from tmp_array)) from (select row, value from tmp_array where col = @viewcol and row < @viewrow) up join (select value from tmp_array where col = @viewcol and row = @viewrow) curval on (up.value >= curval.value)
		select @downscore = isnull(min(down.row),(select max(row) from tmp_array)) - @viewrow from (select row, value from tmp_array where col = @viewcol and row > @viewrow) down join (select value from tmp_array where col = @viewcol and row = @viewrow) curval on (down.value >= curval.value)
		select @leftscore = @viewcol - isnull(max([left].col),(select min(col) from tmp_array)) from (select col, value from tmp_array where col < @viewcol and row = @viewrow) [left] join (select value from tmp_array where col = @viewcol and row = @viewrow) curval on ([left].value >= curval.value)
		select @rightscore = isnull(min([right].col),(select max(col) from tmp_array)) - @viewcol from (select col, value from tmp_array where col > @viewcol and row = @viewrow) [right] join (select value from tmp_array where col = @viewcol and row = @viewrow) curval on ([right].value >= curval.value)
		update tmp_array set upscore = @upscore, leftscore =  @leftscore, downscore = @downscore, rightscore = @rightscore where col = @viewcol and row = @viewrow
		set @viewrow = @viewrow + 1
	end
	--print @viewcol
	set @viewcol = @viewcol + 1
end
--left
set @viewrow = 2
while @viewrow <= (select max(row) from tmp_array) - 1
begin
	set @viewcol = 2
	while @viewcol <= (select max(col) from tmp_array) - 1
	begin
		--print @viewcol
		if not exists (select 1 from 
		(select value from tmp_array a 
		where col = @viewcol and row = @viewrow) curval
		join 
		(select value from tmp_array 
		where col < @viewcol and row = @viewrow
		) prevval on (curval.value <= prevval.value)
		) update tmp_array set visible = 1 where row = @viewrow and col = @viewcol
		set @viewcol = @viewcol + 1
	end
	--print @viewrow
	set @viewrow = @viewrow + 1
end
--bottom
set @viewcol = 2
while @viewcol <= (select max(col) from tmp_array) - 1
begin
	set @viewrow = 98
	while @viewrow >= (select min(row) from tmp_array) - 1
	begin
		--print @viewrow
		if not exists (select 1 from 
		(select value from tmp_array a 
		where col = @viewcol and row = @viewrow) curval
		join 
		(select value from tmp_array 
		where col = @viewcol and row > @viewrow
		) prevval on (curval.value <= prevval.value)
		) update tmp_array set visible = 1 where row = @viewrow and col = @viewcol
		set @viewrow = @viewrow - 1
	end
	--print @viewcol
	set @viewcol = @viewcol + 1
end
--right
set @viewrow = 2
while @viewrow <= (select max(row) from tmp_array) - 1
begin
	set @viewcol = 98
	while @viewcol >= (select min(col) from tmp_array) - 1
	begin
		--print @viewcol
		if not exists (select 1 from 
		(select value from tmp_array a 
		where col = @viewcol and row = @viewrow) curval
		join 
		(select value from tmp_array 
		where col > @viewcol and row = @viewrow
		) prevval on (curval.value <= prevval.value)
		) update tmp_array set visible = 1 where row = @viewrow and col = @viewcol
		set @viewcol = @viewcol - 1
	end
	--print @viewrow
	set @viewrow = @viewrow + 1
end

set @totalvisible = (select count(*) from tmp_array where visible = 1)

select  @totalvisible totalvisiblefromedges, @edgestotal totaledgpieces, @totalvisible + @edgestotal totalvisible --including all edge pieces

select * from tmp_array order by scenicscore desc


