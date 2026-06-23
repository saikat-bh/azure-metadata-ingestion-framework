-- ============================================================
-- Seed: EDP_Metadata.SystemAuth
-- Purpose: Inserts all authentication types supported by ADF
--          linked services with their applicable connectors.
-- ============================================================

INSERT INTO EDP_Metadata.SystemAuth (Authentication_Type, Connectors)
SELECT v.Authentication_Type, v.Connectors
FROM (
    VALUES
        ('Service Principal',                'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('System-Assigned Managed Identity', 'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('User-Assigned Managed Identity',   'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks'),
        ('Account Key',                      'ADLS Gen2, Cosmos DB'),
        ('Shared Access Signature',          'ADLS Gen2'),
        ('SQL Authentication',               'Azure SQL, On-Prem Oracle, On-Prem MySQL'),
        ('Windows Authentication',           'On-Prem Oracle, On-Prem MySQL'),
        ('Basic',                            'FTP, SFTP, On-Prem Oracle, On-Prem MySQL, REST API'),
        ('Anonymous',                        'FTP, REST API'),
        ('SSH Public Key',                   'SFTP'),
        ('Multi-Factor Authentication',      'SFTP'),
        ('Access Token',                     'Azure Databricks'),
        ('OAuth2 Client Credentials',        'REST API'),
        ('API Key',                          'REST API'),
        ('Function Key',                     'Function App'),
        ('System Key',                       'Function App'),
        ('Credential Reference',             'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, FTP, SFTP, REST API, Function App, On-Prem Oracle, On-Prem MySQL')
) AS v(Authentication_Type, Connectors)
WHERE NOT EXISTS (
    SELECT 1
    FROM   EDP_Metadata.SystemAuth a
    WHERE  a.Authentication_Type = v.Authentication_Type
);

-- Backfill Connectors for rows inserted before this column existed
UPDATE a
SET    a.Connectors = v.Connectors
FROM   EDP_Metadata.SystemAuth a
JOIN (
    VALUES
        ('Service Principal',                'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('System-Assigned Managed Identity', 'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, REST API'),
        ('User-Assigned Managed Identity',   'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks'),
        ('Account Key',                      'ADLS Gen2, Cosmos DB'),
        ('Shared Access Signature',          'ADLS Gen2'),
        ('SQL Authentication',               'Azure SQL, On-Prem Oracle, On-Prem MySQL'),
        ('Windows Authentication',           'On-Prem Oracle, On-Prem MySQL'),
        ('Basic',                            'FTP, SFTP, On-Prem Oracle, On-Prem MySQL, REST API'),
        ('Anonymous',                        'FTP, REST API'),
        ('SSH Public Key',                   'SFTP'),
        ('Multi-Factor Authentication',      'SFTP'),
        ('Access Token',                     'Azure Databricks'),
        ('OAuth2 Client Credentials',        'REST API'),
        ('API Key',                          'REST API'),
        ('Function Key',                     'Function App'),
        ('System Key',                       'Function App'),
        ('Credential Reference',             'ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Azure Databricks, FTP, SFTP, REST API, Function App, On-Prem Oracle, On-Prem MySQL')
) AS v(Authentication_Type, Connectors)
  ON  a.Authentication_Type = v.Authentication_Type
WHERE a.Connectors IS NULL;
