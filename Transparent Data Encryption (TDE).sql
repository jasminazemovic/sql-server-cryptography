USE master;
GO

--Master encryption key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Some3xtr4Passw00rd';
GO

--Certificat to latter encrypt database master key
CREATE CERTIFICATE TDE WITH SUBJECT = 'My TDE Certificate';
GO

SELECT * FROM sys.certificates
WHERE name = 'TDE'
GO

--Demo database
CREATE DATABASE CryptoDB
GO

USE CryptoDB 
GO

--Database encrytpion key defended by TDE certificate
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDE;
GO

--Activate TDE
ALTER DATABASE CryptoDB
SET ENCRYPTION ON;
GO

--Now you can try to detach database and atach on another server or instance, it will faild

--Deactivate TDE
ALTER DATABASE CryptoDB
SET ENCRYPTION OFF;
GO

--Cleaning
DROP CERTIFICATE TDE
GO

DROP DATABASE ENCRYPTION KEY 
GO

USE master
GO

DROP CERTIFICATE TDE
GO

DROP MASTER KEY
GO
DROP DATABASE CryptoDB
GO
