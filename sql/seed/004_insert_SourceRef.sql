-- ============================================================
-- Seed: EDP_Metadata.SourceRef
-- Purpose: Inserts all supported ADF data sources with their
--          short reference codes used in linked service naming.
--          Convention: LS_{Source_Ref}_{Auth_Ref}
--          e.g. LS_ADLS_SAMI, LS_ASQL_SP, LS_REST_OAUTH2
-- ============================================================

INSERT INTO EDP_Metadata.SourceRef (Source, Source_Ref)
SELECT v.Source, v.Source_Ref
FROM (
    VALUES
        ('ADLS Gen2',       'ADLS'),
        ('Azure SQL',       'ASQL'),
        ('Key Vault',       'AKV'),
        ('On-Prem Oracle',  'ORA'),
        ('On-Prem MySQL',   'MYSQL'),
        ('Function App',    'FUNC'),
        ('SFTP',            'SFTP'),
        ('FTP',             'FTP'),
        ('Cosmos DB',       'COSMOS'),
        ('Azure Databricks','ADB'),
        ('REST API',        'REST')
) AS v(Source, Source_Ref)
WHERE NOT EXISTS (
    SELECT 1
    FROM   EDP_Metadata.SourceRef s
    WHERE  s.Source = v.Source
);
