/*
If necessary, create a database

CREATE DATABASE Modernize
GO


DROP DATABASE IF EXISTS Modernize
GO

*/

USE WideWorldImporters
GO


--  SO LONG ADVENTURE WORKS!
DROP DATABASE IF EXISTS AdventureWorks2016CTP3
GO

DROP DATABASE IF EXISTS AdventureworksDW2016CTP3
GO


/**************************************************************************
Temporal Table

Each of these objects has a use in the MVC web app.  The EmployeeBase table
is the main object with EmployeeBaseHistory as the historical table.

The view dbo.Employees is used specifically for the web app.  Since it is a view
and MVC doesn't recoginize the primary keys, stored procedures are used for data
modification.

*/

ALTER TABLE [dbo].[EmployeeBase] SET ( SYSTEM_VERSIONING = OFF )
GO

DROP TABLE IF EXISTS [dbo].[EmployeeBase]
GO

DROP TABLE IF EXISTS [dbo].[EmployeeBaseHistory]
GO

/*
CREATE TABLE [dbo].[EmployeeBase](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Position] [varchar](100) NOT NULL,
	[Department] [varchar](100) NOT NULL,
	[Address] [nvarchar](1024) NOT NULL,
	[AnnualSalary] [decimal](10, 2) NOT NULL,
	[ValidFrom] [datetime2](2) GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo] [datetime2](2) GENERATED ALWAYS AS ROW END NOT NULL,
PRIMARY KEY CLUSTERED ( [EmployeeID] ASC ) WITH (
  PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
  ON [PRIMARY]
, PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
) ON [PRIMARY]
WITH
( SYSTEM_VERSIONING = ON (HISTORY_TABLE = [dbo].[EmployeeBaseHistory] , DATA_CONSISTENCY_CHECK = ON ))
GO
*/

--  This method will create the system time versioning on an already existing object
CREATE TABLE [dbo].[EmployeeBase](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Position] [varchar](100) NOT NULL,
	[Department] [varchar](100) NOT NULL,
	[Address] [nvarchar](1024) NOT NULL ,
	[AnnualSalary] [decimal](10, 2) NOT NULL,
PRIMARY KEY CLUSTERED ( [EmployeeID] ASC ) WITH (
  PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) 
  ON [PRIMARY])

GO

ALTER TABLE [dbo].[EmployeeBase]
ADD [ValidFrom] [datetime2](2) GENERATED ALWAYS AS ROW START NOT NULL
		CONSTRAINT df_ValidFrom DEFAULT '19000101',
	[ValidTo] [datetime2](2) GENERATED ALWAYS AS ROW END NOT NULL
		CONSTRAINT df_ValidTo DEFAULT '99991231 23:59:59.99',
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
GO

ALTER TABLE [dbo].[EmployeeBase]
DROP CONSTRAINT df_ValidFrom, df_ValidTo
GO

ALTER TABLE [dbo].[EmployeeBase]
SET ( SYSTEM_VERSIONING = ON 
		(HISTORY_TABLE = [dbo].[EmployeeBaseHistory] , DATA_CONSISTENCY_CHECK = ON ))
GO


-- This is the series of stored procedures that will be called from the MVC application
--  There is an INSERT, UPDATE and DELETE procedure

DROP PROC IF EXISTS dbo.spEmployeeInsert
GO

CREATE PROC dbo.spEmployeeInsert
@Name [nvarchar](100)
, @Position [nvarchar](100)
, @Department [nvarchar](100)
, @Address [nvarchar](1024)
, @AnnualSalary [decimal](10, 2)
AS
BEGIN
	BEGIN TRY
		INSERT INTO dbo.EmployeeBase (Name, Position, Department, Address, AnnualSalary)
		VALUES (@Name, @Position, @Department, @Address, @AnnualSalary)
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

DROP PROC IF EXISTS dbo.spEmployeeDelete
GO

CREATE PROC dbo.spEmployeeDelete
@EmployeeID INT
AS
BEGIN
	BEGIN TRY
		DELETE FROM dbo.EmployeeBase 
		WHERE EmployeeID = @EmployeeID
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO


DROP PROC IF EXISTS dbo.spEmployeeUpdate
GO

CREATE PROC dbo.spEmployeeUpdate
@EmployeeID INT
, @Name [nvarchar](100)
, @Position [nvarchar](100)
, @Department [nvarchar](100)
, @Address [nvarchar](1024)
, @AnnualSalary [decimal](10, 2)
AS
BEGIN
	BEGIN TRY
		UPDATE dbo.EmployeeBase 
		SET Name = @Name
		, Position = @Position
		, Department = @Department
		, Address = @Address
		, AnnualSalary = @AnnualSalary
		WHERE EmployeeID = @EmployeeID
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--  As noted in the initial comments, this view is only for the web app
--   and keeps the ValidTo and ValidFrom fields out of the model

DROP VIEW IF EXISTS [dbo].[Employees]
GO

CREATE VIEW [dbo].[Employees]
AS
SELECT EmployeeID
	  , [Name]
      , [Position]
      , [Department]
      , [Address]
      , [AnnualSalary]
  FROM [dbo].[EmployeeBase]
