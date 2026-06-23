-- ============================================================
-- Table: EDP_Metadata.SystemAuth
-- Purpose: Lookup table for all authentication types supported
--          by ADF linked services. Auth_ID is referenced by
--          linked service metadata rows.
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'SystemAuth'
)
BEGIN
    CREATE TABLE EDP_Metadata.SystemAuth (
        Auth_ID              INT            IDENTITY(1,1)  NOT NULL,
        Authentication_Type  NVARCHAR(100)  NOT NULL,
        Connectors           NVARCHAR(500)  NOT NULL,

        CONSTRAINT PK_SystemAuth       PRIMARY KEY CLUSTERED (Auth_ID),
        CONSTRAINT UQ_SystemAuth_Type  UNIQUE (Authentication_Type)
    );
END
ELSE
BEGIN
    -- Add Connectors column if upgrading from earlier version
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns
        WHERE  object_id = OBJECT_ID('EDP_Metadata.SystemAuth')
        AND    name = 'Connectors'
    )
    BEGIN
        ALTER TABLE EDP_Metadata.SystemAuth
        ADD Connectors NVARCHAR(500) NULL;
    END
END
