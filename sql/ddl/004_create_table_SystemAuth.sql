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
        Auth_ID              INT           IDENTITY(1,1)  NOT NULL,
        Authentication_Type  NVARCHAR(100) NOT NULL,

        CONSTRAINT PK_SystemAuth         PRIMARY KEY CLUSTERED (Auth_ID),
        CONSTRAINT UQ_SystemAuth_Type    UNIQUE (Authentication_Type)
    );
END
