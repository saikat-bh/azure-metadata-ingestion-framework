-- ============================================================
-- Seed: EDP_Metadata.SystemAuth
-- Purpose: Inserts all authentication types supported by ADF
--          linked services with their short ref codes and
--          applicable connectors.
--          Convention: LS_{Source_Ref}_{Auth_Ref}
--          e.g. LS_ADLS_SAMI, LS_ASQL_SP, LS_REST_OAUTH2
-- ============================================================

INSERT INTO EDP_Metadata.SystemAuth (Authentication_Type, Auth_Ref, Connectors)
SELECT v.Authentication_Type, v.Auth_Ref, v.Connectors
FROM (
    VALUES
        ('Service Principal',                'SP',      'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('System-Assigned Managed Identity', 'SAMI',    'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('User-Assigned Managed Identity',   'UAMI',    'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks'),
        ('Account Key',                      'AK',      'ADLS Gen2, Cosmos DB'),
        ('Shared Access Signature',          'SAS',     'ADLS Gen2'),
        ('SQL Authentication',               'SQLA',    'Azure SQL, On-Prem Oracle, On-Prem MySQL'),
        ('Windows Authentication',           'WIN',     'On-Prem Oracle, On-Prem MySQL'),
        ('Basic',                            'BASIC',   'FTP, SFTP, On-Prem Oracle, On-Prem MySQL, REST API'),
        ('Anonymous',                        'ANON',    'FTP, REST API'),
        ('SSH Public Key',                   'SSH',     'SFTP'),
        ('Multi-Factor Authentication',      'MFA',     'SFTP'),
        ('Access Token',                     'AT',      'Azure Databricks'),
        ('OAuth2 Client Credentials',        'OAUTH2',  'REST API'),
        ('API Key',                          'APIKEY',  'REST API'),
        ('Function Key',                     'FKEY',    'Function App'),
        ('System Key',                       'SKEY',    'Function App'),
        ('Credential Reference',             'CREDREF', 'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, FTP, SFTP, REST API, Function App, On-Prem Oracle, On-Prem MySQL')
) AS v(Authentication_Type, Auth_Ref, Connectors)
WHERE NOT EXISTS (
    SELECT 1
    FROM   EDP_Metadata.SystemAuth a
    WHERE  a.Authentication_Type = v.Authentication_Type
);

-- Backfill Auth_Ref and Connectors for rows inserted before these columns existed
UPDATE a
SET    a.Auth_Ref   = v.Auth_Ref,
       a.Connectors = v.Connectors
FROM   EDP_Metadata.SystemAuth a
JOIN (
    VALUES
        ('Service Principal',                'SP',      'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('System-Assigned Managed Identity', 'SAMI',    'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('User-Assigned Managed Identity',   'UAMI',    'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks'),
        ('Account Key',                      'AK',      'ADLS Gen2, Cosmos DB'),
        ('Shared Access Signature',          'SAS',     'ADLS Gen2'),
        ('SQL Authentication',               'SQLA',    'Azure SQL, On-Prem Oracle, On-Prem MySQL'),
        ('Windows Authentication',           'WIN',     'On-Prem Oracle, On-Prem MySQL'),
        ('Basic',                            'BASIC',   'FTP, SFTP, On-Prem Oracle, On-Prem MySQL, REST API'),
        ('Anonymous',                        'ANON',    'FTP, REST API'),
        ('SSH Public Key',                   'SSH',     'SFTP'),
        ('Multi-Factor Authentication',      'MFA',     'SFTP'),
        ('Access Token',                     'AT',      'Azure Databricks'),
        ('OAuth2 Client Credentials',        'OAUTH2',  'REST API'),
        ('API Key',                          'APIKEY',  'REST API'),
        ('Function Key',                     'FKEY',    'Function App'),
        ('System Key',                       'SKEY',    'Function App'),
        ('Credential Reference',             'CREDREF', 'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, FTP, SFTP, REST API, Function App, On-Prem Oracle, On-Prem MySQL')
) AS v(Authentication_Type, Auth_Ref, Connectors)
  ON  a.Authentication_Type = v.Authentication_Type
WHERE a.Auth_Ref IS NULL OR a.Connectors IS NULL;