GO

--  Create data through view

INSERT INTO dbo.Employees
SELECT 'Vinnie','Consultant','Data Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Ted','Consultant','Mobile Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Bill','Consultant','Data Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Rachael','Consultant','Project Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Ashley','Consultant','Data Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Conor','Consultant','Data Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Ralph','Consultant','Project Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Ester','Consultant','Data Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Minnie','Consultant','Collaboration Solutions','123 Polaris Pkwy','75000'
UNION ALL SELECT 'Kamesh','Consultant','Collaboration Solutions','123 Polaris Pkwy','75000'

--  Validate what was inserted

SELECT * FROM dbo.Employees
SELECT * FROM dbo.EmployeeBase
SELECT * FROM dbo.EmployeeBaseHistory

-- Make changes

UPDATE dbo.EmployeeBase
SET AnnualSalary = 85000

/*
Using the web application, make changes to the data
*/

-- Go back and see the tables
SELECT * FROM dbo.Employees
SELECT * FROM dbo.EmployeeBase
SELECT * FROM dbo.EmployeeBaseHistory

--  Using the FOR SYSTEM_TIME AS OF filter will provide the records for a specific point in time
--   Using a range will provide all records that were modified

SELECT * FROM dbo.EmployeeBase
FOR SYSTEM_TIME AS OF '2016-07-28 08:42'




/**************************************************************************
Row Level Security

This feature will provide a filtering mechanism for row data the will allow
only the relevant rows to be return in the query.  The filter predicate can
be based on nearly any criteria, but will run once per row against the queried objects.

1. Create the table that contains the security predicates
2. Create the function that will provide the filter
3. Create a security policy that binds the filter function to the object
4. Query
*/

--  User security table

DROP TABLE IF EXISTS dbo.UserSecurity
GO

CREATE TABLE dbo.UserSecurity (
UserSecurityID INT IDENTITY(1,1)
, UserName NVARCHAR(50) NOT NULL
, Department NVARCHAR(100) NOT NULL
)
GO

--  Using SUSER_NAME function, associate a user to a department

INSERT INTO dbo.UserSecurity
SELECT SUSER_NAME(), 'Data Solutions'
--UNION ALL SELECT SUSER_NAME(), 'Project Solutions'

-- Validate the results

SELECT * FROM dbo.UserSecurity
GO

--  Drop/Create the Filter and Security Policy

DROP SECURITY POLICY IF EXISTS EmployeesBaseFilter
GO

DROP SECURITY POLICY IF EXISTS EmployeesBaseHistoryFilter
GO

DROP FUNCTION IF EXISTS dbo.fn_RowLevelSecurityPredicate
GO

CREATE FUNCTION dbo.fn_RowLevelSecurityPredicate(@RowLevelFilter AS sysname)
	RETURNS TABLE
WITH SCHEMABINDING
AS
	RETURN SELECT 1 AS fn_RowLevelSecurityPredicate_result
	FROM dbo.UserSecurity
	WHERE (UserName = SUSER_NAME() AND Department = @RowLevelFilter) --OR USER_NAME() = N'dbo'
GO

--  We found that when the temporal table is used, querying the primary object does not
--   filter all results.  For records that meet the system time criteria, they will be returned with the
--   result set if no filter predicate is in place.

CREATE SECURITY POLICY EmployeesBaseFilter
ADD FILTER PREDICATE dbo.fn_RowLevelSecurityPredicate(Department) 
ON dbo.EmployeeBase
WITH (STATE = ON);
GO

CREATE SECURITY POLICY EmployeesBaseHistoryFilter
ADD FILTER PREDICATE dbo.fn_RowLevelSecurityPredicate(Department) 
ON dbo.EmployeeBaseHistory
WITH (STATE = ON);
GO

--  Validate the filtering policy

SELECT * FROM EmployeeBase

--  The filter function works similarly to an APPLY statement, returning a single value for each row

select eb.Name, eb.Position, eb.Department, p.fn_RowLevelSecurityPredicate_result
 from EmployeeBase eb
 OUTER APPLY dbo.fn_RowLevelSecurityPredicate(eb.Department) p

 /*
 Go back over to the web application and show the same results
 */

--  Validate that the fitler mechanism is working across both tables in the system-time versioned table

SELECT * FROM dbo.EmployeeBase
FOR SYSTEM_TIME AS OF '2016-02-17 18:00:00.00'

SELECT * FROM dbo.Employees
FOR SYSTEM_TIME AS OF '2016-02-17 18:00:00.00'

--  Drop the objects and the querying goes back to normal

DROP SECURITY POLICY EmployeesBaseFilter
GO
DROP SECURITY POLICY EmployeesBaseHistoryFilter
GO
DROP FUNCTION dbo.fn_RowLevelSecurityPredicate
GO

