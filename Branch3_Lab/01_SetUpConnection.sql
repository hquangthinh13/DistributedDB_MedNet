CREATE LOGIN Branch_3 WITH PASSWORD = 'thinh1234';

USE Branch_3;
GO

CREATE USER Branch_3 FOR LOGIN Branch_3;
ALTER ROLE db_owner ADD MEMBER Branch_3;

--Linked servers:
----Branch 1:
EXEC sp_addlinkedserver   
    @server     = 'Branch_1',     
    @srvproduct = '',                  
    @provider   = 'SQLOLEDB',            
    @datasrc    = '26.50.54.179';    

EXEC sp_addlinkedsrvlogin   
    @rmtsrvname = 'Branch_1',
    @useself    = 'False',
    @locallogin = NULL,                 
    @rmtuser    = 'Branch_1',
    @rmtpassword= 'ngoc1234';

----Branch 2:
EXEC sp_addlinkedserver   
    @server     = 'Branch_2',     
    @srvproduct = '',                  
    @provider   = 'SQLOLEDB',            
    @datasrc    = '26.111.241.214';    

EXEC sp_addlinkedsrvlogin   
    @rmtsrvname = 'Branch_2',
    @useself    = 'False',
    @locallogin = NULL,                 
    @rmtuser    = 'Branch_2',
    @rmtpassword= 'thanh1234';


