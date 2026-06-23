-- ============================================================
-- Table: EDP_Metadata.FileFormat
-- Purpose: Lookup table for all file formats supported by ADF.
--          FileFormat_ID is referenced by dataset metadata rows.
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'FileFormat'
)
BEGIN
    CREATE TABLE EDP_Metadata.FileFormat (
        FileFormat_ID   INT            IDENTITY(1,1)  NOT NULL,
        Format          NVARCHAR(50)   NOT NULL,

        CONSTRAINT PK_FileFormat PRIMARY KEY CLUSTERED (FileFormat_ID),
        CONSTRAINT UQ_FileFormat_Format UNIQUE (Format)
    );
END