/**************************************************************************
Always Encrypted

This feature of SQL 2016 will enable data to be encrypted while moving and at rest.

OK, this one was rough to wire up in the MVC application.  First, create the Master Key
and then the Column Key in SSMS.  That certificate will be stored on your local user
certificate store (unless you choose otherwise).  By having that certificate stored locally,
you can leverage the .Net libraries to decrypt that data (.Net 4.6 or higher) without any special
commands.  The SQL Server connection string does need to have the following added:
	
	Column Encryption Setting=Enabled

Once encryption is configured, the data is no longer able to be viewed in plain text outside
the context provided by the .Net library that uses the certificate.  Even with the connection option
enabled in SSMS, the value is still not readable/unencrypted.

*/

--SQL2016AlwaysEncryptedMasterKey
--SQL2016AlwaysEncryptedColumnKey

--  Create the table with an encrypted column

DROP TABLE IF EXISTS [dbo].[EmployeeEncrypt]
GO

CREATE TABLE [dbo].[EmployeeEncrypt](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL CONSTRAINT pkEmployeeEncrypt PRIMARY KEY,
	[Name] [nvarchar](100) NOT NULL,
	[Position] [varchar](100) NOT NULL,
	[Department] [varchar](100) NOT NULL,
	[Address] [nvarchar](1024) NOT NULL,
	[AnnualSalary] [decimal](10, 2) NOT NULL,
	[SSN] CHAR(12) COLLATE Latin1_General_BIN2 
	--[SSN] CHAR(12) COLLATE Latin1_General_BIN2 ENCRYPTED WITH (ENCRYPTION_TYPE = DETERMINISTIC, ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256', COLUMN_ENCRYPTION_KEY = SQL2016AlwaysEncryptedColumnKey)
	);
GO

--  Insert values that will become visible in the web application
--   and leave the SSN null since we'll be filling that in.

INSERT INTO dbo.[EmployeeEncrypt] (Name, Position, Department, Address, AnnualSalary, SSN)
SELECT 'Vinnie','Consultant','Data Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Ted','Consultant','Mobile Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Bill','Consultant','Data Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Rachael','Consultant','Project Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Ashley','Consultant','Data Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Conor','Consultant','Data Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Ralph','Consultant','Project Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Ester','Consultant','Data Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Minnie','Consultant','Collaboration Solutions','123 Polaris Pkwy','75000', NULL
UNION ALL SELECT 'Kamesh','Consultant','Collaboration Solutions','123 Polaris Pkwy','75000', NULL
GO

INSERT INTO dbo.[EmployeeEncrypt] (Name, Position, Department, Address, AnnualSalary, SSN)
SELECT 'Vinnie','Consultant','Data Solutions','123 Polaris Pkwy','75000', '123-45-6789'
UNION ALL SELECT 'Ted','Consultant','Mobile Solutions','123 Polaris Pkwy','75000', '223-45-6789'
UNION ALL SELECT 'Bill','Consultant','Data Solutions','123 Polaris Pkwy','75000', '323-45-6789'
UNION ALL SELECT 'Rachael','Consultant','Project Solutions','123 Polaris Pkwy','75000', '423-45-6789'
UNION ALL SELECT 'Ashley','Consultant','Data Solutions','123 Polaris Pkwy','75000', '523-45-6789'
UNION ALL SELECT 'Conor','Consultant','Data Solutions','123 Polaris Pkwy','75000', '623-45-6789'
UNION ALL SELECT 'Ralph','Consultant','Project Solutions','123 Polaris Pkwy','75000', '723-45-6789'
UNION ALL SELECT 'Ester','Consultant','Data Solutions','123 Polaris Pkwy','75000', '823-45-6789'
UNION ALL SELECT 'Minnie','Consultant','Collaboration Solutions','123 Polaris Pkwy','75000', '923-45-6789'
UNION ALL SELECT 'Kamesh','Consultant','Collaboration Solutions','123 Polaris Pkwy','75000', '023-45-6789'
GO

--  Check the results

SELECT * FROM dbo.[EmployeeEncrypt]

-- Similar to the earlier insert/update/delete procedures, this part of the app
--  will use a stored procedure for data insert.

DROP PROC IF EXISTS dbo.spEmployeeEncryptUpdate
GO

CREATE PROC dbo.spEmployeeEncryptUpdate
@EmployeeID INT
, @Name [nvarchar](100)
, @Position [nvarchar](100)
, @Department [nvarchar](100)
, @Address [nvarchar](1024)
, @AnnualSalary [decimal](10, 2)
, @SSN CHAR(12) = NULL  --  Since we will sometimes push a null in the MVC app
AS
BEGIN
	BEGIN TRY
		UPDATE dbo.[EmployeeEncrypt] 
		SET Name = @Name
		, Position = @Position
		, Department = @Department
		, Address = @Address
		, AnnualSalary = @AnnualSalary
		, SSN = @SSN
		WHERE EmployeeID = @EmployeeID
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END
GO

--  Show the error

INSERT INTO dbo.[EmployeeEncrypt] (Name, Position, Department, Address, AnnualSalary, SSN)
SELECT 'Vinnie','Consultant','Data Solutions','123 Polaris Pkwy','75000', '123-456-7890'

/*
GO into the web application and make changes
*/