-- Encryptedion and decryption od data using an authenticator value
 
CREATE DATABASE CryptoAuthenticator;
GO

USE CryptoAuthenticator;
GO
 
-- Create a simple employee table
CREATE TABLE Employees 
	(	EmployeeID int PRIMARY KEY, 
		Name varchar(300), 
		Salary varbinary(300)
	);
GO

-- Create a key
CREATE SYMMETRIC KEY SymKeyEmployees 
	WITH ALGORITHM = AES_192 
	ENCRYPTION BY PASSWORD = '#fgth3!@j7hSWl9';
GO

-- Open the key
OPEN SYMMETRIC KEY SymKeyEmployees 
DECRYPTION BY PASSWORD = '#fgth3!@j7hSWl9';
GO
 
-- Verify key was opened
SELECT * FROM sys.openkeys;
 
-- Insert some data
-- We will use the EmployeeID as an authenticator value to tie the Salary to the employee EmployeeID
INSERT INTO Employees VALUES 
	(101, 'Jasmin Azemovic', 
	 EncryptByKey(Key_guid('SymKeyEmployees'),'KM200000', 1, '101'));

INSERT INTO Employees VALUES 
	(102, 'Denis Mušic', 
	 EncryptByKey(Key_Guid('SymKeyEmployees'), 'KM100000', 1, '102'));


--Salary is encrypted
SELECT * FROM Employees;
 
-- Create a view to automatically do the DECRYPTION
-- Note that when decrypting we specify that the EmployeeID should be used as authenticator

CREATE VIEW viewEmployees 
AS SELECT EmployeeID, Name, 
		  CONVERT(varchar(10), 
		  DecryptByKey(Salary, 1, CONVERT(varchar(30), EmployeeID))) AS Salary 
	FROM Employees;
 
-- The decrypted data is available
SELECT * FROM viewEmployees;
 
-- Demonstartion the authenticator role
-- Copy Salary of Jasmin and overwrite the value for Denis

DECLARE @Salary varbinary(300);
SELECT @Salary = Salary FROM Employees WHERE EmployeeID = 101;
UPDATE Employees SET Salary = @Salary WHERE EmployeeID = 102;
GO
-- Note that both entries have the same Salary string
SELECT * FROM Employees;
 
-- See the result, the decrypted data for Denis is no longer available
-- Because it doesn't match the authenticator, which is his employee EmployeeID
SELECT * FROM viewEmployees;
 
-- Close the key
CLOSE SYMMETRIC KEY SymKeyEmployees;
 

-- Cleanup
DROP VIEW viewEmployees;
GO
DROP TABLE Employees;
GO
DROP SYMMETRIC KEY SymKeyEmployees;
GO
 
USE master;
GO
 
DROP DATABASE CryptoAuthenticator
GO
