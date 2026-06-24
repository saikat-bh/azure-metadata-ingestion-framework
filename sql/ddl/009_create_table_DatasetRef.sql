-- ============================================================
-- Table: EDP_Metadata.DatasetRef
-- Purpose: Managed lookup table of all valid ADF dataset types,
--          defined as a unique combination of Source and
--          FileFormat. This is a framework-level table — rows
--          are seeded, not user-created.
--
-- Naming convention: DS_{Source_Ref}_{Format}
--   e.g. DS_ADLS_PARQUET, DS_SFTP_ZIP, DS_ASQL_TABLE
--
-- Column notes:
--   Source_ID     : FK to SourceRef — which data platform
--   FileFormat_ID : FK to FileFormat — NULL for SQL / table-based
--                   sources (Oracle, MySQL, Azure SQL) where the
--                   concept of a file format does not apply.
--                   Dataset_Name uses TABLE suffix for these.
--
-- Runtime parameters (container, path, table, schema, server)
-- are NOT stored here — they are supplied at job-execution time
-- via MetadataRef.MetadataSettingsInput / MetadataSettingsOutput.
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
        Dataset_ID     INT            IDENTITY(1,1)  NOT NULL,
        Dataset_Name   NVARCHAR(200)  NOT NULL,
        Source_ID      INT            NOT NULL,
        FileFormat_ID  INT            NULL,

        CONSTRAINT PK_DatasetRef
            PRIMARY KEY CLUSTERED (Dataset_ID),

        CONSTRAINT UQ_DatasetRef_Name
            UNIQUE (Dataset_Name),

        CONSTRAINT UQ_DatasetRef_SourceFormat
            UNIQUE (Source_ID, FileFormat_ID),

        CONSTRAINT FK_DatasetRef_Source
            FOREIGN KEY (Source_ID)
            REFERENCES EDP_Metadata.SourceRef (Source_ID),

        CONSTRAINT FK_DatasetRef_FileFormat
            FOREIGN KEY (FileFormat_ID)
            REFERENCES EDP_Metadata.FileFormat (FileFormat_ID)
    );
END
ELSE
BEGIN
    -- ── Migrate from old schema (if upgrading) ────────────────────
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DatasetRef_LinkedService'
               AND parent_object_id = OBJECT_ID('EDP_Metadata.DatasetRef'))
        ALTER TABLE EDP_Metadata.DatasetRef DROP CONSTRAINT FK_DatasetRef_LinkedService;

    IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_DatasetRef_IsActive'
               AND parent_object_id = OBJECT_ID('EDP_Metadata.DatasetRef'))
        ALTER TABLE EDP_Metadata.DatasetRef DROP CONSTRAINT DF_DatasetRef_IsActive;

    DECLARE @cols TABLE (col NVARCHAR(100));
    INSERT @cols VALUES ('LinkedService_ID'),('Schema_Name'),('Table_Name'),
                        ('Container'),('FolderPath'),('FileName'),('IsActive');
    DECLARE @col NVARCHAR(100);
    DECLARE c CURSOR FOR SELECT col FROM @cols;
    OPEN c; FETCH NEXT FROM c INTO @col;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.DatasetRef') AND name = @col)
        BEGIN
            DECLARE @sql NVARCHAR(500) = N'ALTER TABLE EDP_Metadata.DatasetRef DROP COLUMN ' + @col;
            EXEC sp_executesql @sql;
        END
        FETCH NEXT FROM c INTO @col;
    END
    CLOSE c; DEALLOCATE c;

    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.DatasetRef') AND name = 'Source_ID')
    BEGIN
        ALTER TABLE EDP_Metadata.DatasetRef ADD Source_ID INT NOT NULL
            CONSTRAINT FK_DatasetRef_Source FOREIGN KEY REFERENCES EDP_Metadata.SourceRef(Source_ID);
    END

    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UQ_DatasetRef_SourceFormat'
                   AND object_id = OBJECT_ID('EDP_Metadata.DatasetRef'))
        ALTER TABLE EDP_Metadata.DatasetRef
        ADD CONSTRAINT UQ_DatasetRef_SourceFormat UNIQUE (Source_ID, FileFormat_ID);
END
