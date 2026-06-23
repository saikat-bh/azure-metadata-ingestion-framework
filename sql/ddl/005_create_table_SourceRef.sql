-- ============================================================
-- Table: EDP_Metadata.SourceRef
-- Purpose: Lookup table for all supported data sources.
--          Source_Ref is the short code used to build
--          linked service names (e.g. LS_ADLS_SAMI).
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'SourceRef'
)
BEGIN
    CREATE TABLE EDP_Metadata.SourceRef (
        Source_ID   INT            IDENTITY(1,1)  NOT NULL,
        Source      NVARCHAR(100)  NOT NULL,
        Source_Ref  NVARCHAR(20)   NOT NULL,

        CONSTRAINT PK_SourceRef         PRIMARY KEY CLUSTERED (Source_ID),
        CONSTRAINT UQ_SourceRef_Source  UNIQUE (Source),
        CONSTRAINT UQ_SourceRef_Ref     UNIQUE (Source_Ref)
    );
END
