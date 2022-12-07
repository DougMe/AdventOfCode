set nocount on
if exists(select 1 from sys.tables where name = 'tmp_input')
drop table tmp_input

select 
identity(int,1,1) id,
cmd,
name,
convert(int,iif(isnumeric(cmd)=1 and cmd <> '$',cmd,0)) filesize,
convert(varchar(100),'') hid
into tmp_input
FROM OPENROWSET(BULK  'C:\adventofcode\2022\Day07\input.txt', 
                         FORMATFILE='C:\adventofcode\2022\Day07\input.fmt', firstrow=1) test
--select top 20 * from tmp_input

declare @counter int, @maxcounter int, @cmd varchar(10), @name varchar(20), @level int, @childlevel int, @hid varchar(100), @filesize int

set @counter = 1
set @maxcounter = (select max(id) from tmp_input)
set @hid = ''

while @counter <= @maxcounter
begin
select @cmd = cmd, @name = [name], @filesize = filesize from tmp_input where id = @counter
--select @cmd, @name, @filesize
if @cmd = '$' and @name = 'cd /' 
begin
set @level = 0
set @hid = '/'
update tmp_input set hid = @hid where id = @counter
end
if @cmd = '$' and @name = 'ls'
begin
set @childlevel = 1
end
if @cmd = 'dir' or @filesize > 0
begin
update tmp_input set hid = @hid + convert(varchar(3),@childlevel) + '/' where id = @counter
set @childlevel = @childlevel + 1
end
if @cmd = '$' and left(@name,2) = 'cd' and @name <> 'cd ..' and @name <> 'cd /'
begin
--select @name, @hid, @childlevel
if (select count(*) from tmp_input where [name] = replace(@name,'cd ','') and id < @counter ) > 1
set @hid = (select hid from tmp_input where [name] = replace(@name,'cd ','') and substring(hid,1,iif(len(hid)<3,3,len(hid))-iif(left(right(hid,3),1)='/',2,3)) = @hid and id < @counter)
else
set @hid = (select hid from tmp_input where [name] = replace(@name,'cd ','') and id < @counter)
if @hid is null 
begin
select @hid, @childlevel,hid,substring(hid,1,iif(len(hid)<3,3,len(hid))-iif(left(right(hid,3),1)='/',2,3)) from tmp_input  where [name] = replace(@name,'cd ','')
break;
end
--select @name, @hid
end
if @cmd = '$' and @name = 'cd ..'
begin
set @hid = substring(@hid,1,len(@hid) - iif(left(right(@hid,3),1)='/',2,3))
if @hid = '/' set @level = 0
end
set @counter = @counter + 1
end

if exists(select 1 from sys.tables where name = 'tmp_input2')
drop table tmp_input2

select id, cmd,name, case when filesize > 0 then 0 else 1 end isdir, filesize, cast(hid as hierarchyid) hid into tmp_input2 from tmp_input where hid <> ''


if exists(select 1 from sys.tables where name = 'tmp_input3')
drop table tmp_input3

;with cte(id, parent, value, leveln, level, total, isdir) as (
		select
			t.hid id, hid.GetAncestor(1) parent, t.filesize value, 
			0 leveln,
			CAST(hid AS nvarchar(100)) AS [Level],
			t.filesize as total, isdir
		from tmp_input2 t
   where hid.GetAncestor(1) is null
   union all
   select
			t.hid id, hid.GetAncestor(1) parent, t.filesize value, 
			c.leveln + 1 leveln,
			CAST(hid AS nvarchar(100)) AS [Level],
			case when t.filesize is null then c.total else t.filesize end as total, t.isdir
		from tmp_input2 t join cte c on (t.hid.GetAncestor(1) = c.id)
 )

select * into tmp_input3 from cte order by level


declare @leveln int

set @leveln = (select max(leveln) from tmp_input3)

while @leveln >= 0
begin

set nocount off
update t3 set total = child.total from (
select parent, sum(total) total from tmp_input3 where leveln = @leveln group by parent) child
join tmp_input3 t3 on (child.parent = t3.id) where isdir = 1

set @leveln = @leveln - 1

end


--select * from tmp_input3 where isdir = 1

--part 1
select sum(total) from tmp_input3 where total <= 100000 and isdir = 1


--part 2
select top 1 total from tmp_input3 where isdir = 1 and total >= (select 30000000 - (70000000 - (select total from tmp_input3 where isdir = 1 and leveln = 0))) order by total asc
