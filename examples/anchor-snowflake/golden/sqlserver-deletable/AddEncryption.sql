-- ENCRYPTION GROUPS -------------------------------------------------------------------------------------------------
--
-- Certificates are created for the encryption groups defined in the metadata.
-- Please note that the "master" password is not stored anywhere after this script
-- has been run. In other words, YOU NEED TO KEEP TRACK OF THIS ELSEWHERE!
--
-- MASTER KEY ---------------------------------------------------------------------------------------------------------
-- The master key used to create certificates and other keys (should not be stored)
-----------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE [name] = '##MS_DatabaseMasterKey##')
BEGIN
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<TYPE STRONG PASSWORD HERE>';
END
GO
-- GROUP CERTIFICATE --------------------------------------------------------------------------------------------------
-- An encryption certificate used by the "PII" group
-----------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.certificates WHERE [name] = 'PII')
BEGIN
    CREATE CERTIFICATE [PII] WITH SUBJECT = 'PII';
END
-- GROUP KEY ----------------------------------------------------------------------------------------------------------
-- An encryption key used to encrypt the data in the attributes: 
--	AC_NAM_Actor_Name
-----------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE [name] = 'PII')
BEGIN
    CREATE SYMMETRIC KEY [PII]
    WITH ALGORITHM = AES_256, 
    IDENTITY_VALUE = 'PII'
    ENCRYPTION BY CERTIFICATE [PII];
END
