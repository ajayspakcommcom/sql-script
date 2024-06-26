
USE [Haemat]
GO
/****** Object:  User [hae]    Script Date: 20-04-2024 11:10:03 ******/
CREATE USER [hae] FOR LOGIN [hae] WITH DEFAULT_SCHEMA=[hae]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [hae]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [hae]
GO
ALTER ROLE [db_datareader] ADD MEMBER [hae]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [hae]
GO
/****** Object:  Schema [hae]    Script Date: 20-04-2024 11:10:04 ******/
CREATE SCHEMA [hae]
GO
/****** Object:  StoredProcedure [dbo].[AUDIT_prc_AggregateReport]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AUDIT_prc_AggregateReport]
	@DATE_FROM 			nvarchar(50)	= NULL,
	@DATE_TO 			nvarchar(50)	= NULL,
    @WHERE				nvarchar(4000)	= NULL,
	@ROW_COUNT 			int 			= NULL,
	@GroupByDate 		tinyint 		= 1,
	@GroupByTableName 	bit 			= 0,
	@GroupByMODIFIED_BY bit 			= 0,
	@GroupByACTION 		bit 			= 0,
	@GroupByAPPLICATION bit 			= 0,
	@GroupByCOMPUTER 	bit 			= 0
AS
DECLARE	@sqlstr nvarchar(4000)
DECLARE	@DateExpression varchar(8000)
DECLARE	@DateFieldName varchar(20)
DECLARE @SearcheableName nvarchar(261)
declare @len int
declare @ver7 bit
declare @ver2000 bit
declare @WhereSql nvarchar(4000)
declare @cmptlvl int
Select @cmptlvl = t1.cmptlevel 
from master.dbo.sysdatabases t1
where t1.[name]=DB_NAME()
set @ver7 = 0
IF @cmptlvl < 80 set @ver7 = 1
set @ver2000 = 0
IF @cmptlvl < 90 set @ver2000 = 1
IF @GroupByDate not in (0,1,2,3,4) 
BEGIN
  RAISERROR ('@GroupByDate must be one of: 0,1,2,3,4',16,1)
  RETURN -1
END
if (select count(*) from ##Filter where [index]='DATABASE') = 0
	insert into ##Filter([index], [value]) values('DATABASE', '%')
if (select count(*) from ##Filter where [index]='TABLE_NAME') = 0
	insert into ##Filter([index], [value]) values('TABLE_NAME', '%')
if (select count(*) from ##Filter where [index]='TABLE_OWNER') = 0
	insert into ##Filter([index], [value]) values('TABLE_OWNER', '%')
if (select count(*) from ##Filter where [index]='USER_NAME') = 0
	insert into ##Filter([index], [value]) values('USER_NAME', '%')
if (select count(*) from ##Filter where [index]='ACTION_ID') = 0
	insert into ##Filter([index], [value]) values('ACTION_ID', '%')
if (select count(*) from ##Filter where [index]='HOST_NAME') = 0
	insert into ##Filter([index], [value]) values('HOST_NAME', '%')
if (select count(*) from ##Filter where [index]='APP_NAME') = 0
	insert into ##Filter([index], [value]) values('APP_NAME', '%')
SET @DateExpression = 
  CASE
   WHEN @GroupByDate = 0 
    THEN ''
   WHEN @GroupByDate = 1 
    THEN 'LEFT(CONVERT(varchar(20), convert(datetime,MODIFIED_DATE), 100),14) + RIGHT(CONVERT(varchar(20), convert(datetime,MODIFIED_DATE), 100),2) '
   WHEN @GroupByDate = 2
    THEN 'CONVERT(varchar(20), CONVERT(datetime,MODIFIED_DATE), 107) '
   WHEN @GroupByDate = 3 
    THEN 'LEFT(CONVERT(varchar(20), CONVERT(datetime,MODIFIED_DATE), 107),4)+RIGHT(CONVERT(varchar(20), CONVERT(datetime,MODIFIED_DATE), 107),4) '
   WHEN @GroupByDate = 4
    THEN 'RIGHT(CONVERT(varchar(20), CONVERT(datetime,MODIFIED_DATE), 107),4) '
  END  
SET @DateFieldName = 
  CASE
   WHEN @GroupByDate = 0 
    THEN ''
   WHEN @GroupByDate = 1 
    THEN ' AS ''Hour'''
   WHEN @GroupByDate = 2
    THEN ' AS ''Date'''
   WHEN @GroupByDate = 3 
    THEN ' AS ''Month'''
   WHEN @GroupByDate = 4
    THEN ' AS ''Year'''
  END  
SET @sqlstr = '
select TOP'+STR(CASE WHEN @ROW_COUNT is null THEN 99999 ELSE @ROW_COUNT END)+' * from (
SELECT sum(DATA_COUNT) AS [#], t.[DATABASE] as ''Database'''+
 CASE
  WHEN @GroupByTableName = 0 THEN ''
  ELSE ', TABLE_NAME as [Table name], TABLE_SCHEMA as [' +
	CASE @ver2000 WHEN 1 THEN 'Owner' ELSE 'Table schema' END +']'
 END +
 CASE
  WHEN @GroupByMODIFIED_BY = 0 THEN ''
  ELSE ', MODIFIED_BY as [Modified by]'
 END +
 CASE
  WHEN @GroupByACTION = 0 THEN ''
  ELSE ', CASE t.AUDIT_ACTION_ID 
              WHEN 1 THEN ''Update'' 
              WHEN 2 THEN ''Insert'' 
              WHEN 3 THEN ''Delete'' 
          END AS [Action]'
 END +
 CASE
  WHEN @GroupByAPPLICATION = 0 THEN ''
  ELSE ', APPLICATION as [Application]'
 END +
 CASE
  WHEN @GroupByCOMPUTER = 0 THEN ''
  ELSE ', COMPUTER as [Computer]'
 END +
 CASE
  WHEN @DateExpression <> '' 
  THEN ', '
  ELSE ''
 END +
@DateExpression+
@DateFieldName
set @sqlstr = @sqlstr +
 ' FROM (
		SELECT 
			  [DATABASE],
			  TABLE_NAME,
			  TABLE_SCHEMA,
			  AUDIT_ACTION_ID, 
			  MODIFIED_BY, 
			  CONVERT(varchar(20), MODIFIED_DATE, 113) AS MODIFIED_DATE,
			  HOST_NAME AS COMPUTER,
			  APP_NAME as APPLICATION,
   			  count(distinct convert(nvarchar(100), t.AUDIT_LOG_TRANSACTION_ID)) [DATA_COUNT]
		from dbo.AUDIT_LOG_TRANSACTIONS t 
			inner join dbo.AUDIT_LOG_DATA d
			on t.AUDIT_LOG_TRANSACTION_ID=d.AUDIT_LOG_TRANSACTION_ID
		group by 
			[DATABASE] ,
			[TABLE_NAME] ,
			[TABLE_SCHEMA] ,
			[AUDIT_ACTION_ID] ,
			[HOST_NAME] ,
			[APP_NAME] ,
			[MODIFIED_BY] ,
			[MODIFIED_DATE] 
	) t
	inner join ##Filter f1 on f1.[index]=''TABLE_NAME'' and t.TABLE_NAME like Replace(f1.[value]' + case @ver7 when 0 then ' collate database_default' else '' end + ', ''['', ''[[]'')
	inner join ##Filter f2 on f2.[index]=''TABLE_OWNER'' and t.TABLE_SCHEMA like Replace(f2.[value]' + case @ver7 when 0 then ' collate database_default' else '' end + ', ''['', ''[[]'')
	inner join ##Filter f3 on f3.[index]=''APP_NAME'' and t.APPLICATION like Replace(f3.[value]' + case @ver7 when 0 then ' collate database_default' else '' end + ', ''['', ''[[]'')
	inner join ##Filter f4 on f4.[index]=''HOST_NAME'' and t.COMPUTER like Replace(f4.[value]' + case @ver7 when 0 then ' collate database_default' else '' end + ', ''['', ''[[]'')
	inner join ##Filter f5 on f5.[index]=''USER_NAME'' and t.MODIFIED_BY like Replace(f5.[value]' + case @ver7 when 0 then ' collate database_default' else '' end + ', ''['', ''[[]'')
	inner join ##Filter f6 on f6.[index]=''ACTION_ID'' and Cast(t.AUDIT_ACTION_ID as char(1)) like Replace(f6.[value]' + case @ver7 when 0 then ' collate database_default' else '' end + ', ''['', ''[[]'')
	inner join ##Filter f7 on f7.[index]=''DATABASE'' and t.[DATABASE] like Replace(f7.[value]' + case @ver7 when 0 then ' collate database_default' else '' end + ', ''['', ''[[]'')
	where [DATA_COUNT]=[DATA_COUNT]
' +
 CASE
  WHEN @DATE_FROM is NULL THEN ''
  ELSE ' AND CONVERT(DATETIME,MODIFIED_DATE) >= '''+CONVERT(varchar(20),@DATE_FROM,120)+''''
 END +
 CASE
  WHEN @DATE_TO is NULL THEN ''
  ELSE ' AND CONVERT(DATETIME,MODIFIED_DATE) < '''+CONVERT(varchar(20),@DATE_TO,120)+''''
 END +
CASE
  WHEN @DateExpression = ''  THEN ' GROUP BY '
  ELSE ' GROUP BY ' + @DateExpression + ','
 END
 + '[DATABASE], ' +
 CASE WHEN @GroupByTableName 	= 1 	THEN ' TABLE_SCHEMA, TABLE_NAME,' 	ELSE '' END +
 CASE WHEN @GroupByMODIFIED_BY 	= 1 	THEN ' MODIFIED_BY,' 	ELSE '' END +
 CASE WHEN @GroupByACTION 	= 1 	THEN ' AUDIT_ACTION_ID,' 	ELSE '' END +
 CASE WHEN @GroupByAPPLICATION 	= 1 	THEN ' APPLICATION,' 	ELSE '' END +
 CASE WHEN @GroupByCOMPUTER 	= 1 	THEN ' COMPUTER,' 	ELSE '' END
set @len = len(@sqlstr)
if substring(@sqlstr, @len, 1) = ','
begin
	set @sqlstr = substring(@sqlstr,1,@len-1)
end
set @sqlstr = @sqlstr + ') [table]'
if @WHERE IS NOT NULL
begin
	set @WhereSql = @sqlstr+' where '+@WHERE
	exec sp_executesql @WhereSql
end
else
begin
	exec sp_executesql @sqlstr
end
RETURN @@ERROR

GO
/****** Object:  StoredProcedure [dbo].[AUDIT_prc_DDLReport]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AUDIT_prc_DDLReport]
(	@DATE_FROM 			nvarchar(50)	    = NULL,
	@DATE_TO 			  nvarchar(50)	    = NULL,
  @OLD_VALUE			nvarchar(4000)    = NULL,    
  @NEW_VALUE			nvarchar(4000)    = NULL,    
  @WHERE				  nvarchar(4000)    = NULL,
  @ROW_COUNT			int               = NULL)
AS
SET NOCOUNT ON;
DECLARE
@rowCount nchar(100),
@database nchar(1000),
@schema nchar(1000),
@action nchar(1000),
@oldValue nchar(1000),
@newValue nchar(1000),
@appName nchar(1000),
@hostName nchar(1000),
@modifiedBy nchar(1000),
@modifiedDate nchar(1000),
@dateFrom nchar(100),
@dateTo nchar(100),
@whereClause nchar(1000),
@query nchar(4000);
-- Set row count
IF @ROW_COUNT IS NULL
  BEGIN
    SET @rowCount = '99999';
  END
ELSE
  BEGIN
    SET @rowCount = CAST(@ROW_COUNT as nchar(100));
  END
-- Set new value
IF @NEW_VALUE IS NULL
  BEGIN
    SET @newValue = '%';
  END
ELSE
  BEGIN
    SET @newValue = '%' + RTRIM(@NEW_VALUE) + '%';
  END
-- Set new value
IF @OLD_VALUE IS NULL
  BEGIN
    SET @oldValue = '%';
  END
ELSE
  BEGIN
    SET @oldValue = '%' + RTRIM(@OLD_VALUE) + '%';
  END
-- Set WHERE clause
IF @WHERE IS NULL
  BEGIN
    SET @whereClause = '';
  END
ELSE
  BEGIN
    SET @whereClause = ' AND (' + RTRIM(@WHERE) + ')';
  END
-- Set date from
IF @DATE_FROM IS NULL
  BEGIN
    SET @dateFrom = '1/1/1900';
  END
ELSE
  BEGIN
    SET @dateFrom = CONVERT(nchar(100), @DATE_FROM, 120);
  END
-- Set date to
IF @DATE_TO IS NULL
  BEGIN
    SET @dateTo = '1/1/3900';
  END
ELSE
  BEGIN
    SET @dateTo = CONVERT(nchar(100), @DATE_TO, 120);
  END
DECLARE
@id int,
@value nchar(1000);
DECLARE
@counter int,
@filterValue nchar(1000);
-- Set filter for DATABASE
IF (select count(*) from ##Filter WHERE [index]='DATABASE') = 0
  BEGIN
	  SET @database = ' WHERE [DATABASE] LIKE ''%''';
  END
ELSE
  BEGIN
	  SET @database = ' WHERE [DATABASE] LIKE ''%''';
  END
  SET @database = RTRIM(@database);
-- Set filter for SCHEMA
CREATE TABLE ##FilterSchema
(
  id int identity(1,1) not null,
  value nchar(1000)
  primary key(id)
)
IF (select count(*) from ##Filter WHERE [index]='SCHEMA') = 0
  SET @schema = '';
ELSE
BEGIN
  INSERT INTO ##FilterSchema (value)
    SELECT [value] FROM ##Filter
    WHERE [index] = 'SCHEMA';
  SET @counter = 1;
  WHILE (@counter <= (SELECT MAX(id) FROM ##FilterSchema))
    BEGIN
      SET @filterValue = (SELECT value FROM ##FilterSchema WHERE id=@counter);
      IF @counter = 1
        BEGIN
          SET @schema = ' AND ([SCHEMA] LIKE ''' + RTRIM(@filterValue) + ''''
        END
      ELSE
        BEGIN
          SET @schema = RTRIM(@schema) + ' OR [SCHEMA] LIKE ''' + RTRIM(@filterValue) + ''''
        END
      SET @counter = @counter + 1
      SET @schema = RTRIM(@schema);
    END
    SET @schema = RTRIM(@schema) + ')';
END    
    DROP TABLE ##FilterSchema;
-- Set filter for ACTION
CREATE TABLE ##FilterAction
(
  id int identity(1,1) not null,
  value nchar(1000)
  primary key(id)
)
IF (select count(*) from ##Filter WHERE [index]='ACTION_ID') = 0
	SET @action = '';
ELSE
  INSERT INTO ##FilterAction (value)
    SELECT [value] FROM ##Filter
    WHERE [index] = 'ACTION_ID';
  SET @counter = 1;
  WHILE (@counter <= (SELECT MAX(id) FROM ##FilterAction))
    BEGIN
      SET @filterValue = (SELECT value FROM ##FilterAction WHERE id=@counter);
      IF @filterValue LIKE '%4%'
        BEGIN
          SET @filterValue = 'CREATE'
        END
      ELSE IF @filterValue LIKE '%5%'
        BEGIN
          SET @filterValue = 'ALTER'
        END
      ELSE IF @filterValue LIKE '%6%'
        BEGIN
          SET @filterValue = 'DROP'
        END
      ELSE
        BEGIN
          SET @filterValue = 'unknown'
        END
      IF @counter = 1
        BEGIN
          SET @action = ' AND (ACTION LIKE ''' + RTRIM(@filterValue) + ''''
        END
      ELSE
        BEGIN
          SET @action = RTRIM(@action) + ' OR ACTION LIKE ''' + RTRIM(@filterValue) + ''''
        END
      SET @counter = @counter + 1;
      SET @action = RTRIM(@action);
    END
    SET @action = RTRIM(@action) + ')';
    DROP TABLE ##FilterAction;
-- Set filter for OLD_VALUE
IF @OLD_VALUE IS NULL
  SET @oldValue = '';
ELSE
  SET @oldValue = ' AND (OLD_VALUE LIKE ''' + RTRIM(@oldValue) + ''')';
-- Set filter for NEW_VALUE
IF @NEW_VALUE IS NULL
  SET @newValue = '';
ELSE
  SET @newValue = ' AND (NEW_VALUE LIKE ''' + RTRIM(@newValue) + ''')';
-- Set filter for APP_NAME
CREATE TABLE ##FilterAppName
(
  id int identity(1,1) not null,
  value nchar(1000)
  primary key(id)
)
IF (select count(*) from ##Filter WHERE [index]='APP_NAME') = 0
	SET @appName = '';
ELSE
BEGIN
  INSERT INTO ##FilterAppName (value)
    SELECT [value] FROM ##Filter
    WHERE [index] = 'APP_NAME';
  SET @counter = 1;
  WHILE (@counter <= (SELECT MAX(id) FROM ##FilterAppName))
    BEGIN
      SET @filterValue = (SELECT value FROM ##FilterAppName WHERE id=@counter);
      IF @counter = 1
        BEGIN
          SET @appName = ' AND (APP_NAME LIKE ''' + RTRIM(@filterValue) + ''''
        END
      ELSE
        BEGIN
          SET @appName = RTRIM(@appName) + ' OR APP_NAME LIKE ''' + RTRIM(@filterValue) + ''''
        END
      SET @counter = @counter + 1;
      SET @appName = RTRIM(@appName);
    END
    SET @appName = RTRIM(@appName) + ')';
END    
    DROP TABLE ##FilterAppName;
-- Set filter for HOST_NAME
CREATE TABLE ##FilterHostName
(
  id int identity(1,1) not null,
  value nchar(1000)
  primary key(id)
)
IF (select count(*) from ##Filter WHERE [index]='HOST_NAME') = 0
	SET @hostName = '';
ELSE
BEGIN
	INSERT INTO ##FilterHostName (value)
    SELECT [value] FROM ##Filter
    WHERE [index] = 'HOST_NAME';
  SET @counter = 1;
  WHILE (@counter <= (SELECT MAX(id) FROM ##FilterHostName))
    BEGIN
      SET @filterValue = (SELECT value FROM ##FilterHostName WHERE id=@counter);
      IF @counter = 1
        BEGIN
          SET @hostName = ' AND (HOST_NAME LIKE ''' + RTRIM(@filterValue) + ''''
        END
      ELSE
        BEGIN
          SET @hostName = RTRIM(@hostName) + ' OR HOST_NAME LIKE ''' + RTRIM(@filterValue) + ''''
        END
      SET @counter = @counter + 1;
      SET @hostName = RTRIM(@hostName);
    END
    SET @hostName = RTRIM(@hostName) + ')';
END  
    DROP TABLE ##FilterHostName;
-- Set filter for MODIFIED_BY
CREATE TABLE ##FilterModifiedBy
(
  id int identity(1,1) not null,
  value nchar(1000)
  primary key(id)
)
IF (select count(*) from ##Filter WHERE [index]='USER_NAME') = 0
	SET @modifiedBy = '';
ELSE
BEGIN
	INSERT INTO ##FilterModifiedBy (value)
    SELECT [value] FROM ##Filter
    WHERE [index] = 'USER_NAME';
  SET @counter = 1;
  WHILE (@counter <= (SELECT MAX(id) FROM ##FilterModifiedBy))
    BEGIN
      SET @filterValue = (SELECT value FROM ##FilterModifiedBy WHERE id=@counter);
      IF @counter = 1
        BEGIN
          SET @modifiedBy = ' AND (MODIFIED_BY LIKE ''' + RTRIM(@filterValue) + ''''
        END
      ELSE
        BEGIN
          SET @modifiedBy = RTRIM(@modifiedBy) + ' OR MODIFIED_BY LIKE ''' + RTRIM(@filterValue) + ''''
        END
      SET @counter = @counter + 1;
      SET @modifiedBy = RTRIM(@modifiedBy);
    END
    SET @modifiedBy = RTRIM(@modifiedBy) + ')';
END    
    DROP TABLE ##FilterModifiedBy;
-- Set filter for MODIFIED_DATE
SET @modifiedDate = ' AND MODIFIED_DATE >= ''' + RTRIM(@dateFrom) + ''' AND MODIFIED_DATE <= ''' + RTRIM(@dateTo) + '''';
SET @query = 'SELECT TOP ' + RTRIM(@rowCount) + ' LogId as ''Log ID'', [DATABASE] as ''Database'', [SCHEMA] as ''Schema'', OBJECT_TYPE as ''Object type'', OBJECT_NAME as ''Object name'', ACTION as ''Action'', OLD_VALUE as ''Old value'', NEW_VALUE as ''New value'', DESCRIPTION as ''Description'', MODIFIED_BY as ''Modified by'', MODIFIED_DATE as ''Modified date'', APP_NAME as ''Application name'', HOST_NAME as ''Host name'' FROM AUDIT_LOG_DDL'
+ RTRIM(@database)
+ RTRIM(@whereClause)
+ RTRIM(@schema)
+ RTRIM(@action)
+ RTRIM(@oldValue)
+ RTRIM(@newValue)
+ RTRIM(@appName)
+ RTRIM(@hostName)
+ RTRIM(@modifiedBy)
+ RTRIM(@modifiedDate);
EXECUTE sp_executesql @query;

GO
/****** Object:  StoredProcedure [dbo].[AUDIT_prc_Purge_AUDIT_LOG]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ------------------------------------------------------------
   PROCEDURE:     AUDIT_prc_Purge_AUDIT_LOG
   AUTHOR:        ApexSQL 
   UPDATED:	  	  19 Apr 2004
   CHANGES:       Version 2.10
		  		  Added @DELETE_ALL Parameter which will delete ALL Audit 
		  		  Log data regardless of what other parameters were specifiec
		  		  Fixed some problems where data in AUDIT_LOG_DATA was not being deleted only AUDIT_LOG_TRANSACTIONS
------------------------------------------------------------ */
CREATE PROCEDURE [dbo].[AUDIT_prc_Purge_AUDIT_LOG]
(
	@DELETE_ALL BIT,			--	This will delete all data
	@OLDER_THAN INT = NULL,			--	pass NULL to skip this check
	@OLDER_THAN_TYPE TINYINT = NULL,	-- 	1 - DAY, 2 - WEEK, 3 - MONTH; if @older_than is NULL, this parameter is not important
	@MAX_ROWS INT = NULL			--	pass NULL to skip this check
)
AS
BEGIN
  DECLARE @DDLExists BIT
  SET @DDLExists = 0
  BEGIN
    IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[AUDIT_LOG_DDL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		  BEGIN
			  set @DDLExists = 1
		  END
  END
  -- Delete all data from auditing tables
	If @DELETE_ALL = 1 
	BEGIN
		DELETE FROM dbo.AUDIT_LOG_DATA
		DELETE FROM dbo.AUDIT_LOG_TRANSACTIONS
    IF @DDLExists = 1
    BEGIN
      DELETE FROM dbo.AUDIT_LOG_DDL
    END
	END
	IF @OLDER_THAN IS NOT NULL
	BEGIN
		-- Get the cut off date and time
		DECLARE @CUTOFF_DATETIME DATETIME
		SET @CUTOFF_DATETIME =
			CASE @OLDER_THAN_TYPE
				WHEN 1 THEN DATEADD(DAY, -@OLDER_THAN, GETDATE())
				WHEN 2 THEN DATEADD(WEEK,-@OLDER_THAN, GETDATE())
				WHEN 3 THEN DATEADD(MONTH, -@OLDER_THAN, GETDATE())
			END
		-- Delete all rows from auditing tables that are older than n day(s)
		PRINT CONVERT(VARCHAR,@CUTOFF_DATETIME)
		DELETE
		FROM dbo.AUDIT_LOG_DATA
		WHERE AUDIT_LOG_TRANSACTION_ID IN
		(SELECT AUDIT_LOG_TRANSACTION_ID FROM dbo.AUDIT_LOG_TRANSACTIONS
		WHERE	MODIFIED_DATE < @CUTOFF_DATETIME)
		DELETE
		FROM dbo.AUDIT_LOG_TRANSACTIONS
		WHERE
			MODIFIED_DATE < @CUTOFF_DATETIME
    IF @DDLExists = 1
    BEGIN
      DELETE
		  FROM dbo.AUDIT_LOG_DDL
		  WHERE
		  	MODIFIED_DATE < @CUTOFF_DATETIME
    END
	END
    -- Check if we should check for max number of rows
	IF @MAX_ROWS IS NOT NULL
	BEGIN
		-- Get AUDIT_LOG_TRANSACTIONS row count
		DECLARE @ROW_COUNT INT
		SELECT @ROW_COUNT = COUNT(*)
		FROM dbo.AUDIT_LOG_TRANSACTIONS
		-- Check if there are more than @MAX_ROWS rows in the database
		IF @ROW_COUNT > @MAX_ROWS
		BEGIN
			-- Create temporary tables to hold ids of records to be purged
			CREATE TABLE #AUDIT_LOG_PURGE_PROCESS_TEMP_TABLE (AUDIT_LOG_TRANSACTION_ID nvarchar(100))
      IF @DDLExists = 1
      BEGIN
        CREATE TABLE #AUDIT_LOG_PURGE_PROCESS_DDL_TEMP_TABLE (LogId int)
      END
			-- Create dynamic queries to fill the temporary tables
			DECLARE @SQL NVARCHAR(4000)
			SET @SQL ='
			INSERT
			INTO #AUDIT_LOG_PURGE_PROCESS_TEMP_TABLE
			SELECT TOP ' + CAST((@ROW_COUNT - @MAX_ROWS) AS varchar(10)) + ' AUDIT_LOG_TRANSACTION_ID
			FROM dbo.AUDIT_LOG_TRANSACTIONS
			ORDER BY MODIFIED_DATE'
      IF @DDLExists = 1
      BEGIN
        DECLARE @SQL_DDL NVARCHAR(4000)
		  	SET @SQL_DDL ='
		  	INSERT 
		  	INTO #AUDIT_LOG_PURGE_PROCESS_DDL_TEMP_TABLE
		  	SELECT TOP ' + CAST((@ROW_COUNT - @MAX_ROWS) AS varchar(10)) + ' LogId
		  	FROM dbo.AUDIT_LOG_DDL
		  	ORDER BY MODIFIED_DATE'
      END
			--PRINT @SQL
      --PRINT @SQL_DDL
			-- Fill temporary tables
			EXEC sp_executesql @SQL
      IF @DDLExists = 1
      BEGIN
        EXEC sp_executesql @SQL_DDL
      END
			-- Delete records from auditing tables
			DELETE
			FROM dbo.AUDIT_LOG_DATA
			WHERE AUDIT_LOG_TRANSACTION_ID IN
				    (SELECT AUDIT_LOG_TRANSACTION_ID
					 FROM #AUDIT_LOG_PURGE_PROCESS_TEMP_TABLE)
			DELETE
			FROM dbo.AUDIT_LOG_TRANSACTIONS
			WHERE AUDIT_LOG_TRANSACTION_ID IN
				(SELECT AUDIT_LOG_TRANSACTION_ID
				 FROM #AUDIT_LOG_PURGE_PROCESS_TEMP_TABLE)
      IF @DDLExists = 1
      BEGIN
        DELETE 
			  FROM dbo.AUDIT_LOG_DDL
			  WHERE LogId IN
			  	(SELECT LogId
			  	FROM #AUDIT_LOG_PURGE_PROCESS_DDL_TEMP_TABLE)
        --Drop temp table
        DROP TABLE #AUDIT_LOG_PURGE_PROCESS_DDL_TEMP_TABLE
      END
			-- Drop temporary tables
			DROP TABLE #AUDIT_LOG_PURGE_PROCESS_TEMP_TABLE
		END
	END
END

GO
/****** Object:  StoredProcedure [dbo].[AUDIT_prc_ReportingAddFilterValue]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[AUDIT_prc_ReportingAddFilterValue]
@index nvarchar(100),
@value nvarchar(4000)
as
begin
if not exists (select [value] from ##Filter where [index]=@index and [value] like Replace(@value collate database_default, '[', '[[]'))
	insert into ##Filter([index], [value]) values(@index, @value)
end

GO
/****** Object:  StoredProcedure [dbo].[AUDIT_prc_ReportingEnd]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AUDIT_prc_ReportingEnd]
as
begin
drop table ##Filter
end

GO
/****** Object:  StoredProcedure [dbo].[AUDIT_prc_ReportingStart]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [dbo].[AUDIT_prc_ReportingStart]
as
begin
create table ##Filter([index] nvarchar(20), [value] nvarchar(4000))
end

GO
/****** Object:  StoredProcedure [dbo].[AUDIT_prc_StandardReport]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AUDIT_prc_StandardReport]
  (	@DATE_FROM 			nvarchar(50)	= NULL,
	@DATE_TO 			nvarchar(50)	= NULL,
    @OLD_VALUE			nvarchar(4000)    = NULL,    
    @NEW_VALUE			nvarchar(4000)    = NULL,    
    @WHERE				nvarchar(4000)   = NULL,
    @ROW_COUNT			int              = NULL)
AS
declare 
@strSql nvarchar(4000),
@ver7 bit,
@ver2000 bit,
@WhereSql nvarchar(4000),
@cmptlvl int
Select @cmptlvl = t1.cmptlevel 
from master.dbo.sysdatabases t1
where t1.[name]=DB_NAME()
set @ver7 = 0
IF @cmptlvl < 80 set @ver7 = 1
set @ver2000 = 0
IF @cmptlvl < 90 set @ver2000 = 1
set nocount on
/* Set replacement values for filter parameter */
if (select count(*) from ##Filter where [index]='DATABASE') = 0
	insert into ##Filter([index], [value]) values('DATABASE', '%')
if (select count(*) from ##Filter where [index]='TABLE_OWNER') = 0
	insert into ##Filter([index], [value]) values('TABLE_OWNER', '%')
if (select count(*) from ##Filter where [index]='TABLE_NAME') = 0
	insert into ##Filter([index], [value]) values('TABLE_NAME', '%')
if (select count(*) from ##Filter where [index]='FIELD_NAME') = 0
	insert into ##Filter([index], [value]) values('FIELD_NAME', '%')
if (select count(*) from ##Filter where [index]='USER_NAME') = 0
	insert into ##Filter([index], [value]) values('USER_NAME', '%')
if (select count(*) from ##Filter where [index]='ACTION_ID') = 0
	insert into ##Filter([index], [value]) values('ACTION_ID', '%')
if (select count(*) from ##Filter where [index]='HOST_NAME') = 0
	insert into ##Filter([index], [value]) values('HOST_NAME', '%')
if (select count(*) from ##Filter where [index]='APP_NAME') = 0
	insert into ##Filter([index], [value]) values('APP_NAME', '%')
IF @DATE_FROM IS NULL
   SET @DATE_FROM= '1/1/1900'
IF @DATE_TO IS NULL
   SET @DATE_TO = '1/1/3900'
IF @OLD_VALUE IS NULL
   SET @OLD_VALUE = '%'
IF @NEW_VALUE IS NULL
   SET @NEW_VALUE = '%'
IF @ROW_COUNT IS NULL
   SET @ROW_COUNT = 99999
/* Get Object ID */
--SELECT @obj_id = object_id(@full_table_name)
set @strSql = '
declare
@DATE_FROM      datetime,
@DATE_TO        datetime,
@OLD_VALUE      varchar(8000),
@NEW_VALUE      varchar(8000),
@ROW_COUNT      int
set @DATE_FROM = '''+convert(nvarchar(100), @DATE_FROM, 120)+'''
set @DATE_TO = '''+convert(nvarchar(100), @DATE_TO, 120)+'''
set @OLD_VALUE = '''+@OLD_VALUE+'''
set @NEW_VALUE = '''+@NEW_VALUE+'''
set @ROW_COUNT = '+cast(@ROW_COUNT as nvarchar(100))+'
select top '+cast(@ROW_COUNT as nvarchar(100))+' * from (
   SELECT  t.[DATABASE] ''Database'',
		   t.TABLE_NAME ''Table name'',
		   t.TABLE_SCHEMA ''' +
	CASE @ver2000 WHEN 1 THEN 'Owner' ELSE 'Table schema' END +''',
           CASE    t.AUDIT_ACTION_ID
               WHEN 2 then ''Insert''
               WHEN 1 then ''Update''
               WHEN 3 then ''Delete''
           END         ''Action'',
           KEY1 as ''Key 1'',
           KEY2 as ''Key 2'',
           KEY3 as ''Key 3'',
           KEY4 as ''Key 4'',
           d.COL_NAME ''Column name'',
           d.OLD_VALUE ''Old value'',
           d.NEW_VALUE ''New value'',
           t.MODIFIED_BY ''Modified by'',
           t.MODIFIED_DATE ''Modified date'',
           t.HOST_NAME ''Computer'',
           t.APP_NAME ''Application''
    FROM dbo.AUDIT_LOG_TRANSACTIONS t
    JOIN dbo.AUDIT_LOG_DATA d ON d.AUDIT_LOG_TRANSACTION_ID = t.AUDIT_LOG_TRANSACTION_ID,
	(select [value] from ##Filter where [index]=''DATABASE'') t_db,-- database
	(select [value] from ##Filter where [index]=''TABLE_OWNER'') t_owners,-- owners
	(select [value] from ##Filter where [index]=''TABLE_NAME'') t_tables,-- tables
	(select [value] from ##Filter where [index]=''FIELD_NAME'') t_columns,-- columns
	(select [value] from ##Filter where [index]=''USER_NAME'') t_users,-- users
	(select [value] from ##Filter where [index]=''ACTION_ID'') t_actions,-- actions
	(select [value] from ##Filter where [index]=''HOST_NAME'') t_hosts,-- hosts
	(select [value] from ##Filter where [index]=''APP_NAME'') t_apps -- applications
    WHERE  
	t.[DATABASE] like Replace(t_db.[value] ' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'') 
	  AND t.TABLE_SCHEMA like Replace(t_owners.[value] ' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'') 
	  AND t.TABLE_NAME like Replace(t_tables.[value] ' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'') 
      AND d.COL_NAME like Replace(t_columns.[value] 
	' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'')
      AND t.MODIFIED_BY like Replace(t_users.[value] ' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'')
      AND t.MODIFIED_DATE >= @DATE_FROM
      AND t.MODIFIED_DATE < @DATE_TO
      AND Cast(t.AUDIT_ACTION_ID as char(1)) like Replace(t_actions.[value] ' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'')
      AND ((d.OLD_VALUE IS NULL AND @OLD_VALUE = ''%'') OR (d.OLD_VALUE LIKE @OLD_VALUE))
      AND ((d.NEW_VALUE IS NULL AND @NEW_VALUE = ''%'') OR (d.NEW_VALUE LIKE @NEW_VALUE))
      AND t.HOST_NAME like Replace(t_hosts.[value] ' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'')
      AND t.APP_NAME like Replace(t_apps.[value] ' +
	case @ver7 when 0 then ' collate database_default'
		else '' end +
		', ''['', ''[[]'')
) [table]'
if @WHERE IS NOT NULL
begin
	set @WhereSql = @strSql+' where '+@WHERE
	exec sp_executesql @WhereSql
end
else
	exec sp_executesql @strSql
RETURN @@ERROR

GO
/****** Object:  StoredProcedure [dbo].[spEmployeeDoctorList]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spEmployeeDoctorList]  
as  
Begin  
 select e.firstname as 'Employee', e.designation,isnull (d.doctorID,'') as doctorId, isnull( d.customerCode,'') as customerCode, 
		isnull(d.doctorName,'') as doctorName, isnull( s.specialtyName,'') as specialtyName, isnull(d.cityName,'') as cityName, 
		isnull(st.StateName,'') as StateName, isnull(d.hospitalName,'') as hospitalName,d.IsActive       
             from tbldoctors d    
            INNER JOIN tblspecialty s on d.specialtyId = s.specialtyId --and s.isActive = 0    
            INNER JOIN states st on st.StateID = d.stateID      
            INNER join tblempdoc ed on ed.doctorID = d.doctorID    
   inner join Employee e on ed.empid=e.empid  
  
            --where ed.empID = @empID    
   and  d.isactive = 0    
  
   order by e.firstname,d.doctorname,d.hospitalName  
  
End
GO
/****** Object:  StoredProcedure [dbo].[spMedicineUsageTDR]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- exec spMedicineUsageTDR 523, '2023-07-09','2023-07-17'
CREATE proc [dbo].[spMedicineUsageTDR]
(
@EmpId int=null,    
 @StartDate datetime=null,    
 @EndDate datetime=null    
)
as
Begin

	declare @fromdate datetime=null    
 declare @todate datetime=null    
 if (@startDate is not null)    
  begin    
   set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')    
  end    
  if (@EndDate is not null)    
  begin    
   set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')    
  end 

  declare @Designation nvarchar(100)
  set @Designation =''
  Select @Designation=e.designation from Employee e where e.empid=@EmpId

	Select mu.Orderdate,mu.EmpID,e.firstname as EmployeeName,mu.DoctorsID,mu.DoctorsName,max(mu.NoofPatients) as NoofPatients,  count(1) as EntryCount, case when count(1)>=3 then 1 else 0 end as IsTDR 
	from MedicineUsage mu 
		inner join tblPortalBrand pb on mu.medID=pb.medId
			inner join tblPortal p on pb.PortalId=p.portalID
		left outer join Employee e on mu.empid=e.empid
	where p.PortalName='Haemat' 
	and  (@Designation='Admin' or    (@EmpId is null or @EmpId=0 or e.empid is null or e.EmpID=@EmpId))
	--and (e.Designation = 'admin' or (@EmpId is null or @EmpId=0 or e.EmpID=@EmpId))  
   and (@fromdate is null or mu.orderdate>=@fromdate)    
  and (@todate is null or mu.orderdate<=@todate)   
	group by mu.Orderdate,mu.EmpID,e.firstname,mu.DoctorsID,mu.DoctorsName
	having Count(1)>=3
	order by mu.Orderdate,mu.EmpID,e.firstname,mu.DoctorsID,mu.DoctorsName
End
GO
/****** Object:  StoredProcedure [dbo].[USP_ADMIN_DASHBOARD_MEDICINE]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_ADMIN_DASHBOARD_MEDICINE 11, 'SERAVACC'
CREATE PROCEDURE [dbo].[USP_ADMIN_DASHBOARD_MEDICINE] 
( 
	@empId int =0,
    @portalCode NVARCHAR(100) = NULL    
) 
AS 
BEGIN 

    if @portalCode IS NULL
    BEGIN
        set @portalCode = 'CRITIBIZZ'
    END
    SELECT DISTINCT m.name as medicineName, count(1) as TotalNoOfPaitents,sum(mu.noofvials) as TotalVialsSold, count(1) as TotalDoctorsCount 
    FROM MedicineUsage mu 
    INNER JOIN Medicine m on mu.medID=m.medId 
        INNER JOIN tblPortalBrand pb on pb.medId = mu.medID
        INNER JOIN tblPortal p on p.portalID = pb.PortalId
    WHERE m.isactive=1  AND PortalName = @portalCode
    group by m.name 

-- Select distinct m.name as medicineName, count(1) as TotalNoOfPaitents,sum(mu.noofvials) as TotalVialsSold, count(1) as TotalDoctorsCount 
-- 	from MedicineUsage mu 
-- 		inner join Medicine m on mu.medID=m.medId 
-- 	where m.isactive=1 
-- group by m.name 
 
	--Select mu.DoctorsName as Seller ,mu.Speciality as Speciality,mu.Indication,mu.OrderDate, m.name as medicineName,mu.DoctorsName 
	-- , mu.NoOfPatients as noOfPaitents,mu.NoOfVials as noOfVials, mu.HospitalName as hospitalName, mu.HospitalCity as HospitalCity 
	-- ,'' as zoneName 
	--from MedicineUsage mu 
	--	inner join Medicine m on mu.medID=m.medId 
	--where (@empId =0 or mu.EmpID=@empId ) 
End

GO
/****** Object:  StoredProcedure [dbo].[USP_ADMIN_DASHBOARD_MEDICINE_SERAVACC]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_ADMIN_DASHBOARD_MEDICINE_SERAVACC] 
( 
	@empId int =0 
) 
AS 
Begin 
	 
select distinct m.name as medicineName, count(1) as TotalNoOfPaitents,sum(mu.noofvials) as TotalVialsSold, count(1) as TotalDoctorsCount 
	from MedicineUsage mu 
	inner join Medicine m on mu.medID=m.medId 
	where m.isactive=1 and m.portalCode = 'SERAVACC'
    group by m.name 
    --HAVING M.portalCode = 'SERAVACC'
 
	--Select mu.DoctorsName as Seller ,mu.Speciality as Speciality,mu.Indication,mu.OrderDate, m.name as medicineName,mu.DoctorsName 
	-- , mu.NoOfPatients as noOfPaitents,mu.NoOfVials as noOfVials, mu.HospitalName as hospitalName, mu.HospitalCity as HospitalCity 
	-- ,'' as zoneName 
	--from MedicineUsage mu 
	--	inner join Medicine m on mu.medID=m.medId 
	--where (@empId =0 or mu.EmpID=@empId ) 
End

GO
/****** Object:  StoredProcedure [dbo].[USP_ADMIN_REPORT_FILTERS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_ADMIN_REPORT_FILTERS]  
(  
	@empId int, 
    @portalCode NVARCHAR(100) = NULL    
)  
AS  
Begin  
    if @portalCode is NULL 
        begin 
            set @portalCode = 'CRITIBIZZ' 
        end 
   --Employee  
	Select e.empID as displayId, trim(e.firstName) as displayName, * from Employee e  
    where firstname is not null and isActive = 0 
    and Division = @portalCode 
    order by trim(e.firstName)  

    Select m.medID as displayId,m.name as displayName from Medicine m 
    INNER join tblPortalBrand pb on m.medID = pb.medId
    inner join tblPortal p on p.portalID = pb.PortalId
where
1 = 1
and p.PortalName = @portalCode
 -- medId in (17,18,19,20,22,23,25,26) 
 and m.IsActive=1 order by m.name 
  
	-- Medicine  
        if @portalCode = 'CRITIBIZZ' 
            begin 
             --   Select m.medID as displayId,m.name as displayName from Medicine m where medId in (17,18,19,20,22,23,25,26) and m.IsActive=1 order by m.name          
                -- Hospital Name  
            	Select distinct mu.HospitalName as displayId, mu.HospitalName as displayName from MedicineUsage mu  where mediD in (17,18,19,20,22,23,25,26) order by mu.HospitalName  
                Select distinct mu.HospitalCity as displayId, mu.HospitalCity as displayName from MedicineUsage mu where mediD in (17,18,19,20,22,23,25,26) order by mu.HospitalCity  
 
            end 
        ELSE    
            begin 
              --  Select m.medID as displayId,m.name as displayName from Medicine m where medId in (29,30,31) and m.IsActive=1 order by m.name          
                Select distinct mu.HospitalName as displayId, mu.HospitalName as displayName from MedicineUsage mu  where mediD in (29,30,31) order by mu.HospitalName 
                Select distinct mu.HospitalCity as displayId, mu.HospitalCity as displayName from MedicineUsage mu where mediD in (29,30,31) order by mu.HospitalCity  
 
            end  
	-- Hospital City  
 End

GO
/****** Object:  StoredProcedure [dbo].[USP_GET_CHART_RECORDS_v2]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_CHART_RECORDS_v2 6,2023, 396      
create PROCEDURE [dbo].[USP_GET_CHART_RECORDS_v2]
    (      
        @month int,      
        @year int,      
        @empId int      
    )      
AS      
    BEGIN      
  IF OBJECT_ID('tempdb..#empHierarchy') IS NOT NULL   
  BEGIN   
   DROP TABLE #empHierarchy   
  END  
    CREATE TABLE #empHierarchy       
    (       
    levels smallInt,       
    EmpID INT,       
    ParentId int       
    )       
                  
    ;WITH       
    RecursiveCte       
    AS       
    (       
    SELECT 1 as Level, H1.EmpID, H1.ParentId       
        FROM tblHierarchy H1       
        WHERE (@empid is null or ParentID = @empid)       
    UNION ALL       
    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId       
        FROM tblHierarchy H2       
            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID       
    )       
        insert into #empHierarchy       
            (levels, EmpID, ParentId )       
        SELECT Level, EmpID, ParentId       
        FROM RecursiveCte r       
        ;    
      
 Select hp.stateID, hp.StateName, m.name as medicineName, sum(hp.HospitalCount) as HospitalCount,sum(isnull(hp.PotentialTarget,0)) as PotentialTarget,sum(isnull(ha.ActualTarget,0) ) as Target    
	--hp.HospitalCount as HospitalCount,isnull(hp.PotentialTarget,0) as PotentialTarget,isnull(ha.ActualTarget,0) as Target    
 from Medicine m 
	left outer join (
				 Select hp.medid,s.stateid,s.StateName, Count(hp.hospitalid) as HospitalCount, sum(hp.target) as PotentialTarget
				 from TblHospitalsPotentials hp 
				 left outer join spakdb.tblEmpHospitals eh on hp.hospitalID=eh.hospitalID  
				  left outer join Employee e on eh.EmpID = e.EmpID  
				   left outer join [states] s on  e.stateID = s.StateID    
				 where  e.empID in (select EmpID from #empHierarchy)  
				 and year(hp.CreatedDate)=@year and MONTH(hp.CreatedDate)=@month    
				 and s.stateid is not null
				 group by hp.medid,s.stateid,s.StateName
				 ) hp on m.medid=hp.medid
	left outer join (
				 Select ha.medid,s.stateid,s.StateName, Count(ha.hospitalid) as HospitalCount, sum(ha.qty) as ActualTarget
				 from tblHospitalActuals ha 
				 left outer join spakdb.tblEmpHospitals eh on ha.hospitalID=eh.hospitalID  
				  left outer join Employee e on eh.EmpID = e.EmpID  
				   left outer join [states] s on  e.stateID = s.StateID    
				 where  e.empID in (select EmpID from #empHierarchy)  
				 and year(ha.addedfor)=@year and MONTH(ha.addedfor)=@month    
				 and s.stateid is not null
				 group by ha.medid,s.stateid,s.StateName
				 ) ha on m.medid=ha.medid and hp.stateid=ha.stateid
 where m.portalcode='CRITIBIZZ'
	and hp.stateid is not null

 group by hp.stateID, hp.StateName, m.name,hp.HospitalCount 
 order by hp.stateID, hp.StateName, m.name,hp.HospitalCount 
  
  
    drop table #empHierarchy       
      
      
    END 

GO
/****** Object:  StoredProcedure [dbo].[USP_GET_CHART_RECORDS_v2_Ramesh_21072023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_CHART_RECORDS_v2 6,2023, 396      
create PROCEDURE [dbo].[USP_GET_CHART_RECORDS_v2_Ramesh_21072023]    
    (      
        @month int,      
        @year int,      
        @empId int      
    )      
AS      
    BEGIN      
  IF OBJECT_ID('tempdb..#empHierarchy') IS NOT NULL   
  BEGIN   
   DROP TABLE #empHierarchy   
  END  
    CREATE TABLE #empHierarchy       
    (       
    levels smallInt,       
    EmpID INT,       
    ParentId int       
    )       
                  
    ;WITH       
    RecursiveCte       
    AS       
    (       
    SELECT 1 as Level, H1.EmpID, H1.ParentId       
        FROM tblHierarchy H1       
        WHERE (@empid is null or ParentID = @empid)       
    UNION ALL       
    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId       
        FROM tblHierarchy H2       
            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID       
    )       
        insert into #empHierarchy       
            (levels, EmpID, ParentId )       
        SELECT Level, EmpID, ParentId       
        FROM RecursiveCte r       
        ;    
      
Select s.stateID, s.StateName, hp.medicineName, count(h.hospitalId) as HospitalCount,sum(isnull( hp.PotentialTarget,0)) as PotentialTarget,sum(isnull(ha.ActualTarget,0) ) as Target    
from tblHospitals h   
 left outer join(  
      Select hp.MedId,m.name as MedicineName ,hp.hospitalId,sum(isnull(hp.target,0)) as PotentialTarget   
      from TblHospitalsPotentials hp  
       inner join Medicine m on hp.medId=m.medId and m.portalcode='CRITIBIZZ' and year(hp.CreatedDate)=@year and MONTH(hp.CreatedDate)=@month    
      group by hp.MedId,m.name,hp.hospitalId  
     )hp on h.hospitalId=hp.hospitalId  
 left outer join(  
      Select ha.MedId,m.name as MedicineName ,ha.hospitalId,sum(isnull(ha.qty,0)) as ActualTarget   
      from tblHospitalActuals ha  
       inner join Medicine m on ha.medId=m.medId and m.portalcode='CRITIBIZZ'  and year(ha.addedfor)=@year and month(ha.addedfor)=@month  
      group by ha.MedId,m.name,ha.hospitalId       
     )ha on hp.hospitalId=ha.hospitalId and hp.medId=ha.medId  
  
 left outer join spakdb.tblEmpHospitals eh on h.hospitalID=eh.hospitalID  
  left outer join Employee e on eh.EmpID = e.EmpID  
   left outer join [states] s on  e.stateID = s.StateID    
 where e.empID in (select EmpID from #empHierarchy)    
  and hp.medid is not null  
 group by s.stateid, s.statename,hp.medId, hp.MedicineName  
 order by s.stateid, s.statename,hp.medId, hp.MedicineName  
  
  
    drop table #empHierarchy       
      
      
    END 

GO
/****** Object:  StoredProcedure [dbo].[USP_LOG_USER_MEDICINE_DETAILS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  CREATE PROCEDURE [dbo].[USP_LOG_USER_MEDICINE_DETAILS]
    (  	
        @OrderDate date,  	
        @EmpID int,  	
        @MedID int,  	
        @noOfPaitents int,  	
        @DoctorsName nvarchar(100),  	
        @DoctorID nvarchar(50),  	
        @noOfVials int,  	
        @HospitalName nvarchar(200),  	
        @HospitalCity nvarchar(100),  	
        @indication nvarchar(100),  	
        @speciality nvarchar(100),  	
        @prescriptions nvarchar(100),  	
        @strips nvarchar(100),  	
        @TotalValue nvarchar(100),  	
        @arc nvarchar(100),
        @PrescriberType nvarchar(100),
        @Target nvarchar(100)
         
        )  
        AS  Begin  	
        insert into MedicineUsage([EmpID], [medID], [OrderDate], [NoOfPatients], [DoctorsID],      
        [DoctorsName], [NoOfVials], [HospitalName], [HospitalCity], [Indication], [Speciality],     
        [createdDate], prescriptions, strips, TotalValue, arc, PrescriberType, [Target])  	
        values(@EmpID,@MedID,@OrderDate,@noOfPaitents,@DoctorID,@DoctorsName,@noOfVials,@HospitalName,     
        @HospitalCity,@indication,@speciality,getdate(), @prescriptions, @strips, @TotalValue, @arc, @PrescriberType, @Target)    	
        declare @ID int  	
            declare @success bit=0  	
            set @ID =@@identity;    	
            if (@ID>0)  		
                begin  			
                    set @success=1  		
                end  	
            select @success as success  End 

GO
/****** Object:  StoredProcedure [dbo].[USP_PATH2CARE_DAILY_REPORT]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_PATH2CARE_DAILY_REPORT]    
( 
    @dt date = null
) 
AS  
    BEGIN  
        select   
            z.zoneName,  
            dbo.getMyRBMInfo(e.EmpID) as RBM,   
            -- e.EmpID,   
            e.firstName kamName, mu.EmpID from employee e  
            inner join tblZone z on z.zoneID = e.ZoneID  
            --left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN DATEADD(day, -1, CAST(GETDATE() AS date)) and DATEADD(day, -1, CAST(GETDATE() AS date)) 
            left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN @dt and @dt  
        where   
            e.isActive = 0   
            and Division = 'critibizz'  
            and CHARINDEX('KAM', Designation)> 0  
            and mu.EmpID is not null  
        group by z.zoneName, e.EmpID, e.firstName, mu.EmpID  
        -- , mu.NoOfPatients  
        order by ZONENAME, e.firstName  
  
  
        select   
            z.zoneName,  
            dbo.getMyRBMInfo(e.EmpID) as RBM,   
            -- e.EmpID,   
            e.firstName kamName, mu.EmpID from employee e  
            inner join tblZone z on z.zoneID = e.ZoneID  
            --left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN DATEADD(day, -1, CAST(GETDATE() AS date)) and CAST(GETDATE() AS date)  
          left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN @dt and @dt   
        where   
            e.isActive = 0   
            and Division = 'critibizz'  
            and CHARINDEX('KAM', Designation)> 0  
            and mu.EmpID is null  
        -- group by z.zoneName, e.EmpID, e.firstName, mu.EmpID  
        -- , mu.NoOfPatients  
        order by ZONENAME, e.firstName  
  
    END  

GO
/****** Object:  StoredProcedure [dbo].[USP_REPORT_1]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- USP_REPORT_1 468, null, null, null, null, null, null      
      
CREATE PROCEDURE [dbo].[USP_REPORT_1]        
(        
	@empId int =null,        
	@medId int=null,        
	@hospitalName nvarchar(100)=null,        
	@hospitalCity nvarchar(100)=null,        
	@fromDate datetime=null,        
	@toDate datetime=null,      
 	@portalCode NVARCHAR(100) = NULL        
)        
AS        
    Begin        
    -- IF MAKING CHANGE IN THIS SP.. MAKE SURE MAKE CHANGES IN TEH USP_REPORT_1_PATH2CARE_GOOGLE_SHEET AS WELL 
    if @fromDate is null       
        begin       
        set @fromDate = '1-Jan-2022'       
        end       
    if @toDate is null       
        begin       
        set @toDate = '31-Dec-2029'       
        end       
        
    if @portalCode is null  
        begin  
            set @portalCode = 'critibizz'  
        end  
  
Select     
        
       e.firstName as Seller, mu.Speciality as Speciality,mu.Indication,mu.OrderDate, m.name as medicineName,mu.DoctorsName,       
 mu.NoOfPatients as noOfPaitents,mu.NoOfVials as noOfVials, mu.HospitalName as hospitalName, mu.HospitalCity as HospitalCity,      
 z.ZoneName as zoneName,    
 -- '-NA-' as zoneName,    
  e.EmpID, p.PortalName, mu.*      
from MedicineUsage mu        
INNER join Medicine m on mu.medID=m.medId        
inner JOIN Employee e on mu.EmpID=e.EmpID        
inner join tblportalBrand pb on pb.medId = mu.medID    
INNER join tblPortal p on p.PortalId = pb.PortalId   
INNER join tblzone z on z.zoneID = e.ZONEID   
where m.Isactive=1       
and p.PortalName = @portalCode    
and (@medId is null or @medId = 0 or mu.medID = @medId)      
 and (mu.EmpID = @empId or @empId is null )      
and OrderDate BETWEEN @fromDate and @toDate        
    
End       
    

GO
/****** Object:  StoredProcedure [dbo].[USP_REPORT_1_PATH2CARE_GOOGLE_SHEET]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_REPORT_1_PATH2CARE_GOOGLE_SHEET]       
-- (       
-- 	-- @empId int =null,       
-- 	-- @medId int=null,       
-- 	-- @hospitalName nvarchar(100)=null,       
-- 	-- @hospitalCity nvarchar(100)=null,       
-- 	-- @fromDate datetime=null,       
-- 	-- @toDate datetime=null,     
--  	-- @portalCode NVARCHAR(100) = NULL       
-- )       
AS       
    Begin       
    -- ORIGINAL SP USP_REPORT_1 
    declare @fromDate date =  DATEADD(DAY, 1, EOMONTH(getdate(), -1)) 
    declare @toDate date =  getdate() 
    declare @portalCode NVARCHAR(20) = 'PATH2CARE' 
    -- if @fromDate is null      
    --     begin      
    --     set @fromDate = '1-Jan-2022'      
    --     end      
    -- if @toDate is null      
    --     begin      
    --     set @toDate = '31-Dec-2029'      
    --     end      
       
    -- if @portalCode is null 
    --     begin 
    --         set @portalCode = 'critibizz' 
    --     end 
 
    -- select @fromDate, @toDate, @portalCode; 
 
Select    
       
        z.ZoneName as zoneName,  
        e.firstName as Seller,  
        mu.HospitalName as hospitalName,  
        mu.HospitalCity as HospitalCity,  
        mu.Speciality as Speciality,  
        mu.Indication,  
        mu.OrderDate,  
        m.name as medicineName,  
        mu.DoctorsName,  
        mu.NoOfPatients as noOfPaitents, 
        mu.NoOfVials as noOfVial, 
        e.EmpID     
from MedicineUsage mu       
INNER join Medicine m on mu.medID=m.medId       
inner JOIN Employee e on mu.EmpID=e.EmpID       
inner join tblportalBrand pb on pb.medId = mu.medID   
INNER join tblPortal p on p.PortalId = pb.PortalId  
INNER join tblzone z on z.zoneID = e.ZONEID  
where m.Isactive=1      
and p.PortalName = @portalCode   
--and (@medId is null or @medId = 0 or mu.medID = @medId)     
--  and (mu.EmpID = @empId or @empId is null )     
and OrderDate BETWEEN @fromDate  and @toDate      
-- USP_REPORT_1_PATH2CARE_GOOGLE_SHEET  
   
End      
   
   


GO
/****** Object:  StoredProcedure [dbo].[USP_REPORT_SERAVACC]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_REPORT_SERAVACC]  
(  
	@empId int =0,  
	@medId int=0,  
	@hospitalName nvarchar(100)=null,  
	@hospitalCity nvarchar(100)=null,  
	@fromDate datetime=null,  
	@toDate datetime=null  
)  
AS  
Begin  
    if @fromDate is null 
        begin 
            set @fromDate = '1-Jan-2022' 
        end 
    if @toDate is null 
        begin 
            set @toDate = '31-Dec-2029' 
        end 

		Select e.firstName as Seller, mu.Speciality as Speciality, mu.Indication,mu.OrderDate, m.name as medicineName, mu.DoctorsName, mu.NoOfPatients as noOfPaitents,mu.NoOfVials as noOfVials, mu.HospitalName as hospitalName, mu.HospitalCity as HospitalCity, z.ZoneName as zoneName  
	    from MedicineUsage mu  
		left outer join Medicine m on mu.medID=m.medId    
		left outer join Employee e on mu.EmpID=e.EmpID  
		left outer join States s on e.StateID=s.StateID  
		left outer join Zones z on s.ZoneID=z.ZoneID  
    where m.Isactive=1  
    --and m.portalCode = 'SERAVACC'
    and mu.medID = @medId or @medId is NULL 
    and mu.EmpID = @empId or @empId is NULL 
    and OrderDate BETWEEN @fromDate and @toDate     
End 

GO
/****** Object:  StoredProcedure [dbo].[USP_SERAVACC_DAILY_REPORT]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_SERAVACC_DAILY_REPORT]      
(   
    @dt date = null  
)   
AS    
    BEGIN    
        select     
            z.zoneName,    
            dbo.getMyRBMInfo(e.EmpID) as RBM,     
            -- e.EmpID,     
            e.firstName kamName, mu.EmpID from employee e    
            inner join tblZone z on z.zoneID = e.ZoneID    
            --left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN DATEADD(day, -1, CAST(GETDATE() AS date)) and DATEADD(day, -1, CAST(GETDATE() AS date))   
            left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN @dt and @dt    
        where     
            e.isActive = 0     
            and Division = 'SERAVACC'    
            and CHARINDEX('TBM', Designation)> 0    
            and mu.EmpID is not null    
        group by z.zoneName, e.EmpID, e.firstName, mu.EmpID    
        -- , mu.NoOfPatients    
        order by ZONENAME, e.firstName    
    
    
        select     
            z.zoneName,    
            dbo.getMyRBMInfo(e.EmpID) as RBM,     
            -- e.EmpID,     
            e.firstName kamName, mu.EmpID from employee e    
            inner join tblZone z on z.zoneID = e.ZoneID    
            --left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN DATEADD(day, -1, CAST(GETDATE() AS date)) and CAST(GETDATE() AS date)    
          left outer join MedicineUsage mu on mu.empID = e.EmpID and mu.OrderDate BETWEEN @dt and @dt     
        where     
            e.isActive = 0     
            and Division = 'SERAVACC'    
            and CHARINDEX('TBM', Designation)> 0    
            and mu.EmpID is null    
        -- group by z.zoneName, e.EmpID, e.firstName, mu.EmpID    
        -- , mu.NoOfPatients    
        order by ZONENAME, e.firstName    
    
    END 

GO
/****** Object:  StoredProcedure [dbo].[USP_VALIDATE_ADMIN_USER]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_VALIDATE_ADMIN_USER]
	(
	@username nvarchar(100),
	@password nvarchar(100)
	)
AS
	Begin
	if exists(Select 1 from Employee e where e.Email=@username and e.Password=@password and e.Designation='admin')
		begin
			DECLARE @empID int
			Select @empID=e.EmpID from Employee e where e.Email=@username and e.Password=@password  and e.Designation='admin'
			insert into EmployeeLoginLog(EmpID,LoginDate) values(@empID,Getdate())
			--Update Employee set LastLoginDate=GETDATE() where Email=@email and Password=@password
		end
	Select * from Employee e where e.Email=@username and e.Password=@password
End

GO
/****** Object:  StoredProcedure [dbo].[USP_VALIDATE_USER]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_VALIDATE_USER]     
(     
	@email nvarchar(100),     
	@password nvarchar(100),    
    @portalCode nvarchar(20) = NULL    
)     
AS     
Begin     
    -- declare  @portalCode nvarchar(20) = NULL    
    if @portalCode is null    
    BEGIN      
       set @portalCode = 'CRITIBIZZ'    
     --    set @portalCode = 'HAEMAT'    
    END    
    
	if exists(Select 1 from Employee e where e.Email=@email and e.Password=@password and isActive = 0 AND Division = @portalCode)     
		begin     
			DECLARE @empID int     
			Select @empID=e.EmpID from Employee e where e.Email=@email and e.Password=@password     
			insert into EmployeeLoginLog(EmpID,LoginDate) values(@empID,Getdate())     
			--Update Employee set LastLoginDate=GETDATE() where Email=@email and Password=@password     
		end     
	Select * from Employee e where e.Email=@email and e.Password=@password and isActive = 0  AND Division = @portalCode    
End 

GO
/****** Object:  StoredProcedure [hae].[spMedicineUsageSummary]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- exec spMedicineUsageSummary 449, '2023-09-16 00:00:00.000', '2023-09-16 00:00:00.000'    
create proc [hae].[spMedicineUsageSummary]    
(    
 @EmpId int=null,      
 @StartDate datetime=null,      
 @EndDate datetime=null      
)    
as      
Begin      
    
declare @fromdate datetime=null      
 declare @todate datetime=null      
 if (@startDate is not null)      
  begin      
   set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')      
  end      
  if (@EndDate is not null)      
  begin      
   set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')      
  end      
    
Create table #MedicineUsageSummary     
(    
 Zonename    varchar(100),    
 ZBM      varchar(100),    
 RBM      varchar(100),    
 Empid     int,    
 EmployeeName    varchar(100),    
 Designation    varchar(100),    
 OrderDate    Datetime,    
 DoctorsName    varchar(100),    
 Speciality    varchar(100),    
 HospitalName   varchar(100),    
 Indication    varchar(100),    
 Oncyclo_NoOfPatients int,    
 Oncyclo_strips   int,    
 Oncyclo_PapValue  float,    
 Revugam_NoOfPatients int,    
 Revugam_strips   int,    
 Revugam_PapValue  float,    
 Thymogam_NoOfPatients int,    
 Thymogam_strips   int,    
 Thymogam_PapValue float,    
 [Revugam-25_NoOfPatients] int,    
 [Revugam-25_strips]  int,    
 [Revugam-25_PapValue]  float    
)    
    
    
insert into  #MedicineUsageSummary(Zonename,ZBM,RBM, Empid,EmployeeName,Designation ,OrderDate ,DoctorsName ,Speciality ,HospitalName,Indication     
 ,Oncyclo_NoOfPatients,Revugam_NoOfPatients,Thymogam_NoOfPatients,[Revugam-25_NoOfPatients])    
Select       
p.zonename, p.zbm,p.rbm,p.empid,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication      
,sum(isnull(p.Oncyclo,0)) as Oncyclo_NoOfPatients,sum(isnull(p.Revugam,0)) as Revugam_NoOfPatients ,sum(isnull(p.Thymogam,0)) as Thymogam_NoOfPatients,sum(isnull(p.[Revugam-25],0)) as [Revugam-25_NoOfPatients]       
from (      
Select z.ZoneName,hae.getMyZBMInfo(e.empid) as ZBM, hae.getMyRbmInfo(e.empid) as RBM,m.[name] as Medicinename,e.EmpID,e.firstname as employeename      
 ,e.Designation,mu.OrderDate,mu.DoctorsName,mu.Speciality,mu.HospitalName,mu.Indication
 ,isnull(mu.NoOfPatients,0) as NoOfPatients,cast(ISNULL(mu.strips,'0') as int) as strips,isnull(mu.papvalue,0) as PapValue      
from Medicine m       
 inner join MedicineUsage mu on m.medid=mu.medid      
 inner join Employee e on mu.empid=e.empid       
 inner join tblZone z on e.ZoneID = z.ZoneID       
     
   where e.Division = 'HAEMAT' and e.isActive = 0       
   and (@EmpId is null or @EmpId=0 or e.EmpID=@EmpId)    
   and (@fromdate is null or mu.orderdate>=@fromdate)      
  and (@todate is null or mu.orderdate<=@todate)      
 )d      
PIVOT ( Sum(NoOfPatients) for [Medicinename] in ([Oncyclo], [Revugam], [Thymogam], [Revugam-25]))p      
group by p.zonename, p.zbm,p.rbm,p.empid,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication      
    
update mus set Oncyclo_strips=s.Oncyclo_strips, Revugam_strips=s.Revugam_strips, Thymogam_strips =s.Thymogam_strips, [Revugam-25_strips]=s.[Revugam-25_strips]    
from    
(    
Select       
p.zonename, p.zbm,p.rbm,p.empid,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication      
,sum(isnull(p.Oncyclo,0)) as Oncyclo_strips,sum(isnull(p.Revugam,0)) as Revugam_strips ,sum(isnull(p.Thymogam,0)) as Thymogam_strips,sum(isnull(p.[Revugam-25],0)) as [Revugam-25_strips]       
from     
(    
Select z.ZoneName,hae.getMyZBMInfo(e.empid) as ZBM, hae.getMyRbmInfo(e.empid) as RBM,m.[name] as Medicinename,e.EmpID,e.firstname as employeename      
 ,e.Designation,mu.OrderDate,mu.DoctorsName,mu.Speciality,mu.HospitalName,mu.Indication
 ,isnull(mu.NoOfPatients,0) as NoOfPatients,cast(ISNULL(mu.strips,isnull(mu.NoofVials,'0')) as int) as strips,isnull(mu.papvalue,0) as PapValue      
from Medicine m       
 inner join MedicineUsage mu on m.medid=mu.medid       inner join Employee e on mu.empid=e.empid      
  inner join tblZone z on e.ZoneID = z.ZoneID     
   where e.Division = 'HAEMAT' and e.isActive = 0      
   and (@EmpId is null or @EmpId=0 or e.EmpID=@EmpId)    
   and (@fromdate is null or mu.orderdate>=@fromdate)      
  and (@todate is null or mu.orderdate<=@todate)      
 )d      
PIVOT ( Sum(strips) for [Medicinename] in ([Oncyclo], [Revugam], [Thymogam], [Revugam-25]))p      
group by p.zonename, p.zbm,p.rbm,p.empid,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication      
)s inner join #MedicineUsageSummary mus on     
s.empid=mus.empid and s.Employeename=mus.employeename and s.Designation=mus.Designation and s.OrderDate=mus.OrderDate and s.DoctorsName=mus.DoctorsName       
 and s.Speciality=mus.Speciality and s.HospitalName=mus.HospitalName and s.Indication=mus.Indication      
    
    
update mus set Oncyclo_PapValue=s.Oncyclo_PapValue, Revugam_PapValue=s.Revugam_PapValue, Thymogam_PapValue =s.Thymogam_PapValue, [Revugam-25_PapValue]=s.[Revugam-25_PapValue]    
from    
(    
Select       
p.zonename, p.zbm,p.rbm,p.empid,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication      
,sum(isnull(p.Oncyclo,0)) as Oncyclo_PapValue,sum(isnull(p.Revugam,0)) as Revugam_PapValue ,sum(isnull(p.Thymogam,0)) as Thymogam_PapValue,sum(isnull(p.[Revugam-25],0)) as [Revugam-25_PapValue]       
from     
(     
Select  z.ZoneName,hae.getMyZBMInfo(e.empid) as ZBM, hae.getMyRbmInfo(e.empid) as RBM,m.[name] as Medicinename,e.EmpID,e.firstname as employeename      
 ,e.Designation,mu.OrderDate,mu.DoctorsName,mu.Speciality,mu.HospitalName,mu.Indication
 ,isnull(mu.NoOfPatients,0) as NoOfPatients,cast(ISNULL(mu.strips,'0') as int) as strips,isnull(mu.papvalue,0) as PapValue      
from Medicine m       
 inner join MedicineUsage mu on m.medid=mu.medid      
 inner join Employee e on mu.empid=e.empid      
  inner join tblZone z on e.ZoneID = z.ZoneID     
   where e.Division = 'HAEMAT' and e.isActive = 0       
   and (@EmpId is null or @EmpId=0 or e.EmpID=@EmpId)    
   and (@fromdate is null or mu.orderdate>=@fromdate)      
  and (@todate is null or mu.orderdate<=@todate)      
 )d      
PIVOT ( Sum(PapValue) for [Medicinename] in ([Oncyclo], [Revugam], [Thymogam], [Revugam-25]))p        
group by p.zonename, p.zbm,p.rbm,p.empid,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication      
)s inner join #MedicineUsageSummary mus on     
s.empid=mus.empid and s.Employeename=mus.employeename and s.Designation=mus.Designation and s.OrderDate=mus.OrderDate and s.DoctorsName=mus.DoctorsName       
 and s.Speciality=mus.Speciality and s.HospitalName=mus.HospitalName and s.Indication=mus.Indication      
    
    
Select * from #MedicineUsageSummary mus order by mus.OrderDate    
    
drop table #MedicineUsageSummary    
    
End      
GO
/****** Object:  StoredProcedure [hae].[spMedicineUsageSummary_V1]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 -- exec spMedicineUsageSummary 698, '2023-07-01 00:00:00.000', '2023-08-31 00:00:00.000'
create proc [hae].[spMedicineUsageSummary_V1]  
(
 @EmpId int=null,  
 @StartDate datetime=null,  
 @EndDate datetime=null  
)
as  
Begin  

declare @fromdate datetime=null  
 declare @todate datetime=null  
 if (@startDate is not null)  
  begin  
   set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')  
  end  
  if (@EndDate is not null)  
  begin  
   set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')  
  end  

Select pp.zonename,pp.zbm,pp.rbm,pp.Employeename,pp.Designation,pp.OrderDate,pp.DoctorsName,pp.Speciality,pp.HospitalName,pp.Indication  
,pp.Oncyclo_NoOfPatients,ss.Oncyclo_strips,pv.Oncyclo_PapValue  
,pp.Revugam_NoOfPatients,ss.Revugam_strips,pv.Revugam_PapValue  
,pp.Thymogam_NoOfPatients,ss.Thymogam_strips,pv.Thymogam_PapValue  
,pp.[Revugam-25_NoOfPatients],ss.[Revugam-25_strips],pv.[Revugam-25_PapValue]  
from   
(  
Select   
p.zonename, p.zbm,p.rbm,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication  
,isnull(p.Oncyclo,0) as Oncyclo_NoOfPatients,isnull(p.Revugam,0) as Revugam_NoOfPatients ,isnull(p.Thymogam,0) as Thymogam_NoOfPatients,isnull(p.[Revugam-25],0) as [Revugam-25_NoOfPatients]   
from (  
Select z.ZoneName,hae.getMyZBMInfo(e.empid) as ZBM, hae.getMyRbmInfo(e.empid) as RBM,m.[name] as Medicinename,e.firstname as employeename  
 ,e.Designation,mu.OrderDate,mu.DoctorsName,mu.Speciality,mu.HospitalName,mu.Indication  
 ,isnull(mu.NoOfPatients,0) as NoOfPatients,cast(ISNULL(mu.strips,'0') as int) as strips,isnull(mu.papvalue,0) as PapValue  
from Medicine m   
 inner join MedicineUsage mu on m.medid=mu.medid  
 inner join Employee e on mu.empid=e.empid  	
	inner join tblZone z on e.ZoneID = z.ZoneID   
	
   where e.Division = 'HAEMAT' and e.isActive = 0   
   and (@EmpId is null or @EmpId=0 or e.EmpID=@EmpId)
   and (@fromdate is null or mu.orderdate>=@fromdate)  
  and (@todate is null or mu.orderdate<=@todate)  
 )d  
PIVOT ( Sum(NoOfPatients) for [Medicinename] in ([Oncyclo], [Revugam], [Thymogam], [Revugam-25]))p  
)pp  
left outer join   
(  
Select   
p.zonename,p.zbm,p.rbm,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication  
,isnull(p.Oncyclo,0) as Oncyclo_strips,isnull(p.Revugam,0) as Revugam_strips ,isnull(p.Thymogam,0) as Thymogam_strips,isnull(p.[Revugam-25],0) as [Revugam-25_strips]   
from (  
Select z.ZoneName,hae.getMyZBMInfo(e.empid) as ZBM, hae.getMyRbmInfo(e.empid) as RBM,m.[name] as Medicinename,e.firstname as employeename  
 ,e.Designation,mu.OrderDate,mu.DoctorsName,mu.Speciality,mu.HospitalName,mu.Indication  
 ,isnull(mu.NoOfPatients,0) as NoOfPatients,cast(ISNULL(mu.strips,'0') as int) as strips,isnull(mu.papvalue,0) as PapValue  
from Medicine m   
 inner join MedicineUsage mu on m.medid=mu.medid  
 inner join Employee e on mu.empid=e.empid  
 	inner join tblZone z on e.ZoneID = z.ZoneID 
   where e.Division = 'HAEMAT' and e.isActive = 0  
   and (@EmpId is null or @EmpId=0 or e.EmpID=@EmpId)
   and (@fromdate is null or mu.orderdate>=@fromdate)  
  and (@todate is null or mu.orderdate<=@todate)  
 )d  
PIVOT ( Sum(strips) for [Medicinename] in ([Oncyclo], [Revugam], [Thymogam], [Revugam-25]))p  
)ss on pp.Employeename=ss.employeename and pp.Designation=ss.Designation and pp.OrderDate=ss.OrderDate and pp.DoctorsName=ss.DoctorsName   
 and pp.Speciality=ss.Speciality and pp.HospitalName=ss.HospitalName and pp.Indication=ss.Indication  
left outer join   
(  
Select   
p.zonename,p.zbm,p.rbm,p.Employeename,p.Designation,p.OrderDate,p.DoctorsName,p.Speciality,p.HospitalName,p.Indication  
,isnull(p.Oncyclo,0) as Oncyclo_PapValue,isnull(p.Revugam,0) as Revugam_PapValue ,isnull(p.Thymogam,0) as Thymogam_PapValue,isnull(p.[Revugam-25],0) as [Revugam-25_PapValue]   
from (  
Select  z.ZoneName,hae.getMyZBMInfo(e.empid) as ZBM, hae.getMyRbmInfo(e.empid) as RBM,m.[name] as Medicinename,e.firstname as employeename  
 ,e.Designation,mu.OrderDate,mu.DoctorsName,mu.Speciality,mu.HospitalName,mu.Indication  
 ,isnull(mu.NoOfPatients,0) as NoOfPatients,cast(ISNULL(mu.strips,'0') as int) as strips,isnull(mu.papvalue,0) as PapValue  
from Medicine m   
 inner join MedicineUsage mu on m.medid=mu.medid  
 inner join Employee e on mu.empid=e.empid  
 	inner join tblZone z on e.ZoneID = z.ZoneID 
   where e.Division = 'HAEMAT' and e.isActive = 0   
   and (@EmpId is null or @EmpId=0 or e.EmpID=@EmpId)
   and (@fromdate is null or mu.orderdate>=@fromdate)  
  and (@todate is null or mu.orderdate<=@todate)  
 )d  
PIVOT ( Sum(PapValue) for [Medicinename] in ([Oncyclo], [Revugam], [Thymogam], [Revugam-25]))p  
)pv on pp.Employeename=pv.employeename and pp.Designation=pv.Designation and pp.OrderDate=pv.OrderDate and pp.DoctorsName=pv.DoctorsName   
 and pp.Speciality=pv.Speciality and pp.HospitalName=pv.HospitalName and pp.Indication=pv.Indication  
  
  
End  
  
  
GO
/****** Object:  StoredProcedure [hae].[USP_BSV_GET_PERSON_LIST]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hae].[USP_BSV_GET_PERSON_LIST]
AS
SELECT * FROM Person
GO;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_DASHBOARD]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_DASHBOARD 'khushbu.kumari@bsvl.com', 'BSV@112233'       
----------------------------------------------       
-- CREATED BY: GURU SINGH       
-- CREATD DATE: 9-SEP-2021       
----------------------------------------------       
CREATE procedure [hae].[USP_BSVHR_DASHBOARD] 
     
as 
set NOCOUNT on;
    BEGIN
        select count(*) as TotalEmployees from employee where isActive = 0
        select count(*) as TotalHospitals from tblhospitals where isActive = 0
        -- select count(*) from tblhospitals h
        --     INNER join tblEmpHospitals eh on  eh.hospitalId = h.hospitalID
        -- where isActive = 0
    END
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_DELETE_EMPLOYEE]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_DELETE_EMPLOYEE 'khushbu.kumari@bsvl.com', 'BSV@112233'        
----------------------------------------------        
-- CREATED BY: GURU SINGH        
-- CREATD DATE: 9-SEP-2021        
----------------------------------------------        
CREATE procedure [hae].[USP_BSVHR_DELETE_EMPLOYEE]  
     ( 
         @empId int 
     ) 
as  
set NOCOUNT on; 
    BEGIN 
            update employee  
                set isActive = 1 
            where empID = @empId 
         select 'true' as success, 'record deleted sucessfully ' as msg
    END 
set NOCOUNT off; 
 
 

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_DELETE_HOSPITAL]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [hae].[USP_BSVHR_DELETE_HOSPITAL] 
	@hospitalId  int	
AS 
   BEGIN  
	set nocount on
		-- DELETE FROM tblhospitals WHERE hospitalID = @hospitalId
		update tblhospitals  set isactive = 1
			WHERE hospitalID = @hospitalId
   END 

   



   

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_GET_EMPLOYEE_AND_MANAGER]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_GET_EMPLOYEE_AND_MANAGER 'khushbu.kumari@bsvl.com', 'BSV@112233'       
----------------------------------------------       
-- CREATED BY: GURU SINGH       
-- CREATD DATE: 9-SEP-2021       
----------------------------------------------       
CREATE procedure [hae].[USP_BSVHR_GET_EMPLOYEE_AND_MANAGER] 
     (
         @empId int

     )
as 
set NOCOUNT on;
    BEGIN
            
        select firstName, Designation from employee
            where empId = @empId
        
        select firstName, Designation from employee
            where empId in (
                select parentID from tblhierarchy where EmpID = @empId
            )
       
    END
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_GET_EMPLOYEE_DETAILS_BY_ID]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_GET_EMPLOYEE_DETAILS_BY_ID 'khushbu.kumari@bsvl.com', 'BSV@112233'        
----------------------------------------------        
-- CREATED BY: GURU SINGH        
-- CREATD DATE: 9-SEP-2021        
----------------------------------------------        
CREATE procedure [hae].[USP_BSVHR_GET_EMPLOYEE_DETAILS_BY_ID]  
     ( 
         @empId int 
     ) 
as  
set NOCOUNT on; 
    BEGIN 
            select EmpNumber, designation, firstName, Email  
        ,MobileNumber, zoneName, StateName ,hqcode as HoCode  
        ,HQName, RegionName,   Password,
         
        convert(nvarchar(20), doj, 106) as DOJ,  
        case   
            when e.isActive = 0 then 'Yes'  
            else 'No'  
            end  as isDisabled  , e.ZoneID, e.StateID, DesignationID
        ,empId, comments from employee e  
        INNER join tblzone z on e.zoneid = z.zoneID   
        inner join states s on s.stateID = e.stateID  
          
 
            where empID = @empId 
        
    END 
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_GET_HOSPITAL_DETAILS_BY_ID]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hae].[USP_BSVHR_GET_HOSPITAL_DETAILS_BY_ID] 
	@hospitalId int	
AS 
	BEGIN  
		set nocount on
			select * from tblhospitals
			where hospitalID = @hospitalId
	END 

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_GET_MANAGER_LIST]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_GET_MANAGER_LIST 525       
----------------------------------------------        
-- CREATED BY: GURU SINGH        
-- CREATD DATE: 9-SEP-2021        
----------------------------------------------        
CREATE procedure [hae].[USP_BSVHR_GET_MANAGER_LIST]  
     ( 
         @empId int 
 
     ) 
as  
set NOCOUNT on; 
    BEGIN 
        declare @designation nvarchar(10)     
        declare @zoneID int 
        select @designation = designation, @zoneId = zoneID from employee where empID = @empId 
        -- select @designation 
        if CHARINDEX('kam', @designation)  > 0  
            BEGIN 
                select empId, firstname + ' ('+designation+')' as Name from employee where isActive = 0 and designation = 'RBM' and zoneid = @zoneId 
            END  
        else if CHARINDEX('RBM', @designation)  > 0   
            BEGIN 
                select empId, isNull(firstname + ' ('+designation+')', '-NA-') as Name from employee where isActive = 0 and designation = 'ZBM' and zoneid = @zoneId 
            END  
        else  
            BEGIN 
                select empId, firstname + ' ('+designation+')' as Name from employee where isActive = 0 and designation = 'BU' 
            END  
 
 
        
    END 
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_GET_MASTER_DATA]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_GET_MASTER_DATA 'khushbu.kumari@bsvl.com', 'BSV@112233'       
----------------------------------------------       
-- CREATED BY: GURU SINGH       
-- CREATD DATE: 9-SEP-2021       
----------------------------------------------       
CREATE procedure [hae].[USP_BSVHR_GET_MASTER_DATA] 
     
as 
set NOCOUNT on;
    BEGIN
        select zoneID, zoneName from tblzone where isActive = 1
        select stateId, stateName from states 
        select designationId, designationname as designation from Designation -- order by designationid desc
       
    END
set NOCOUNT off;



GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_GET_UN_ASSINGED_HOSPITALS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [hae].[USP_BSVHR_GET_UN_ASSINGED_HOSPITALS]

AS

BEGIN

select hospitalId, hospitalName, regionName from tblhospitals where isActive = 0 

	and hospitalid NOt in (

			select hospitalID from tblempHOspitals group by hospitalID 

	)

	

END

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_LIST_EMPLOYEES]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [hae].[USP_BSVHR_LIST_EMPLOYEES]   
       
as   
set NOCOUNT on;  
    BEGIN  
        select empnumber, designation, firstName, email, mobileNumber, zoneName, StateName ,hqcode as hocode, hqname, regionName,   
        convert(nvarchar(20), doj, 106) as doj,  
        case   
            when e.isActive = 0 then 'Yes'  
            else 'No'  
            end  as isDisabled, empId, comments, Division from employee e  
        INNER join tblzone z on e.zoneid = z.zoneID   
        inner join states s on s.stateID = e.stateID  
         where e.isActive = 0 -- ajay uncommented on 20-04-2023 
    END  
set NOCOUNT off; 

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_LIST_HOSPITAL]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [hae].[USP_BSVHR_LIST_HOSPITAL]
as
	begin
			select hospitalName, regionName
			, isNull(totalBed,0) as bedNo
			, isNull(ICUbed,0) as ICUbedNo
			, hospitalId from tblhospitals where isactive = 0

	end

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_REMOVE_HOSPITAL_FROM_EMP_LIST]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------
-- CREATED BY: GURU SINGH
-- CREATED DATE: 4-JUL-2023
----------------------------------------------
CREATE PROCEDURE [hae].[USP_BSVHR_REMOVE_HOSPITAL_FROM_EMP_LIST]
(
    @empId INT,
    @hospitalId INT

)
AS
    BEGIN
        IF EXISTS (SELECT 1 FROM tblEmpHospitals WHERE EmpID = @empId AND hospitalId = @hospitalId)
            BEGIN
                DELETE FROM tblEmpHospitals WHERE EmpID = @empId AND hospitalId = @hospitalId
                SELECT 'true' as flag, 'Hospital removed successfully' as msg
            END
        ELSE    
            BEGIN
                SELECT 'false' as flag, 'Hospital does not exists' as msg
            END
    END

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_UPDATE_EMP_HOSPITAL_LIST]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_UPDATE_EMP_HOSPITAL_LIST 524       
----------------------------------------------       
-- CREATED BY: GURU SINGH       
-- CREATD DATE: 9-SEP-2021       
----------------------------------------------       
CREATE procedure [hae].[USP_BSVHR_UPDATE_EMP_HOSPITAL_LIST] 
     (
         @empId int

     )
as 
set NOCOUNT on;
    BEGIN
        SELECT  hospitalName, regionName, H.hospitalId  FROM TBLHOSPITALS H
            INNER JOIN TBLEMPHOSPITALS EH ON H.HOSPITALID = EH.HOSPITALID
        WHERE EH.EMPID = @empId
        GROUP BY hospitalName, regionName, H.hospitalId
    END
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_UPDATE_EMPLOYEE_DETAILS_BY_ID]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_UPDATE_EMPLOYEE_DETAILS_BY_ID 'khushbu.kumari@bsvl.com', 'BSV@112233'        
----------------------------------------------        
-- CREATED BY: GURU SINGH        
-- CREATD DATE: 9-SEP-2021        
----------------------------------------------        
CREATE procedure [hae].[USP_BSVHR_UPDATE_EMPLOYEE_DETAILS_BY_ID]  
     ( 
         @empId int, 
         @firstName NVARCHAR(200), 
         @MobileNumber NVARCHAR(200), 
         @Password NVARCHAR(200), 
         @Designation NVARCHAR(200), 
         @DesignationID NVARCHAR(200), 
         @EmpNumber NVARCHAR(200), 
         @HoCode NVARCHAR(200), 
         @ZoneID int, 
         @StateID int, 
         @HQName NVARCHAR(200), 
         @RegionName NVARCHAR(200), 
         @DOJ NVARCHAR(200), 
         @isDisabled bit, 
         @comments NVARCHAR(200), 
         @email NVARCHAR(200) 
 
     ) 
as  
set NOCOUNT on; 
    BEGIN 
             
        if @empId is NULL 
            BEGIN 
                declare @employeeId int;

                insert into employee  (Password,  Email,  firstName, middleName, lastName,  
                    DesignationID, MobileNumber, HQName,  
                    EmpNumber, StateID, Comments, DOJ, HQCode, ZoneID,  
                    regionName, isActive) 
                VALUES ( 
                    @Password, @email, @firstName, null, null,  
                    @DesignationID, @MobileNumber, @HQName, 
                    @EmpNumber, @StateID, @comments, @DOJ, @HoCode, @ZoneID, 
                    @RegionName, @isDisabled 
                ) 
                set @employeeId =  @@identity   
 
                update employee set 
                --Designation = designationName                 
                Designation = DesignationName                 
                from employee e  
                inner join designation d on d.DesignationId = e.DesignationID 
                where e.EmpID = @employeeId 
 
                select 'true' as sucess, 'user added successfully ' as msg 
            END 
        else  
            BEGIN 
                    update employee set  
                        [Password] = @Password,   
                        Email = @email,   
                        firstName = @firstName,  
                        DesignationID = @DesignationID,  
                        MobileNumber = @MobileNumber,  
                        HQName = @HQName,  
                        EmpNumber = @EmpNumber,  
                        StateID = @StateID,  
                        Comments = Comments + '<br>' +@comments,  
                        DOJ = @DOJ,  
                        HQCode = @HoCode,  
                        ZoneID = @ZoneID,  
                        regionName = @RegionName,  
                        isActive = @isDisabled 
 
                    where empID = @empID 
 
 
                     update employee set 
                Designation = designationName 
                from employee e  
                    inner join designation d on d.DesignationId = e.DesignationID 
                where e.EmpID = @empID 
 
                    select 'true' as sucess, 'user updated successfully ' as msg 
            END 
        
    END 
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_UPDATE_HOSPITAL_DETAILS_BY_ID]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [hae].[USP_BSVHR_UPDATE_HOSPITAL_DETAILS_BY_ID] 
	@hospitalId  int,
	@name varchar(50),
	@regionName varchar(100),
	@isDisabled bit    
AS 
   BEGIN  
	set nocount on
      -- SQL statements  
      -- SELECT, INSERT, UPDATE, or DELETE statement  
	  select * from tblhospitals
	  if @hospitalId is null
		begin
			insert into tblhospitals (hospitalName, regionName, isactive)
				values (@name, @regionName, 0)
				select 'true' as success, 'hospital created sucessfully' as msg
		end
	  else
		begin
			update tblhospitals set
				hospitalName = @name,
				regionName = @regionName,
				isActive = @isDisabled
			WHERE hospitalID = @hospitalId
			select 'true' as success, 'hospital udpated sucessfully' as msg 
		end
   END  

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_UPDATE_MANAGER]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_BSVHR_UPDATE_MANAGER 524       
----------------------------------------------       
-- CREATED BY: GURU SINGH       
-- CREATD DATE: 9-SEP-2021       
----------------------------------------------       
CREATE procedure [hae].[USP_BSVHR_UPDATE_MANAGER] 
     (
         @empId int,
         @parentId int

     )
as 
set NOCOUNT on;
    BEGIN
        
        if exists (select 1 from tblhierarchy where empId = @empId)
            BEGIN
                delete from tblhierarchy where empId = @empId
            END
        insert into tblhierarchy (empID, ParentID)
            VALUES(@EmpID, @parentId)
       select 'true' as success, 'record updated sucessfully ' as msg
    END
set NOCOUNT off;

GO
/****** Object:  StoredProcedure [hae].[USP_BSVHR_UPDATE_UN_ASSINGED_HOSPITALS_TO_EMPLOYEE]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create procedure [hae].[USP_BSVHR_UPDATE_UN_ASSINGED_HOSPITALS_TO_EMPLOYEE]
(
	@empID int,
	@hospitalId int
)
as
	begin
		if exists (select 1 from tblempHospitals where hospitalID  = @hospitalId)
			begin
				delete from tblempHospitals where hospitalID  = @hospitalId
			end
		insert into tblempHospitals (empId, hospitalID)
			values (@empID, @hospitalId)
	end

GO
/****** Object:  StoredProcedure [hae].[USP_GET_ADMIN_REPORT_FILTER_CRITIBIZZ]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------- 
-- CREATED BY: GURU SINGH 
-- CREATED DATE: 19-APR-2023 
------------------------------------------- 
CREATE procedure [hae].[USP_GET_ADMIN_REPORT_FILTER_CRITIBIZZ]  
as  
begin 
	 select h.hospitalName, h.hospitalId, h.regionName from tblhospitals h 
	 inner join tblemphospitals eh on eh.hospitalid = h.hospitalid  
	 and h.isactive = 0 
     -- group by h.hospitalname, h.hospitalId, h.regionName
 
	 select s.stateid, s.statename from states s order by s.statename 
 
	 select m.medID as 'medId', m.name as 'medicineName' from medicine m 
	 where m.portalcode = 'CRITIBIZZ' and m.isactive = 1 
	 order by m.name  
 
	  select e.firstname as 'firstName', e.designation as Designation, e.designationId, e.EmpID as 'EmpID' from employee e 
	 where  CHARINDEX('KAM', e.designation) > 0 and e.isactive = 0 
 
	 select e.firstname as 'firstName', e.designation  as Designation, e.designationId, e.EmpID as EmpID, e.isactive
    , ZoneName as designZone
     from employee e 
     inner join tblzone z on z.ZoneID = e.ZoneID
	 where e.designation in ('rbm','zbm') and e.isactive = 0 
 
	 select z.zoneid as 'zoneID', z.zonename as 'name' from tblZone z 
	 where z.isActive = 1 
 
end 
 
--select CHARINDEX('@', 'someone@somewhere.com') 
 
 
 --select e.firstname, e.designation, e.designationId, e.EmpID from employee e 
	-- where  CHARINDEX('KAM', e.designation) > 0 and e.isactive = 0 
 
	--select * from tblZone	 
	--select * from Zones 
 
	

GO
/****** Object:  StoredProcedure [hae].[USP_GET_ALL_EMPLOYEES_UNDER_ME_v1]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_ALL_EMPLOYEES_UNDER_ME_v1  511 
create PROCEDURE [hae].[USP_GET_ALL_EMPLOYEES_UNDER_ME_v1] 
    ( 
        @empId int
    ) 
AS 
    set NOCOUNT ON   
	
        select EmpID, EmpNumber, firstName, Designation, Email, MobileNumber from employee where empID in (
            select empID from tblhierarchy where ParentID = @empID
        )

        select count(*) as HospitalCount from tblEmpHospitals where empid = @empID

    set NOCOUNT off; 
 
     
        
         

GO
/****** Object:  StoredProcedure [hae].[USP_GET_CHART_RECORDS_v2_bk19072023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--drop proc USP_GET_CHART_RECORDS_v2
--go
-- USP_GET_CHART_RECORDS_v2 6,2023, 396  
create PROCEDURE [hae].[USP_GET_CHART_RECORDS_v2_bk19072023]  
    (  
        @month int,  
        @year int,  
        @empId int  
    )  
AS  
    BEGIN  
  
    CREATE TABLE #empHierarchy   
    (   
    levels smallInt,   
    EmpID INT,   
    ParentId int   
    )   
              
    ;WITH   
    RecursiveCte   
    AS   
    (   
    SELECT 1 as Level, H1.EmpID, H1.ParentId   
        FROM tblHierarchy H1   
        WHERE (@empid is null or ParentID = @empid)   
    UNION ALL   
    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId   
        FROM tblHierarchy H2   
            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID   
    )   
        insert into #empHierarchy   
            (levels, EmpID, ParentId )   
        SELECT Level, EmpID, ParentId   
        FROM RecursiveCte r   
        ;   
  
                          
        --select   
        --    s.stateID, s.StateName, h.hospitalname, 99 as Target, 999 as PotentialTarget, 'Amphonex' as medicineName  
        --    -- e.empID, firstName, e.MobileNumber, email, EmpNumber, HQCode, HQName, designation,   
        --    --       s.StateName,              DOJ, trim(replace(e.regionName,' ','')) as regionName,   
        --    -- eh.hospitalId, h.hospitalname        
  
        --from Employee e           
        --inner join [states] s on s.stateID = e.StateID      
        --inner join tblEmpHospitals eh on eh.EmpID = e.EmpID          
        --inner join tblhospitals h on eh.hospitalId = h.hospitalID  
        --where e.empID in (select EmpID from #empHierarchy)   
        --order by designation       
  select   
            s.stateID, s.StateName,m.medID,  m.name as medicinename, sum(isnull(hp.target,0)) as PotentialTarget, sum(isnull(ha.qty,0)) as ActualTarget
			--, 99 as Target, 999 as PotentialTarget, 'Amphonex' as medicineName  
            -- e.empID, firstName, e.MobileNumber, email, EmpNumber, HQCode, HQName, designation,   
            --       s.StateName,              DOJ, trim(replace(e.regionName,' ','')) as regionName,   
            -- eh.hospitalId, h.hospitalname        
  
        from Employee e           
        inner join [states] s on s.stateID = e.StateID      
        inner join tblEmpHospitals eh on eh.EmpID = e.EmpID          
        inner join tblhospitals h on eh.hospitalId = h.hospitalID  
			left outer join TblHospitalsPotentials hp on h.hospitalid =hp.hospitalid and year(hp.CreatedDate)=@year and MONTH(hp.CreatedDate)=@month
				left outer join Medicine m on hp.medid=m.medid
				left outer join tblHospitalActuals ha on hp.hospitalid=ha.hospitalid and hp.medid=ha.medid and year(ha.addedfor)=@year and month(ha.addedfor)=@month
        where e.empID in (select EmpID from #empHierarchy)   
		and m.medid is not null
		group by s.stateID, s.StateName,m.medID,  m.name
		order by s.stateID, s.StateName,m.medID,  m.name
  
    drop table #empHierarchy   
  
  
    END   

GO
/****** Object:  StoredProcedure [hae].[USP_GET_HOSPITALS_LIST_FROM_EMP]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_HOSPITALS_LIST_FROM_EMP  404, 3,2023 
create PROCEDURE [hae].[USP_GET_HOSPITALS_LIST_FROM_EMP] 
    ( 
        @empId int,
        @month int,
        @year int
    ) 
AS 
    set NOCOUNT ON   
	
        select  h.hospitalId, h.hospitalName, h.regionName 
        ,sum(isNull(hp.[target],0)) as TotalPotential 
        ,dbo.getSumOfHospitalActuals(h.hospitalID, @month, @year) as totalActual
       
        from tblhospitals h
        inner join tblemphospitals eh on h.hospitalID = eh.hospitalId
           left outer join tblhospitalspotentials hp on hp.hospitalID = h.hospitalID and hp.isActive = 0
        where eh.EmpID = @empId
        group by h.hospitalId, h.hospitalName, h.regionName

    set NOCOUNT   OFF;

GO
/****** Object:  StoredProcedure [hae].[USP_GET_MEDICINES_LIST]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MEDICINES_LIST  'CRITIBIZZ'    

CREATE PROCEDURE [hae].[USP_GET_MEDICINES_LIST]    

(        

    @portalCode NVARCHAR(100) = NULL   

)    

AS        

    BEGIN           

         select  m.name, m.imageURL, m.medID, m.descp, m.objective from medicine M                    

                    inner join tblPortalBrand PB ON PB.medID = M.medID                   

                    inner join tblPortal p on p.portalID = pb.PortalId                   

                    where p.PortalName =  @portalCode  -- and m.medID = 24           

                    order by m.name ASC   

        -- if @portalCode is null               

        --     BEGIN                   

        --         select * from medicine M                    

        --         inner join tblPortalBrand PB ON PB.medID = M.medID                    

        --         where portalCode <> 'SERAVACC'              

        --         order by m.name ASC                

        --     END           

        -- ELSE                   

        --     BEGIN               

        --         select * from medicine M                    

        --             inner join tblPortalBrand PB ON PB.medID = M.medID                   

        --             inner join tblPortal p on p.portalID = pb.PortalId                   

        --             where p.PortalName =  'CRITIBIZZ'              

        --             order by m.name ASC                

        --     END                     

    END  

 

 

GO
/****** Object:  StoredProcedure [hae].[USP_GET_MY_CHILD_RECORDS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_MY_CHILD_RECORDS  511 
create PROCEDURE [hae].[USP_GET_MY_CHILD_RECORDS] 
    ( 
        @empId int 
    ) 
AS 
    BEGIN 
 
    CREATE TABLE #empHierarchy  
    (  
    levels smallInt,  
    EmpID INT,  
    ParentId int  
    )  
             
    ;WITH  
    RecursiveCte  
    AS  
    (  
    SELECT 1 as Level, H1.EmpID, H1.ParentId  
        FROM tblHierarchy H1  
        WHERE (@empid is null or ParentID = @empid)  
    UNION ALL  
    SELECT RCTE.level + 1 as Level, H2.EmpID, H2.ParentId  
        FROM tblHierarchy H2  
            INNER JOIN RecursiveCte RCTE ON H2.ParentId = RCTE.EmpID  
    )  
        insert into #empHierarchy  
            (levels, EmpID, ParentId )  
        SELECT Level, EmpID, ParentId  
        FROM RecursiveCte r  
        ;  
 
        select 1 as output 
 
        select 
            h.hospitalId, h.hospitalName , firstName as EmpName,  
            h.regionName,  
            e.empNumber as EmpNumber, 
            -- e.regionName,  
            trim(replace(e.regionName,' ','')) as empregionName, 
            trim(replace(h.regionName,' ','')) as hospitalregionName, 
            e.EmpID, 
            isNull(h.totalBed,0) as bedNo, 
            isNull(h.icuBed,0) as ICUbedNo, 
            spakdb.getHospitalPotential(h.hospitalId, 17) as 'AGCuffill', 
            spakdb.getHospitalPotential(h.hospitalId, 18) as 'Amphonex', 
            spakdb.getHospitalPotential(h.hospitalId, 19) as 'Octaplex', 
            spakdb.getHospitalPotential(h.hospitalId, 20) as 'Thymogam', 
            spakdb.getHospitalPotential(h.hospitalId, 22) as 'Plasmanate', 
            spakdb.getHospitalPotential(h.hospitalId, 23) as 'PolyMxB', 
            spakdb.getHospitalPotential(h.hospitalId, 24) as 'UTryp' 
        from Employee e          
        inner join [states] s on s.stateID = e.StateID     
        inner join tblEmpHospitals eh on eh.EmpID = e.EmpID         
        inner join tblhospitals h on eh.hospitalId = h.hospitalID 
        where e.empID in (select EmpID from #empHierarchy)  
        order by designation      
 
 
    drop table #empHierarchy  
 
 
    END  

GO
/****** Object:  StoredProcedure [hae].[USP_GET_STATE_MANAGERS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_GET_STATE_MANAGERS  511 
create PROCEDURE [hae].[USP_GET_STATE_MANAGERS] 
    ( 
        @stateName NVARCHAR(200) 
    ) 
AS 
    set NOCOUNT ON   
    select firstname, designation from Employee e   
        inner join states s on e.StateID = s.StateID 
        -- inner join tblhierarchy h on e. 
        where trim(replace(s.StateName,' ','')) = trim(replace('UTTAR PRADESH', ' ','')) 
        order by Designation 
    set NOCOUNT off; 
 
     
        
         

GO
/****** Object:  StoredProcedure [hae].[USP_HAEMAT_ADD_ORDER_DETAILS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_HAEMAT_ADD_ORDER_DETAILS 1000, 2, 2, '1-May-2023', 10     

------------------------------     -- CREATED BY: GURU SINGH   -- CREATED DATE: 24-MAY-2023     ------------------------------     

CREATE PROCEDURE [hae].[USP_HAEMAT_ADD_ORDER_DETAILS]     

(      

   @doctorId INT,         

   @empID int,         

   @medId int,         

   @orderDate date,         

   @NoOfVials int,       

   @NoOfStrips int,       

   @NoOfPatients int,      

   @papValue int,     

   @indication NVARCHAR(50),

   @EntryID NVARCHAR(100)=null

)     

AS         

Begin



  -- SELECT top 10 * FROM MedicineUsage             

  declare  @doctorCode NVARCHAR(100),  @doctorName NVARCHAR(100),  @HospitalName NVARCHAR(100),  @HospitalCity NVARCHAR(100),@Speciality NVARCHAR(100);                       

  select @doctorCode = d.customerCode,                   

		@doctorName = d.doctorName,                    

		@HospitalCity = d.cityName,                   

		@HospitalName = d.hospitalName,                  

		@Speciality = s.specialtyName                  

  from tbldoctors d                     

	INNER JOIN tblspecialty s on s.specialtyId = d.specialtyId and s.isActive = 0                 

  where d.doctorID = @doctorId                              

  -- select @doctorCode, @doctorName, @HospitalCity, @HospitalName, @Speciality                                       

  insert into MedicineUsage (empId, medID, orderDate, DoctorsID, DoctorsName, NoOfVials, HospitalName, HospitalCity

	, Indication, Speciality, CreatedDate, NoOfPatients, strips, papValue, EntryID)                 

  VALUES(@empID, @medId, @orderDate, @doctorCode, @doctorName, @NoOfVials, @HospitalName, @HospitalCity

	, @indication, @Speciality, GETDATE(), @NoOfPatients, @NoOfStrips, @papValue,@EntryID )

	

                 select 'true' as flag, 'Record added successfully' as msg        

End
GO
/****** Object:  StoredProcedure [hae].[USP_HAEMAT_ADMIN_REPORT]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec USP_HAEMAT_ADMIN_REPORT null, '2023-08-16 00:00:00.000', '2023-08-16 00:00:00.000'

CREATE PROCEDURE [hae].[USP_HAEMAT_ADMIN_REPORT]    
(  
 @EmpId int=null,
 @StartDate datetime=null,
	@EndDate datetime=null
)  
AS    
BEGIN    
-- 01-Jul-2023  Ramesh Ubbu  Added EmployeeName in select list  
  
  declare @fromdate datetime=null
	declare @todate datetime=null
	if (@startDate is not null)
		begin
			set @fromdate=DATEADD(DAY, DATEDIFF(DAY, '19000101', @StartDate), '19000101')
		end
		if (@EndDate is not null)
		begin
			set @todate=DATEADD(DAY, DATEDIFF(DAY, '19000101',@EndDate), '23:59:59')
		end


    select OrderDate, z.ZoneName, e.firstName, --m.DoctorsID, m.DoctorsName, m.Speciality, m.HospitalName,     
    --m.hospitalCity, m.Indication,  
	m.*   
 ,e.firstName as EmployeeName  
 from MedicineUsage m    
    INNER JOIN tblPortalbrand pb on pb.medId = m.medID    
    INNER join tblPortal p on p.portalID = pb.PortalId and p.isActive = 0    
    inner join Employee e on e.EmpID = m.EmpID  and e.Division = 'HAEMAT' and e.isActive = 0    
    inner join tblZone z on z.zoneId = e.ZoneID    
    WHERE p.PortalName = 'HAEMAT'    
		and (@fromdate is null or m.orderdate>=@fromdate)
		and (@todate is null or m.orderdate<=@todate)
    order by m.OrderDate asc    
    
    
    
    select m.*,e.firstName as EmployeeName from MedicineUsage m    
    inner join Employee e on e.EmpID = m.EmpID  and e.Division = 'HAEMAT' and e.isActive = 0    
    INNER JOIN tblPortalbrand pb on pb.medId = m.medID    
    INNER join tblPortal p on p.portalID = pb.PortalId and p.isActive = 0    
    WHERE p.PortalName = 'HAEMAT'  
	and (@fromdate is null or m.orderdate>=@fromdate)
		and (@todate is null or m.orderdate<=@todate)
    order by MedicineUsageId desc    
    
END    
GO
/****** Object:  StoredProcedure [hae].[USP_HAEMAT_GET_DOC_DETAILS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_HAEMAT_GET_DOC_DETAILS 1000
------------------------------
-- CREATED BY: GURU SINGH
-- CREATED DATE: 24-MAY-2023
------------------------------
CREATE PROCEDURE [hae].[USP_HAEMAT_GET_DOC_DETAILS]
(
    @doctorId INT = NULL
)
as
    set NOCOUNT on;
        select d.doctorID, d.customerCode, d.doctorName,  s.specialtyName, 
             d.cityName, st.StateName, d.hospitalName   
             from tbldoctors d
            INNER JOIN tblspecialty s on s.specialtyId = d.specialtyId and s.isActive = 0
            INNER JOIN states st on st.StateID = d.stateID  
            where d.doctorID = @doctorId

            EXEC USP_GET_MEDICINES_LIST 'HAEMAT'
                
    set NOCOUNT off; 


GO
/****** Object:  StoredProcedure [hae].[USP_HAEMAT_GET_DOC_LIST]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------    
-- CREATED BY: GURU SINGH    
-- CREATED DATE: 24-MAY-2023    
------------------------------  
-- exec USP_HAEMAT_GET_DOC_LIST 702  
CREATE PROCEDURE [hae].[USP_HAEMAT_GET_DOC_LIST]    
(    
    @empID INT = NULL    
)    
as    
--  
    set NOCOUNT on;    
        select distinct d.doctorID, d.customerCode, d.doctorName,  s.specialtyName,     
             d.cityName, st.StateName, d.hospitalName,d.IsActive       
             from tbldoctors d    
            INNER JOIN tblspecialty s on d.specialtyId = s.specialtyId --and s.isActive = 0    
            INNER JOIN states st on st.StateID = d.stateID      
            INNER join tblempdoc ed on ed.doctorID = d.doctorID    
            where ed.empID = @empID    
   and  d.isactive = 0    
               
  order by d.doctorname  
    set NOCOUNT off; 
GO
/****** Object:  StoredProcedure [hae].[USP_HOSPITAL_DETAILS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_HOSPITAL_DETAILS  875, 3,2023 
create PROCEDURE [hae].[USP_HOSPITAL_DETAILS] 
    ( 
        @hospitalId int,
        @month int,
        @year int
    ) 
AS 
    set NOCOUNT ON   
	
        select hospitalID, hospitalName, regionName, isNull(totalBed,0) as totalBed, isNull(icuBed,0) as icuBed
        from tblhospitals where hospitalID =@hospitalId

            
            select 
                m.medID, imageUrl, 
                dbo.getSumOfHospitalActualsforMed(@hospitalId, @month, @year, m.medId) as TargetAchieved,
                dbo.getHospitalPotential(@hospitalId, m.medId) as PotentialTarget
            
            from tblportalBrand pb
            inner join medicine m on pb.medId = m.medID
            
            where pb.PortalId = 1000 
            order by medid asc


    set NOCOUNT   OFF;

GO
/****** Object:  StoredProcedure [hae].[USP_INSERT_HOSPITAL_ACTUAL_TARGETS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_INSERT_HOSPITAL_ACTUAL_TARGETS  875, 3,2023 
create PROCEDURE [hae].[USP_INSERT_HOSPITAL_ACTUAL_TARGETS] 
    ( 
        @medId  int,
        @hospitalId int,
        @empId int,
        @actualTarget bigint,
        @month int,
        @year int
    ) 
AS 
    set NOCOUNT ON   
	
         declare @addedFor smallDateTime    
            set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1)) 
        if exists (select 1 from tblhospitalactuals where hospitalId = @hospitalId and medid = @medId and addedFor = @addedFor)
            BEGIN
                -- update tblhospitalactuals set isActive = 1 where hospitalId = @hospitalId and medid = @medId and addedFor = @addedFor
                delete from tblhospitalactuals where hospitalId = @hospitalId and medid = @medId and addedFor = @addedFor
       
            END 
        insert into tblhospitalactuals (empID, medid, hospitalID, addedfor, qty, isActive)
        VALUES(@empId, @medId, @hospitalId, @addedFor, @actualTarget, 0)




    set NOCOUNT   OFF;

GO
/****** Object:  StoredProcedure [hae].[USP_INSERT_HOSPITAL_POTENTIAL_TARGETS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_INSERT_HOSPITAL_POTENTIAL_TARGETS  511 
create PROCEDURE [hae].[USP_INSERT_HOSPITAL_POTENTIAL_TARGETS] 
    ( 
        @medId int,
        @hospitalId int,
        @empId int,
        @potential bigint
    ) 
AS 
    set NOCOUNT ON   
	
		if exists (select 1 from TblHospitalsPotentials where hospitalId = @hospitalId and medId = @medid and isActive = 0)
			BEGIN
				update TblHospitalsPotentials set isActive = 1
					where hospitalId = @hospitalId and medId = @medid and isActive = 0
				insert into TblHospitalsPotentials (empid, hospitalID, medID, target, isActive)
					VALUES(@empid, @hospitalId, @medId, @potential, 0)
			END
		ELSE
			BEGIN
				insert into TblHospitalsPotentials (empid, hospitalID, medID, target, isActive)
					VALUES(@empid, @hospitalId, @medId, @potential, 0)
			END

    set NOCOUNT off; 
 
     
        
         

GO
/****** Object:  StoredProcedure [hae].[USP_RBM_REPORT_v7]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [hae].[USP_RBM_REPORT_v7]   
(   
    @year INT,   
    @secondYear INT,   
    @empId int = null,   
    @hospitalId INT = null,   
    @medId INT = null,   
    @kamId INT = null,   
    @rbmId INT = null,   
    @zbmId INT = null,   
    @zoneId INT = null   
)   
AS   
    BEGIN   
        declare @firstYear smallDateTime, @secYear smallDateTime   
        set  @firstYear = (DATEFROMPARTS (@Year, 4, 1))   
        set  @secYear = (DATEFROMPARTS (@secondYear, 3, 31))  
  
       select    
          
       dbo.getMyZBMInfo(e.empID) as ZBMName, dbo.getMyRBMInfo(e.empID) as RBM, e.empID, E.firstName, H.hospitalId, H.regionName, H.hospitalName,     
        z.ZoneName as 'name',  
        m.medID, hp.[target] as PotentialTarget, e.EmpNumber as EmpNumber, m.name as 'Brand' from employee e   
       INNER JOIN tblEmpHospitals EH ON EH.EmpID = E.EmpID   
       INNER JOIN TBLHOSPITALS H ON H.HOSPITALID = EH.hospitalId   
       right OUTER JOIN tblhospitalsPotentials hp on hp.hospitalID = h.hospitalID and hp.isActive = 0   
       inner join medicine m on m.medID = hp.medId  
       --ajay 
       inner join tblZone z on e.ZoneID = z.ZoneID 
        --ajay 
 
        where 1 = 1    
        and e.isActive = 0  
        -- AND E.EMPID = 394  
        -- AND H.HOSPITALID =  1545

        and CHARINDEX('kam', e.designation) > 0    
    END  
 

GO
/****** Object:  StoredProcedure [hae].[USP_RBM_REPORT_v7_1]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- USP_RBM_REPORT_v7_1 2023, 2024, 875  
-- USP_RBM_REPORT_v7_1 2022, 2023, 1545  
-------------------------------------------  
-- CREATED BY: GURU SINGH  
-- CREATED DATE: 19-APR-2023  
-------------------------------------------  
create procedure [hae].[USP_RBM_REPORT_v7_1]  
(  
    @year INT,  
    @secondYear INT,  
    @hospitalId INT = null,  
    @medId INT = null,  
    @kamId INT = null  
)  
AS  
    BEGIN  
        declare @firstYear date, @secYear date  
        set  @firstYear = convert(date, (DATEFROMPARTS (@Year, 4, 1)),23)  -- first day of the finicial Year 1-Apr-2022  
        set  @secYear = convert(date, (DATEFROMPARTS (@secondYear, 3, 31)),23)  -- last day of the finicial Year 31-Mar-2023   
       -- select @firstYear as first, @secYear as second 
  
        /*  
            data.MedID, data.ActualsEnteredFor, apr.ActualTarget  
        */  
        SELECT medId, hospitalId, addedFor as ActualsEnteredFor, isNull(qty,0) as ActualTarget, empId, comments  FROM tblhospitalActuals  
            where isActive = 0  
           and (hospitalId = @hospitalId or @hospitalId is NULL ) 
           and (medId = @medId or @medId is NULL)  
           and (empId = @kamId or @kamId is NULL ) 
          -- and addedFor BETWEEN @firstYear and @secYear  
         --   and convert(date, addedFor,23)  BETWEEN @firstYear and @secYear  
           and convert(date, addedFor,23) >= @firstYear and convert(date, addedFor,23) <= @secYear  
            order by addedFor ASC
          -- USP_RBM_REPORT_v7_1 2022, 2023, 1545  
              
    END 

GO
/****** Object:  StoredProcedure [hae].[USP_UPDATE_HOSPITALS_BED]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [hae].[USP_UPDATE_HOSPITALS_BED] 

    ( 

        @hospitalId int,

		@bed int,

        @icuBed int

    ) 

AS 

    set NOCOUNT ON   

	

		

			update tblhospitals SET

				totalBed = @bed,

				ICUBed = @icuBed

			where hospitalId = @hospitalId --875





    set NOCOUNT off; 

GO
/****** Object:  UserDefinedFunction [dbo].[AUDIT_fn_HexToStr]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[AUDIT_fn_HexToStr](@hex varbinary(8000))
returns varchar(8000)
as
begin
declare 
	@len int,
	@counter int,
	@res varchar(8000),
	@string char(16),
	@byte binary(1)
	set @string = '0123456789ABCDEF'
	set @res = '0x'
	set @len = datalength(@hex)
	set @counter = 1
	while(@counter <= @len)
	begin
		set @byte = substring(@hex, @counter, 1)
		set @res = @res + substring(@string, 1 + @byte/16, 1) + substring(@string, 1 + @byte - (@byte/16)*16, 1)
		set @counter = @counter + 1
	end
	return @res
end

GO
/****** Object:  UserDefinedFunction [dbo].[AUDIT_fn_SqlVariantToString]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[AUDIT_fn_SqlVariantToString](@var sql_variant, @string bit)
returns nvarchar(4000)
as
begin
declare
@type varchar(20),
@result nvarchar(4000)
set @type = cast(SQL_VARIANT_PROPERTY(@var,'BaseType') as varchar(20))
if (@type='binary' or @type='varbinary')
	set @result = cast(dbo.AUDIT_fn_HexToStr(cast(@var as varbinary(8000))) as nvarchar(4000))
else if (@type='float' or @type='real')
	set @result = convert(nvarchar(4000), @var, 3)
else if (@type='int'
	or @type='tinyint'
	or @type='smallint'
	or @type='bigint'
	or @type='bit'
	or @type='decimal'
	or @type='numeric'
	)
	set @result = convert(nvarchar(4000), @var)
else if (@type='timestamp')
	set @result = convert(nvarchar(4000), convert(bigint, @var))
else if (@string = 1)
	set @result = 'N''' + convert(nvarchar(4000), @var) + ''''
else
	set @result = convert(nvarchar(4000), @var)
return @result
end

GO
/****** Object:  UserDefinedFunction [dbo].[getHospitalPotential]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [dbo].[getHospitalPotential]   
    (        
        @hospitalId int,        
        @medId int     
    )    
    RETURNS bigint AS    
        BEGIN         
            DECLARE @retVal float             
            -- select @retVal  = SUM(RATE * qty) from TblHospitalactuals                 
            -- select @retVal  = SUM(qty) from TblHospitalsPotentials                 
            select top 1 @retVal  = target from TblHospitalsPotentials                 
                where hospitalId = @hospitalId     
                and medId = @medId    
                and isactive = 0                    
            RETURN isNull(@retVal, 0)    
        END 

GO
/****** Object:  UserDefinedFunction [dbo].[getSumOfHospitalActuals]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [dbo].[getSumOfHospitalActuals]   
    (        
        @hospitalId int,        
        @month int ,
        @year int
    )    
    RETURNS bigint AS    
        BEGIN         
            DECLARE @retVal float   
              declare @addedFor smallDateTime    
            set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))           
            -- select @retVal  = SUM(RATE * qty) from TblHospitalactuals                 
            -- select @retVal  = SUM(qty) from TblHospitalsPotentials                 
            select @retVal  = SUM(qty) from tblhospitalactuals                 
                where hospitalId = @hospitalId     
                and isactive = 0                    
                and addedFor = @addedFor
            RETURN isNull(@retVal, 0)    
        END 

GO
/****** Object:  UserDefinedFunction [dbo].[getSumOfHospitalActualsforMed]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [dbo].[getSumOfHospitalActualsforMed]   
    (        
        @hospitalId int,        
        @month int ,
        @year int,
        @medId int
    )    
    RETURNS bigint AS    
        BEGIN         
            DECLARE @retVal float   
              declare @addedFor smallDateTime    
            set  @addedFor = (DATEFROMPARTS (@Year, @Month, 1))           
            -- select @retVal  = SUM(RATE * qty) from TblHospitalactuals                 
            -- select @retVal  = SUM(qty) from TblHospitalsPotentials                 
            select @retVal  = (qty) from tblhospitalactuals                 
                where hospitalId = @hospitalId     
                and isactive = 0                    
                and mediD = @medId
                and addedFor = @addedFor
            RETURN isNull(@retVal, 0)    
        END 

GO
/****** Object:  UserDefinedFunction [dbo].[StringSplit]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[StringSplit](@input NVARCHAR(MAX), @delimiter CHAR(1)=',') 
       RETURNS @returnTable TABLE(item NVARCHAR(100)) AS  
     BEGIN 
        IF @input IS NULL RETURN;
        DECLARE @currentStartIndex INT, @currentEndIndex INT,@length INT;
        SET @length=LEN(@input);
        SET @currentStartIndex=1;

        SET @currentEndIndex=CHARINDEX(@delimiter,@input,@currentStartIndex);
        WHILE (@currentEndIndex<>0)
          BEGIN
            INSERT INTO @returnTable VALUES (LTRIM(SUBSTRING(@input, @currentStartIndex, @currentEndIndex-@currentStartIndex)))
            SET @currentStartIndex=@currentEndIndex+1;
            SET @currentEndIndex=CHARINDEX(@delimiter,@input,@currentStartIndex);
          END

        IF (@currentStartIndex <= @length)
          INSERT INTO @returnTable 
            VALUES (LTRIM(SUBSTRING(@input, @currentStartIndex, @length-@currentStartIndex+1)));
        RETURN;
     END
GO
/****** Object:  UserDefinedFunction [hae].[getHospitalPotential]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE FUNCTION [hae].[getHospitalPotential]   
    (        
        @hospitalId int,        
        @medId int     
    )    
    RETURNS bigint AS    
        BEGIN         
            DECLARE @retVal float             
            -- select @retVal  = SUM(RATE * qty) from TblHospitalactuals                 
            -- select @retVal  = SUM(qty) from TblHospitalsPotentials                 
            select top 1 @retVal  = target from TblHospitalsPotentials                 
                where hospitalId = @hospitalId     
                and medId = @medId    
                and isactive = 0                    
            RETURN isNull(@retVal, 0)    
        END 

GO
/****** Object:  UserDefinedFunction [hae].[getMyRBMInfo]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [getMyRBMInfo](79)
create FUNCTION [hae].[getMyRBMInfo] ( 
    @empId int
 ) 
RETURNS NVARCHAR(200) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(200) 
        select @retVal = firstname from employee where empId in (
            select ParentID from tblHierarchy where empId = @empId -- and isDisabled = 0
        ) and isActive = 0
        RETURN isNull(@retVal, '-NA-') 
END 

GO
/****** Object:  UserDefinedFunction [hae].[getMyZBMInfo]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select [getMyZBMInfo](89)
create FUNCTION [hae].[getMyZBMInfo] ( 
    @empId int
 ) 
RETURNS NVARCHAR(200) 
AS BEGIN 
 
    DECLARE @retVal NVARCHAR(200) 
        declare @parentID int
        select @parentID  = ParentID from tblHierarchy where empId = @empId -- and isDisabled = 0 -- rbm
        select @retVal = firstname from employee where empId in (
            select ParentID from tblHierarchy where empId = @parentID -- and isDisabled = 0
        ) and isActive = 0
        RETURN isNull(@retVal, '-NA-') 
END 

GO
/****** Object:  Table [dbo].[__MigrationHistory]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[__MigrationHistory](
	[MigrationId] [nvarchar](150) NOT NULL,
	[ContextKey] [nvarchar](300) NOT NULL,
	[Model] [varbinary](max) NOT NULL,
	[ProductVersion] [nvarchar](32) NOT NULL,
 CONSTRAINT [PK_dbo.__MigrationHistory] PRIMARY KEY CLUSTERED 
(
	[MigrationId] ASC,
	[ContextKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AddDoctorsCSV]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AddDoctorsCSV](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TS] [nvarchar](500) NOT NULL,
	[DoctorAddition] [nvarchar](500) NOT NULL,
 CONSTRAINT [PK_AddDoctorsCSV] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AUDIT_LOG_DATA]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AUDIT_LOG_DATA](
	[AUDIT_LOG_DATA_ID] [int] IDENTITY(1,1) NOT NULL,
	[AUDIT_LOG_TRANSACTION_ID] [int] NOT NULL,
	[PRIMARY_KEY_DATA] [nvarchar](1500) NOT NULL,
	[COL_NAME] [nvarchar](128) NOT NULL,
	[OLD_VALUE_LONG] [ntext] NULL,
	[NEW_VALUE_LONG] [ntext] NULL,
	[NEW_VALUE_BLOB] [image] NULL,
	[NEW_VALUE]  AS (isnull(CONVERT([nvarchar](4000),[NEW_VALUE_LONG]),CONVERT([varchar](8000),CONVERT([varbinary](8000),substring([NEW_VALUE_BLOB],(1),(8000)))))),
	[OLD_VALUE]  AS (CONVERT([nvarchar](4000),[OLD_VALUE_LONG])),
	[PRIMARY_KEY]  AS ([PRIMARY_KEY_DATA]),
	[DATA_TYPE] [char](1) NOT NULL,
	[KEY1] [nvarchar](500) NULL,
	[KEY2] [nvarchar](500) NULL,
	[KEY3] [nvarchar](500) NULL,
	[KEY4] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[AUDIT_LOG_DATA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AUDIT_LOG_DDL]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AUDIT_LOG_DDL](
	[LogId] [int] IDENTITY(1,1) NOT NULL,
	[DATABASE] [nvarchar](100) NOT NULL,
	[SCHEMA] [nvarchar](100) NULL,
	[OBJECT_TYPE] [nvarchar](100) NOT NULL,
	[OBJECT_NAME] [nvarchar](100) NOT NULL,
	[ACTION] [nvarchar](100) NOT NULL,
	[OLD_VALUE] [nvarchar](100) NULL,
	[NEW_VALUE] [nvarchar](100) NULL,
	[MODIFIED_BY] [nvarchar](100) NOT NULL,
	[MODIFIED_DATE] [datetime] NULL,
	[APP_NAME] [nvarchar](100) NOT NULL,
	[HOST_NAME] [nvarchar](100) NOT NULL,
	[DESCRIPTION] [nvarchar](100) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[LogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[AUDIT_LOG_TRANSACTIONS]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AUDIT_LOG_TRANSACTIONS](
	[AUDIT_LOG_TRANSACTION_ID] [int] IDENTITY(1,1) NOT NULL,
	[DATABASE] [nvarchar](128) NOT NULL,
	[TABLE_NAME] [nvarchar](261) NOT NULL,
	[TABLE_SCHEMA] [nvarchar](261) NOT NULL,
	[AUDIT_ACTION_ID] [tinyint] NOT NULL,
	[HOST_NAME] [varchar](128) NOT NULL,
	[APP_NAME] [varchar](128) NOT NULL,
	[MODIFIED_BY] [varchar](128) NOT NULL,
	[MODIFIED_DATE] [datetime] NOT NULL,
	[AFFECTED_ROWS] [int] NOT NULL,
	[SYSOBJ_ID]  AS (object_id([TABLE_NAME])),
PRIMARY KEY CLUSTERED 
(
	[AUDIT_LOG_TRANSACTION_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[City]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[City](
	[CityID] [int] IDENTITY(1,1) NOT NULL,
	[CityName] [nvarchar](max) NULL,
	[RegionID] [int] NOT NULL,
	[CityInchargeID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.City] PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DeleteDoctors]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DeleteDoctors](
	[TS] [varchar](500) NULL,
	[DoctorDeletion] [varchar](500) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DeleteMedicineUsage]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeleteMedicineUsage](
	[ZoneName] [nvarchar](50) NULL,
	[EmployeeName] [nvarchar](50) NULL,
	[OrderDate] [date] NULL,
	[DoctorsName] [nvarchar](50) NULL,
	[Speciality] [nvarchar](50) NULL,
	[HospitalName] [nvarchar](50) NULL,
	[Indication] [nvarchar](50) NULL,
	[Thymogam_NoOfPatients] [bit] NULL,
	[Revugam_NoOfPatients] [bit] NULL,
	[Oncyclo_NoOfPatients] [bit] NULL,
	[ThymogamVials] [tinyint] NULL,
	[RevugamStrips] [tinyint] NULL,
	[OncycloStrips] [tinyint] NULL,
	[ThymogamPap] [tinyint] NULL,
	[RevugamPap] [tinyint] NULL,
	[OncycloPap] [tinyint] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Designation]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Designation](
	[DesignationId] [int] IDENTITY(1,1) NOT NULL,
	[DesignationName] [nvarchar](100) NULL,
 CONSTRAINT [PK_dbo.Designation] PRIMARY KEY CLUSTERED 
(
	[DesignationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[DoctorsForVerify27112023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DoctorsForVerify27112023](
	[TS] [nvarchar](255) NULL,
	[Doctor] [nvarchar](255) NULL,
	[TSs] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[Hospital] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EmpDocHospTemp]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmpDocHospTemp](
	[Employee] [nvarchar](100) NULL,
	[designation] [nvarchar](100) NULL,
	[doctorID] [int] NOT NULL,
	[customerCode] [nvarchar](100) NULL,
	[doctorName] [nvarchar](100) NULL,
	[specialtyName] [nvarchar](100) NULL,
	[cityName] [nvarchar](100) NULL,
	[StateName] [nvarchar](max) NULL,
	[hospitalName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Employee]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee](
	[EmpID] [int] IDENTITY(1,1) NOT NULL,
	[Password] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[firstName] [nvarchar](100) NULL,
	[middleName] [nvarchar](100) NULL,
	[lastName] [nvarchar](100) NULL,
	[Designation] [nvarchar](100) NULL,
	[LastLoginDate] [datetime] NULL,
	[DesignationID] [int] NOT NULL,
	[MobileNumber] [nvarchar](100) NULL,
	[HQName] [nvarchar](100) NULL,
	[EmpNumber] [nvarchar](100) NULL,
	[StateID] [int] NOT NULL,
	[Comments] [nvarchar](2000) NULL,
	[DOJ] [datetime] NULL,
	[HQCode] [nvarchar](100) NULL,
	[ZoneID] [int] NULL,
	[isMetro] [bit] NULL,
	[regionName] [nvarchar](100) NULL,
	[isActive] [int] NULL,
	[createdOn] [smalldatetime] NULL,
	[Division] [nvarchar](10) NULL,
	[HiDocDoJ] [nvarchar](20) NULL,
	[SeravaccDoJ] [nvarchar](20) NULL,
 CONSTRAINT [PK_dbo.Employee] PRIMARY KEY CLUSTERED 
(
	[EmpID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Employee_24072023_beforeCleanup]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employee_24072023_beforeCleanup](
	[EmpID] [int] IDENTITY(1,1) NOT NULL,
	[Password] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[firstName] [nvarchar](100) NULL,
	[middleName] [nvarchar](100) NULL,
	[lastName] [nvarchar](100) NULL,
	[Designation] [nvarchar](100) NULL,
	[LastLoginDate] [datetime] NULL,
	[DesignationID] [int] NOT NULL,
	[MobileNumber] [nvarchar](100) NULL,
	[HQName] [nvarchar](100) NULL,
	[EmpNumber] [nvarchar](100) NULL,
	[StateID] [int] NOT NULL,
	[Comments] [nvarchar](2000) NULL,
	[DOJ] [datetime] NULL,
	[HQCode] [nvarchar](100) NULL,
	[ZoneID] [int] NULL,
	[isMetro] [bit] NULL,
	[regionName] [nvarchar](100) NULL,
	[isActive] [int] NULL,
	[createdOn] [smalldatetime] NULL,
	[Division] [nvarchar](10) NULL,
	[HiDocDoJ] [nvarchar](20) NULL,
	[SeravaccDoJ] [nvarchar](20) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[employeebk]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[employeebk](
	[EmpID] [int] IDENTITY(1,1) NOT NULL,
	[Password] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[firstName] [nvarchar](100) NULL,
	[middleName] [nvarchar](100) NULL,
	[lastName] [nvarchar](100) NULL,
	[Designation] [nvarchar](100) NULL,
	[LastLoginDate] [datetime] NULL,
	[DesignationID] [int] NOT NULL,
	[MobileNumber] [nvarchar](100) NULL,
	[HQName] [nvarchar](100) NULL,
	[EmpNumber] [nvarchar](100) NULL,
	[StateID] [int] NOT NULL,
	[Comments] [nvarchar](2000) NULL,
	[DOJ] [datetime] NULL,
	[HQCode] [nvarchar](100) NULL,
	[ZoneID] [int] NULL,
	[isMetro] [bit] NULL,
	[regionName] [nvarchar](100) NULL,
	[isActive] [int] NULL,
	[createdOn] [smalldatetime] NULL,
	[Division] [nvarchar](10) NULL,
	[HiDocDoJ] [nvarchar](20) NULL,
	[SeravaccDoJ] [nvarchar](20) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[EmployeeLoginLog]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmployeeLoginLog](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmpID] [int] NOT NULL,
	[LoginDate] [datetime] NOT NULL,
 CONSTRAINT [PK_dbo.EmployeeLoginLog] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HospitalImport06112023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HospitalImport06112023](
	[TS] [nvarchar](255) NULL,
	[DoctorName] [nvarchar](255) NULL,
	[CityName] [nvarchar](255) NULL,
	[Hospital] [nvarchar](255) NULL,
	[ISDeleted] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[HospitalImport06112023_bkup]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HospitalImport06112023_bkup](
	[TS] [nvarchar](255) NULL,
	[DoctorName] [nvarchar](255) NULL,
	[CityName] [nvarchar](255) NULL,
	[Hospital] [nvarchar](255) NULL,
	[ISDeleted] [float] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Medicine]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Medicine](
	[medID] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](100) NULL,
	[imageURL] [nvarchar](2000) NULL,
	[IsActive] [bit] NOT NULL,
	[portalCode] [nvarchar](100) NULL,
	[descp] [nvarchar](1000) NULL,
	[objective] [nvarchar](1000) NULL,
 CONSTRAINT [PK_dbo.Medicine] PRIMARY KEY CLUSTERED 
(
	[medID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MedicineUsage]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MedicineUsage](
	[MedicineUsageId] [int] IDENTITY(1,1) NOT NULL,
	[EmpID] [int] NOT NULL,
	[medID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[NoOfPatients] [int] NOT NULL,
	[DoctorsID] [nvarchar](100) NULL,
	[DoctorsName] [nvarchar](100) NULL,
	[NoOfVials] [int] NOT NULL,
	[HospitalName] [nvarchar](200) NULL,
	[HospitalCity] [nvarchar](100) NULL,
	[Indication] [nvarchar](250) NULL,
	[Speciality] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[prescriptions] [nvarchar](100) NULL,
	[strips] [nvarchar](100) NULL,
	[TotalValue] [nvarchar](100) NULL,
	[arc] [nvarchar](100) NULL,
	[PrescriberType] [nvarchar](100) NULL,
	[Target] [nvarchar](100) NULL,
	[PapValue] [int] NULL,
	[EntryID] [varchar](100) NULL,
 CONSTRAINT [PK_dbo.MedicineUsage] PRIMARY KEY CLUSTERED 
(
	[MedicineUsageId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[MedicineUsage_08042023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MedicineUsage_08042023](
	[MedicineUsageId] [int] IDENTITY(1,1) NOT NULL,
	[EmpID] [int] NOT NULL,
	[medID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[NoOfPatients] [int] NOT NULL,
	[DoctorsID] [nvarchar](100) NULL,
	[DoctorsName] [nvarchar](100) NULL,
	[NoOfVials] [int] NOT NULL,
	[HospitalName] [nvarchar](200) NULL,
	[HospitalCity] [nvarchar](100) NULL,
	[Indication] [nvarchar](250) NULL,
	[Speciality] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MedicineUsage27112023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MedicineUsage27112023](
	[MedicineUsageId] [int] IDENTITY(1,1) NOT NULL,
	[EmpID] [int] NOT NULL,
	[medID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[NoOfPatients] [int] NOT NULL,
	[DoctorsID] [nvarchar](100) NULL,
	[DoctorsName] [nvarchar](100) NULL,
	[NoOfVials] [int] NOT NULL,
	[HospitalName] [nvarchar](200) NULL,
	[HospitalCity] [nvarchar](100) NULL,
	[Indication] [nvarchar](250) NULL,
	[Speciality] [nvarchar](100) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[prescriptions] [nvarchar](100) NULL,
	[strips] [nvarchar](100) NULL,
	[TotalValue] [nvarchar](100) NULL,
	[arc] [nvarchar](100) NULL,
	[PrescriberType] [nvarchar](100) NULL,
	[Target] [nvarchar](100) NULL,
	[PapValue] [int] NULL,
	[EntryID] [varchar](100) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[OrganogramData]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrganogramData](
	[ID] [float] NULL,
	[Zone] [nvarchar](255) NULL,
	[State] [nvarchar](255) NULL,
	[City] [nvarchar](255) NULL,
	[HQ Code] [nvarchar](255) NULL,
	[Employee Number] [nvarchar](255) NULL,
	[Employee_Name] [nvarchar](255) NULL,
	[Designation] [nvarchar](255) NULL,
	[HQ Name] [nvarchar](255) NULL,
	[Region Name] [nvarchar](255) NULL,
	[DOJ] [datetime] NULL,
	[Mobile No] [nvarchar](255) NULL,
	[Email Address] [nvarchar](255) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Person]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Person](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [varchar](255) NULL,
	[LastName] [varchar](255) NULL,
	[Age] [int] NULL,
	[City] [varchar](255) NULL,
 CONSTRAINT [PK__Person__3214EC07F39C22B6] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Regions]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Regions](
	[RegionID] [int] IDENTITY(1,1) NOT NULL,
	[RegionName] [nvarchar](max) NULL,
	[RegionInchargeID] [int] NOT NULL,
	[StateID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Regions] PRIMARY KEY CLUSTERED 
(
	[RegionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[States]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[States](
	[StateID] [int] IDENTITY(1,1) NOT NULL,
	[StateName] [nvarchar](max) NULL,
	[ZoneID] [int] NOT NULL,
	[StateInchargeID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.States] PRIMARY KEY CLUSTERED 
(
	[StateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDoctors]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDoctors](
	[doctorID] [int] IDENTITY(1000,1) NOT NULL,
	[customerCode] [nvarchar](100) NULL,
	[doctorName] [nvarchar](100) NULL,
	[specialtyID] [int] NULL,
	[cityName] [nvarchar](100) NULL,
	[stateId] [int] NULL,
	[hospitalName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [date] NULL,
 CONSTRAINT [PK_tblDoctors] PRIMARY KEY CLUSTERED 
(
	[doctorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDoctors_22112023_errored]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDoctors_22112023_errored](
	[doctorID] [int] IDENTITY(1000,1) NOT NULL,
	[customerCode] [nvarchar](100) NULL,
	[doctorName] [nvarchar](100) NULL,
	[specialtyID] [int] NULL,
	[cityName] [nvarchar](100) NULL,
	[stateId] [int] NULL,
	[hospitalName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [date] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDoctors20072023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDoctors20072023](
	[doctorID] [int] IDENTITY(1000,1) NOT NULL,
	[customerCode] [nvarchar](100) NULL,
	[doctorName] [nvarchar](100) NULL,
	[specialtyID] [int] NULL,
	[cityName] [nvarchar](100) NULL,
	[stateId] [int] NULL,
	[hospitalName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [date] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDoctors27112023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDoctors27112023](
	[doctorID] [int] IDENTITY(1000,1) NOT NULL,
	[customerCode] [nvarchar](100) NULL,
	[doctorName] [nvarchar](100) NULL,
	[specialtyID] [int] NULL,
	[cityName] [nvarchar](100) NULL,
	[stateId] [int] NULL,
	[hospitalName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [date] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblDoctors28112023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblDoctors28112023](
	[doctorID] [int] IDENTITY(1000,1) NOT NULL,
	[customerCode] [nvarchar](100) NULL,
	[doctorName] [nvarchar](100) NULL,
	[specialtyID] [int] NULL,
	[cityName] [nvarchar](100) NULL,
	[stateId] [int] NULL,
	[hospitalName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [date] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblEmpDoc]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblEmpDoc](
	[empDocId] [int] IDENTITY(1,1) NOT NULL,
	[empID] [int] NULL,
	[doctorID] [int] NULL,
 CONSTRAINT [PK_tblEmpDoc] PRIMARY KEY CLUSTERED 
(
	[empDocId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblEmpDoc27112023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblEmpDoc27112023](
	[empDocId] [int] IDENTITY(1,1) NOT NULL,
	[empID] [int] NULL,
	[doctorID] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblEmpDoc28112023]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblEmpDoc28112023](
	[empDocId] [int] IDENTITY(1,1) NOT NULL,
	[empID] [int] NULL,
	[doctorID] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblEmpHospitals]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tblEmpHospitals](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[hospitalId] [varchar](255) NULL,
	[EmpID] [varchar](255) NULL,
 CONSTRAINT [PK__tblEmpHo__3213E83F17ED851D] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tblemployeeBkup]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblemployeeBkup](
	[EmpID] [int] IDENTITY(1,1) NOT NULL,
	[Password] [nvarchar](100) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[firstName] [nvarchar](100) NULL,
	[middleName] [nvarchar](100) NULL,
	[lastName] [nvarchar](100) NULL,
	[Designation] [nvarchar](100) NULL,
	[LastLoginDate] [datetime] NULL,
	[DesignationID] [int] NOT NULL,
	[MobileNumber] [nvarchar](100) NULL,
	[HQName] [nvarchar](100) NULL,
	[EmpNumber] [nvarchar](100) NULL,
	[StateID] [int] NOT NULL,
	[Comments] [nvarchar](2000) NULL,
	[DOJ] [datetime] NULL,
	[HQCode] [nvarchar](100) NULL,
	[ZoneID] [int] NULL,
	[isMetro] [bit] NULL,
	[regionName] [nvarchar](100) NULL,
	[isActive] [int] NULL,
	[createdOn] [smalldatetime] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblerrorCapture]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblerrorCapture](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[remarks] [nvarchar](1000) NULL,
	[Month] [nvarchar](100) NULL,
 CONSTRAINT [PK_tblerrorCapture] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblHematOrn]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHematOrn](
	[S_No] [tinyint] NULL,
	[Zone] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[HQ] [nvarchar](500) NULL,
	[Emp_Code] [nvarchar](500) NULL,
	[Emp_Names] [nvarchar](500) NULL,
	[Old_or_New] [nvarchar](500) NULL,
	[DOJ] [nvarchar](500) NULL,
	[state1] [nvarchar](100) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblHierarchy]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHierarchy](
	[HierarchyID] [int] IDENTITY(1,1) NOT NULL,
	[empID] [int] NULL,
	[ParentID] [int] NULL,
 CONSTRAINT [PK_tblHierarchy] PRIMARY KEY CLUSTERED 
(
	[HierarchyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblHospitalActuals]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblHospitalActuals](
	[actualID] [int] IDENTITY(1,1) NOT NULL,
	[empID] [int] NULL,
	[medId] [int] NULL,
	[hospitalId] [int] NULL,
	[addedFor] [smalldatetime] NULL,
	[qty] [int] NULL,
	[isActive] [bit] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[comments] [nvarchar](100) NULL,
 CONSTRAINT [PK_tblHospitalActuals] PRIMARY KEY CLUSTERED 
(
	[actualID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblhospitals]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblhospitals](
	[hospitalID] [int] IDENTITY(1,1) NOT NULL,
	[hospitalname] [nvarchar](500) NULL,
	[regionName] [nvarchar](500) NULL,
	[totalBed] [int] NULL,
	[ICUBed] [int] NULL,
	[isActive] [bit] NULL,
	[CreatedDate] [smalldatetime] NULL,
	[zoneID] [int] NULL,
 CONSTRAINT [PK_tblhospitals] PRIMARY KEY CLUSTERED 
(
	[hospitalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[TblHospitalsPotentials]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblHospitalsPotentials](
	[potentialId] [int] IDENTITY(1,1) NOT NULL,
	[empId] [int] NULL,
	[hospitalId] [int] NULL,
	[medId] [int] NULL,
	[target] [int] NULL,
	[isActive] [bit] NULL,
	[CreatedDate] [smalldatetime] NULL,
 CONSTRAINT [PK_TblHospitalsPotentials] PRIMARY KEY CLUSTERED 
(
	[potentialId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblMSL]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMSL](
	[Zone] [nvarchar](500) NULL,
	[Therapy_Specialist_Code] [nvarchar](500) NULL,
	[Therapy_Specialist_Name] [nvarchar](500) NULL,
	[_1st_Level_Reporting_Region] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[Customer_Code] [nvarchar](500) NULL,
	[Doctor_Name] [nvarchar](500) NULL,
	[Specialty] [nvarchar](500) NULL,
	[Qualification] [nvarchar](500) NULL,
	[City] [nvarchar](500) NULL,
	[State1] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPortal]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPortal](
	[portalID] [int] IDENTITY(1000,1) NOT NULL,
	[PortalName] [nvarchar](100) NULL,
	[isActive] [bit] NULL,
 CONSTRAINT [PK_tblPortal] PRIMARY KEY CLUSTERED 
(
	[portalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblPortalBrand]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPortalBrand](
	[portalBrandID] [int] IDENTITY(1000,1) NOT NULL,
	[PortalId] [int] NULL,
	[medId] [int] NULL,
	[isActive] [bit] NULL,
 CONSTRAINT [PK_tblPortalBrand] PRIMARY KEY CLUSTERED 
(
	[portalBrandID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblSera]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSera](
	[Division] [nvarchar](500) NULL,
	[HQ_Name] [nvarchar](500) NULL,
	[HQ_Code] [nvarchar](500) NULL,
	[Designation] [nvarchar](500) NULL,
	[Employee_Name] [nvarchar](500) NULL,
	[Employee_Number] [nvarchar](500) NULL,
	[Employee_Mobile] [nvarchar](500) NULL,
	[Employee_Email_Address] [nvarchar](500) NULL,
	[Date_Of_Joining] [nvarchar](500) NULL,
	[HiDoctor_Start_Date] [nvarchar](500) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblSpecialty]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSpecialty](
	[specialtyId] [int] IDENTITY(1000,1) NOT NULL,
	[specialtyName] [nvarchar](100) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [date] NULL,
 CONSTRAINT [PK_tblSpecialty] PRIMARY KEY CLUSTERED 
(
	[specialtyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[tblZone]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblZone](
	[zoneID] [smallint] IDENTITY(1000,1) NOT NULL,
	[ZoneName] [nvarchar](50) NULL,
	[IsActive] [bit] NULL,
	[createdDate] [smalldatetime] NULL,
 CONSTRAINT [PK_tblZone] PRIMARY KEY CLUSTERED 
(
	[zoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[UserGuid] [nvarchar](100) NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Password] [nvarchar](100) NOT NULL,
	[FullName] [nvarchar](100) NULL,
	[Mobile_No] [nvarchar](100) NULL,
	[LastLoginDate] [datetime] NULL,
	[Is_Deleted] [bit] NOT NULL,
	[Created_By] [int] NULL,
	[Created_Date] [datetime] NOT NULL,
	[Created_IP] [nvarchar](100) NULL,
	[Updated_By] [int] NULL,
	[Updated_Date] [datetime] NULL,
	[Updated_IP] [nvarchar](100) NULL,
	[Deleted_By] [int] NULL,
	[Deleted_Date] [datetime] NULL,
	[Deleted_IP] [nvarchar](100) NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Zones]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Zones](
	[ZoneID] [int] IDENTITY(1,1) NOT NULL,
	[ZoneName] [nvarchar](max) NULL,
	[ZoneInchargeID] [int] NOT NULL,
 CONSTRAINT [PK_dbo.Zones] PRIMARY KEY CLUSTERED 
(
	[ZoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  View [dbo].[AUDIT_UNDO]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUDIT_UNDO] AS
/* ------------------------------------------------------------
VIEW:          AUDIT_UNDO
DESCRIPTION:   Selects Audit Log records and returns all rows from the
               AUDIT_LOG_TRANSACTIONS ALT, with the matching rows in the AUDIT_LOG_DATA AD.
   ------------------------------------------------------------ */
SELECT    
	ALT.AUDIT_LOG_TRANSACTION_ID,    
	TABLE_NAME = ALT.TABLE_NAME,
	TABLE_SCHEMA = ALT.TABLE_SCHEMA,
	CASE    
		WHEN ALT.AUDIT_ACTION_ID = 3 THEN 'Delete' 
		WHEN ALT.AUDIT_ACTION_ID = 2 THEN 'Insert'
		WHEN ALT.AUDIT_ACTION_ID = 1 THEN 'Update'
	END AS ACTION_NAME,
	ALT.HOST_NAME,    
	ALT.APP_NAME,    
	ALT.MODIFIED_BY,    
	ALT.MODIFIED_DATE,    
	ALT.AFFECTED_ROWS,
	AUDIT_LOG_DATA_ID,  
	PRIMARY_KEY,  
	COL_NAME,  
	OLD_VALUE,  
	NEW_VALUE,
	DATA_TYPE      
FROM AUDIT_LOG_TRANSACTIONS ALT
	LEFT JOIN  AUDIT_LOG_DATA AD
		ON AD.AUDIT_LOG_TRANSACTION_ID = ALT.AUDIT_LOG_TRANSACTION_ID

GO
/****** Object:  View [dbo].[AUDIT_VIEW]    Script Date: 20-04-2024 11:10:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[AUDIT_VIEW] AS
/* ------------------------------------------------------------
VIEW:          AUDIT_VIEW
DESCRIPTION:   Selects Audit Log records and groups by MODIFIED_DATE and PK
               effectively grouping audit data by Audit transaction
   ------------------------------------------------------------ */
SELECT MAX(t.TABLE_NAME) AS TABLE_NAME,
    CASE MAX(t.AUDIT_ACTION_ID) 
    WHEN 1 THEN 'UPDATE' 
    WHEN 2 THEN 'INSERT' 
    WHEN 3 THEN 'DELETE' 
    END AS ACTION, 
    MAX(t.MODIFIED_BY) AS MODIFIED_BY, 
    MAX(PRIMARY_KEY_DATA) AS PRIMARY_KEY,
    COUNT(DISTINCT PRIMARY_KEY_DATA) AS REC_COUNT,
    CONVERT(varchar(20), MODIFIED_DATE, 113) AS MODIFIED_DATE,
    Max(HOST_NAME) AS COMPUTER,
    Max(APP_NAME) as APPLICATION
FROM dbo.AUDIT_LOG_TRANSACTIONS t
INNER JOIN dbo.AUDIT_LOG_DATA r ON r.AUDIT_LOG_TRANSACTION_ID = t.AUDIT_LOG_TRANSACTION_ID
GROUP BY MODIFIED_DATE, PRIMARY_KEY_DATA

GO
ALTER TABLE [dbo].[AUDIT_LOG_DATA] ADD  DEFAULT ('A') FOR [DATA_TYPE]
GO
ALTER TABLE [dbo].[AUDIT_LOG_TRANSACTIONS] ADD  DEFAULT (db_name()) FOR [DATABASE]
GO
ALTER TABLE [dbo].[Employee] ADD  CONSTRAINT [DF__Employee__Design__398D8EEE]  DEFAULT ((0)) FOR [DesignationID]
GO
ALTER TABLE [dbo].[Employee] ADD  CONSTRAINT [DF__Employee__StateI__5535A963]  DEFAULT ((0)) FOR [StateID]
GO
ALTER TABLE [dbo].[Employee] ADD  CONSTRAINT [DEFAULT_Employee_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[Employee] ADD  CONSTRAINT [DEFAULT_Employee_createdOn]  DEFAULT (getdate()) FOR [createdOn]
GO
ALTER TABLE [dbo].[Medicine] ADD  CONSTRAINT [DF_Medicine_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[MedicineUsage] ADD  CONSTRAINT [DF__MedicineU__Creat__32E0915F]  DEFAULT ('1900-01-01T00:00:00.000') FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Regions] ADD  CONSTRAINT [DF__Regions__StateID__5CD6CB2B]  DEFAULT ((0)) FOR [StateID]
GO
ALTER TABLE [dbo].[States] ADD  CONSTRAINT [DF__States__ZoneID__5DCAEF64]  DEFAULT ((0)) FOR [ZoneID]
GO
ALTER TABLE [dbo].[States] ADD  CONSTRAINT [DF__States__StateInc__5EBF139D]  DEFAULT ((0)) FOR [StateInchargeID]
GO
ALTER TABLE [dbo].[tblDoctors] ADD  CONSTRAINT [DEFAULT_tblDoctors_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tblDoctors] ADD  CONSTRAINT [DEFAULT_tblDoctors_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[tblHospitalActuals] ADD  CONSTRAINT [DEFAULT_tblHospitalActuals_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[tblHospitalActuals] ADD  CONSTRAINT [DEFAULT_tblHospitalActuals_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[tblhospitals] ADD  CONSTRAINT [DEFAULT_tblhospitals_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[tblhospitals] ADD  CONSTRAINT [DEFAULT_tblhospitals_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[TblHospitalsPotentials] ADD  CONSTRAINT [DEFAULT_TblHospitalsPotentials_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[TblHospitalsPotentials] ADD  CONSTRAINT [DEFAULT_TblHospitalsPotentials_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[tblPortal] ADD  CONSTRAINT [DEFAULT_tblPortal_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[tblPortalBrand] ADD  CONSTRAINT [DEFAULT_tblPortalBrand_isActive]  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[tblSpecialty] ADD  CONSTRAINT [DEFAULT_tblSpecialty_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tblSpecialty] ADD  CONSTRAINT [DEFAULT_tblSpecialty_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[tblZone] ADD  CONSTRAINT [DEFAULT_tblZone_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tblZone] ADD  CONSTRAINT [DEFAULT_tblZone_createdDate]  DEFAULT (getdate()) FOR [createdDate]
GO
ALTER TABLE [dbo].[AUDIT_LOG_DATA]  WITH CHECK ADD  CONSTRAINT [FK_AUDIT_LOG_TRANSACTION_ID] FOREIGN KEY([AUDIT_LOG_TRANSACTION_ID])
REFERENCES [dbo].[AUDIT_LOG_TRANSACTIONS] ([AUDIT_LOG_TRANSACTION_ID])
GO
ALTER TABLE [dbo].[AUDIT_LOG_DATA] CHECK CONSTRAINT [FK_AUDIT_LOG_TRANSACTION_ID]
GO
