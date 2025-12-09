CREATE LOGIN Branch_2 WITH PASSWORD = 'thanh1234';

USE Branch_2;
GO

CREATE USER Branch_2 FOR LOGIN Branch_2;
ALTER ROLE db_owner ADD MEMBER Branch_2;

SELECT name, type_desc
FROM sys.server_principals
WHERE name = 'Branch_2';

--Connect Branch 1----
EXEC sp_addlinkedserver   
    @server     = 'Branch_1',      -- name you assign
    @srvproduct = '',                    -- can be empty for SQL Server
    @provider   = 'SQLOLEDB',             -- or 'MSOLEDBSQL', 'SQLOLEDB'
    @datasrc    = '26.50.54.179';    -- network name or IP
EXEC sp_addlinkedsrvlogin   
    @rmtsrvname = 'Branch_1',
    @useself    = 'False',
    @locallogin = NULL,                  -- all local logins
    @rmtuser    = 'Branch_1',
    @rmtpassword= 'ngoc1234';

---Connect Branch 3---
EXEC sp_addlinkedserver   
    @server     = 'Branch_3',      -- name you assign
    @srvproduct = '',                    -- can be empty for SQL Server
    @provider   = 'SQLOLEDB',             -- or 'MSOLEDBSQL', 'SQLOLEDB'
    @datasrc    = '26.118.79.75';    -- network name or IP
EXEC sp_addlinkedsrvlogin   
    @rmtsrvname = 'Branch_3',
    @useself    = 'False',
    @locallogin = NULL,                  -- all local logins
    @rmtuser    = 'Branch_3',
    @rmtpassword= 'thinh1234';