-- ============================================================
-- Table: EDP_Metadata.LinkedServiceRef
-- Purpose: Catalogue of all ADF linked services derived from
--          valid Source × Authentication combinations.
--          LinkedServiceName follows the convention:
--              LS_{Source_Ref}_{Auth_Ref}
--          LinkedServiceConnectionString is a JSON template
--          where runtime values are supplied as dynamic
--          parameters by the metadata pipeline.
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'LinkedServiceRef'
)
BEGIN
    CREATE TABLE EDP_Metadata.LinkedServiceRef (
        LinkedService_ID              INT             IDENTITY(1,1)  NOT NULL,
        LinkedServiceName             NVARCHAR(100)   NOT NULL,
        LinkedServiceConnectionName   NVARCHAR(200)   NULL, -- Changed to NULL, allowed duplicates
        Source_ID                     INT             NOT NULL,
        Auth_ID                       INT             NOT NULL,
        LinkedServiceConnectionString NVARCHAR(MAX)   NOT NULL,

        CONSTRAINT PK_LinkedServiceRef               PRIMARY KEY CLUSTERED (LinkedService_ID),
        -- Removed UQ_LinkedServiceRef_Name to allow duplicate values
        -- Removed UQ_LinkedServiceRef_ConnName to allow duplicate values
        CONSTRAINT FK_LinkedServiceRef_Source        FOREIGN KEY (Source_ID)
            REFERENCES EDP_Metadata.SourceRef  (Source_ID),
        CONSTRAINT FK_LinkedServiceRef_Auth          FOREIGN KEY (Auth_ID)
            REFERENCES EDP_Metadata.SystemAuth (Auth_ID)
    );
END
ELSE
BEGIN
    -- 1. Drop existing unique constraints if they exist in the live database
    IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'UQ_LinkedServiceRef_Name' AND type = 'UQ')
    BEGIN
        ALTER TABLE EDP_Metadata.LinkedServiceRef DROP CONSTRAINT UQ_LinkedServiceRef_Name;
    END

    IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'UQ_LinkedServiceRef_ConnName' AND type = 'UQ')
    BEGIN
        ALTER TABLE EDP_Metadata.LinkedServiceRef DROP CONSTRAINT UQ_LinkedServiceRef_ConnName;
    END

    -- 2. Add the column as NULL if it does not exist
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.LinkedServiceRef') AND name = 'LinkedServiceConnectionName')
    BEGIN
        ALTER TABLE EDP_Metadata.LinkedServiceRef ADD LinkedServiceConnectionName NVARCHAR(200) NULL;
    END
    ELSE
    BEGIN
        -- If it exists but was previously NOT NULL, alter it to NULL
        ALTER TABLE EDP_Metadata.LinkedServiceRef ALTER COLUMN LinkedServiceConnectionName NVARCHAR(200) NULL;
    END
END
