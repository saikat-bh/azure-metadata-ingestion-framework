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
        LinkedServiceConnectionName   NVARCHAR(200)   NOT NULL,
        Source_ID                     INT             NOT NULL,
        Auth_ID                       INT             NOT NULL,
        LinkedServiceConnectionString NVARCHAR(MAX)   NOT NULL,

        CONSTRAINT PK_LinkedServiceRef               PRIMARY KEY CLUSTERED (LinkedService_ID),
        CONSTRAINT UQ_LinkedServiceRef_Name          UNIQUE (LinkedServiceName),
        CONSTRAINT UQ_LinkedServiceRef_ConnName      UNIQUE (LinkedServiceConnectionName),
        CONSTRAINT FK_LinkedServiceRef_Source        FOREIGN KEY (Source_ID)
            REFERENCES EDP_Metadata.SourceRef  (Source_ID),
        CONSTRAINT FK_LinkedServiceRef_Auth          FOREIGN KEY (Auth_ID)
            REFERENCES EDP_Metadata.SystemAuth (Auth_ID)
    );
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.LinkedServiceRef') AND name = 'LinkedServiceConnectionName')
    BEGIN
        ALTER TABLE EDP_Metadata.LinkedServiceRef ADD LinkedServiceConnectionName NVARCHAR(200) NULL;
        UPDATE EDP_Metadata.LinkedServiceRef SET LinkedServiceConnectionName = LinkedServiceName WHERE LinkedServiceConnectionName IS NULL;
        ALTER TABLE EDP_Metadata.LinkedServiceRef ALTER COLUMN LinkedServiceConnectionName NVARCHAR(200) NOT NULL;
        ALTER TABLE EDP_Metadata.LinkedServiceRef ADD CONSTRAINT UQ_LinkedServiceRef_ConnName UNIQUE (LinkedServiceConnectionName);
    END
END
