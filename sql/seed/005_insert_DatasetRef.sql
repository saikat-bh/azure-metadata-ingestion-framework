-- ============================================================
-- Seed: EDP_Metadata.DatasetRef
-- Purpose: Inserts all valid Source × FileFormat dataset
--          combinations supported by ADF. This table is
--          framework-managed — users do not add rows here.
--
-- Naming convention: DS_{Source_Ref}_{Format}
--   SQL / table-based sources use TABLE suffix (FileFormat NULL)
--
-- Source coverage:
--   ADLS Gen2     : all 12 formats (incl. Zip, Tar)
--   Azure SQL     : TABLE (no file format)
--   On-Prem Oracle: TABLE (no file format)
--   On-Prem MySQL : TABLE (no file format)
--   SFTP          : flat-file formats (CSV,JSON,XML,Binary,
--                   DelimitedText,Excel,Zip,Tar)
--   FTP           : same as SFTP
--   Cosmos DB     : JSON only
--   Azure Databricks: Delta, Parquet, CSV, JSON
--   REST API      : JSON, XML
--   Key Vault     : excluded (secret store, not a data dataset)
--   Function App  : excluded (compute trigger, not a copy source)
-- ============================================================

INSERT INTO EDP_Metadata.DatasetRef (Dataset_Name, Source_ID, FileFormat_ID)
SELECT
    v.Dataset_Name,
    (SELECT Source_ID FROM EDP_Metadata.SourceRef  WHERE Source_Ref = v.SrcRef),
    (SELECT FileFormat_ID FROM EDP_Metadata.FileFormat WHERE Format  = v.Format)
FROM (
    VALUES
        -- ── ADLS Gen2 (all formats) ──────────────────────────────────
        ('DS_ADLS_CSV',             'ADLS', 'CSV'),
        ('DS_ADLS_JSON',            'ADLS', 'JSON'),
        ('DS_ADLS_PARQUET',         'ADLS', 'Parquet'),
        ('DS_ADLS_AVRO',            'ADLS', 'Avro'),
        ('DS_ADLS_ORC',             'ADLS', 'ORC'),
        ('DS_ADLS_EXCEL',           'ADLS', 'Excel'),
        ('DS_ADLS_XML',             'ADLS', 'XML'),
        ('DS_ADLS_BINARY',          'ADLS', 'Binary'),
        ('DS_ADLS_DELTA',           'ADLS', 'Delta'),
        ('DS_ADLS_DELIMITEDTEXT',   'ADLS', 'DelimitedText'),
        ('DS_ADLS_ZIP',             'ADLS', 'Zip'),
        ('DS_ADLS_TAR',             'ADLS', 'Tar'),

        -- ── SFTP (flat-file formats) ──────────────────────────────────
        ('DS_SFTP_CSV',             'SFTP', 'CSV'),
        ('DS_SFTP_JSON',            'SFTP', 'JSON'),
        ('DS_SFTP_XML',             'SFTP', 'XML'),
        ('DS_SFTP_BINARY',          'SFTP', 'Binary'),
        ('DS_SFTP_DELIMITEDTEXT',   'SFTP', 'DelimitedText'),
        ('DS_SFTP_EXCEL',           'SFTP', 'Excel'),
        ('DS_SFTP_ZIP',             'SFTP', 'Zip'),
        ('DS_SFTP_TAR',             'SFTP', 'Tar'),

        -- ── FTP (flat-file formats) ───────────────────────────────────
        ('DS_FTP_CSV',              'FTP',  'CSV'),
        ('DS_FTP_JSON',             'FTP',  'JSON'),
        ('DS_FTP_XML',              'FTP',  'XML'),
        ('DS_FTP_BINARY',           'FTP',  'Binary'),
        ('DS_FTP_DELIMITEDTEXT',    'FTP',  'DelimitedText'),
        ('DS_FTP_EXCEL',            'FTP',  'Excel'),
        ('DS_FTP_ZIP',              'FTP',  'Zip'),
        ('DS_FTP_TAR',              'FTP',  'Tar'),

        -- ── Azure Databricks (structured + file formats) ──────────────
        ('DS_ADB_DELTA',            'ADB',  'Delta'),
        ('DS_ADB_PARQUET',          'ADB',  'Parquet'),
        ('DS_ADB_CSV',              'ADB',  'CSV'),
        ('DS_ADB_JSON',             'ADB',  'JSON'),

        -- ── Cosmos DB ─────────────────────────────────────────────────
        ('DS_COSMOS_JSON',          'COSMOS','JSON'),

        -- ── REST API ──────────────────────────────────────────────────
        ('DS_REST_JSON',            'REST', 'JSON'),
        ('DS_REST_XML',             'REST', 'XML')

) AS v(Dataset_Name, SrcRef, Format)
WHERE NOT EXISTS (
    SELECT 1 FROM EDP_Metadata.DatasetRef d WHERE d.Dataset_Name = v.Dataset_Name
);

-- ── SQL / table-based sources (FileFormat_ID = NULL) ─────────────
INSERT INTO EDP_Metadata.DatasetRef (Dataset_Name, Source_ID, FileFormat_ID)
SELECT v.Dataset_Name,
    (SELECT Source_ID FROM EDP_Metadata.SourceRef WHERE Source_Ref = v.SrcRef),
    NULL
FROM (
    VALUES
        ('DS_ASQL_TABLE',  'ASQL'),
        ('DS_ORA_TABLE',   'ORA'),
        ('DS_MYSQL_TABLE', 'MYSQL')
) AS v(Dataset_Name, SrcRef)
WHERE NOT EXISTS (
    SELECT 1 FROM EDP_Metadata.DatasetRef d WHERE d.Dataset_Name = v.Dataset_Name
);
