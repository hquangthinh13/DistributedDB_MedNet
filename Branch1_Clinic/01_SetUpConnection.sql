CREATE LOGIN Branch_1 WITH PASSWORD = 'ngoc1234';

USE Branch_1;
GO

CREATE USER Branch_1 FOR LOGIN Branch_1;
ALTER ROLE db_owner ADD MEMBER Branch_1;

--Linked servers:
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

----Branch 3:
EXEC sp_addlinkedserver   
    @server     = 'Branch_3',
    @srvproduct = '',           
    @provider   = 'SQLOLEDB',             
    @datasrc    = '26.118.79.75';    
EXEC sp_addlinkedsrvlogin   
    @rmtsrvname = 'Branch_3',
    @useself    = 'False',
    @locallogin = NULL,                  
    @rmtuser    = 'Branch_3',
    @rmtpassword= 'thinh1234';


