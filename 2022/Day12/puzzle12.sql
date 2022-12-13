
USE AOC
GO


set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,0,-1) ypos,
inst --,
--iif(isnumeric(SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst)))=1,convert(int,SUBSTRING(inst,charindex(' ',inst,1)+1,len(inst))),0) reg
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day12\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day12\input.fmt', firstrow=1) test

set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2
go
create table tmp_input2(id int identity(1,1)  primary key, ypos int not null, xpos int not null, elevation int, isstart bit default(0), isdest bit default(0)) as NODE
go

if exists(select 1 from sys.tables where name = 'possibleroutes')
drop table possibleroutes
go
CREATE TABLE possibleroutes(sxpos int, sypos int, dxpos int, dypos int, selevation int, delevation int) AS EDGE
go

declare @counter int, @maxcounter int, @xpos int, @maxxpos int
set @counter = 0
set @maxcounter = (select min(ypos) from tmp_input)
while @counter >= @maxcounter
begin
set @xpos = 0
set @maxxpos = (select len(inst) from tmp_input where ypos = @counter) - 1
while @xpos <= @maxxpos
begin
insert into tmp_input2(ypos,xpos,elevation,isstart,isdest)
select ypos, @xpos xpos, ascii(substring(inst,@xpos+1,1)) elevation, iif(ascii(substring(inst,@xpos+1,1)) = ASCII('S'),1,0) isstart, iif(ascii(substring(inst,@xpos+1,1)) = ASCII('E'),1,0) isdest from tmp_input where ypos = @counter
set @xpos = @xpos + 1
end
set @counter = @counter - 1
end

update tmp_input2 set elevation = ASCII('a') where isstart = 1
update tmp_input2 set elevation = ASCII('z') where isdest = 1

select * from tmp_input2 where isstart = 1
select * from tmp_input2 where isdest = 1

insert into possibleroutes
select t.$node_id, tr.$node_id, t.xpos, t.ypos, tr.xpos, tr.ypos, t.elevation, tr.elevation
from tmp_input2 t join tmp_input2 tr on (t.ypos = tr.ypos and t.xpos + 1 = tr.xpos)
where tr.elevation - t.elevation <= 1

insert into possibleroutes
select t.$node_id, tl.$node_id, t.xpos, t.ypos, tl.xpos, tl.ypos, t.elevation, tl.elevation
from tmp_input2 t join tmp_input2 tl on (t.ypos = tl.ypos and t.xpos - 1 = tl.xpos)
where tl.elevation - t.elevation <= 1

insert into possibleroutes
select t.$node_id, tu.$node_id, t.xpos, t.ypos, tu.xpos, tu.ypos, t.elevation, tu.elevation
from tmp_input2 t join tmp_input2 tu on (t.ypos + 1 = tu.ypos and t.xpos = tu.xpos)
where tu.elevation - t.elevation <= 1

insert into possibleroutes
select t.$node_id, td.$node_id, t.xpos, t.ypos, td.xpos, td.ypos, t.elevation, td.elevation
from tmp_input2 t join tmp_input2 td on (t.ypos - 1 = td.ypos and t.xpos = td.xpos)
where td.elevation - t.elevation <= 1

SELECT startpos, numsteps, Routes, LastNode
FROM (
	SELECT
		convert(varchar(5),Elevation1.xpos) + ',' + convert(varchar(5),Elevation1.ypos) AS startpos,
		STRING_AGG(convert(varchar(5),Elevation2.xpos) + ',' + convert(varchar(5),Elevation2.ypos), '->') WITHIN GROUP (GRAPH PATH) AS Routes,
		count(Elevation2.id) WITHIN GROUP (GRAPH PATH) AS NumSteps,
		LAST_VALUE(convert(varchar(5),Elevation2.xpos) + ',' + convert(varchar(5),Elevation2.ypos)) WITHIN GROUP (GRAPH PATH) AS LastNode
	--select *
	FROM
		tmp_input2 AS Elevation1,
		possibleroutes FOR PATH AS fo,
		tmp_input2 FOR PATH  AS Elevation2
	WHERE MATCH(SHORTEST_PATH(Elevation1(-(fo)->Elevation2)+))
	AND Elevation1.elevation = ascii('a') 
) AS Q
where Q.lastnode = '91,-20'
order by numsteps 





