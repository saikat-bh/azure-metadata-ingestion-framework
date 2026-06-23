-- ============================================================
-- Table: EDP_Metadata.DatasetRef
-- Purpose: Catalogue of ADF dataset definitions. Each row
--          represents a dataset template combining a linked
--          service with format and structural/path metadata.
--          Referenced by MetadataRef.InputDataset_ID and
--          MetadataRef.OutputDataset_ID.
--
-- Naming convention: DS_{Source_Ref}_{Auth_Ref}_{Format}
--   e.g. DS_ADLS_SAMI_PARQUET, DS_ASQL_SQLA_TABLE
--
-- Column notes:
--   FileFormat_ID  : NULL for non-file sources (SQL, REST, Cosmos)
--   Schema_Name    : populated for SQL-based sources/targets
--   Table_Name     : populated for SQL-based sources/targets
--   Container      : populated for ADLS / Blob sources/targets
--   FolderPath     : populated for ADLS / Blob sources/targets
--   FileName       : populated for ADLS / Blob; NULL = dynamic/wildcard
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'DatasetRef'
)
BEGIN
    CREATE TABLE EDP_Metadata.DatasetRef (
        Dataset_ID        INT            IDENTITY(1,1)  NOT NULL,
        Dataset_Name      NVARCHAR(200)  NOT NULL,
        LinkedService_ID  INT            NOT NULL,
        FileFormat_ID     INT            NULL,
        Schema_Name       NVARCHAR(100)  NULL,
        Table_Name        NVARCHAR(200)  NULL,
        Container         NVARCHAR(200)  NULL,
        FolderPath        NVARCHAR(500)  NULL,
        FileName          NVARCHAR(200)  NULL,
        IsActive          BIT            NOT NULL  CONSTRAINT DF_DatasetRef_IsActive DEFAULT (1),

        CONSTRAINT PK_DatasetRef
            PRIMARY KEY CLUSTERED (Dataset_ID),

        CONSTRAINT UQ_DatasetRef_Name
            UNIQUE (Dataset_Name),

        CONSTRAINT FK_DatasetRef_LinkedService
            FOREIGN KEY (LinkedService_ID)
            REFERENCES EDP_Metadata.LinkedServiceRef (LinkedService_ID),

        CONSTRAINT FK_DatasetRef_FileFormat
            FOREIGN KEY (FileFormat_ID)
            REFERENCES EDP_Metadata.FileFormat (FileFormat_ID)
    );
END
