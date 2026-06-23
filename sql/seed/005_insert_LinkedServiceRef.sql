-- ============================================================
-- Seed: EDP_Metadata.LinkedServiceRef
-- Purpose: Inserts all valid ADF linked service combinations
--          derived from SourceRef × SystemAuth.
--
--          JSON placeholder convention:
--            <placeholder>   → runtime dynamic parameter
--            Secret_Name     → name of the AKV secret to resolve
--            Credential_Name → name of the ADF credential object
--            Integration_Runtime → Self-Hosted IR name (on-prem only)
-- ============================================================

INSERT INTO EDP_Metadata.LinkedServiceRef
    (LinkedServiceName, Source_ID, Auth_ID, LinkedServiceConnectionString)
SELECT v.LinkedServiceName, s.Source_ID, a.Auth_ID, v.LinkedServiceConnectionString
FROM (VALUES

    -- ══════════════════════════════════════════════════════
    -- ADLS Gen2
    -- ══════════════════════════════════════════════════════
    ('LS_ADLS_SP',
        'ADLS Gen2', 'Service Principal',
        '{"URL":"https://<accountname>.dfs.core.windows.net","Tenant_ID":"<tenant_id>","Service_Principal_ID":"<sp_client_id>","Secret_Name":"<akv_secret_name>"}'),

    ('LS_ADLS_SAMI',
        'ADLS Gen2', 'System-Assigned Managed Identity',
        '{"URL":"https://<accountname>.dfs.core.windows.net"}'),

    ('LS_ADLS_UAMI',
        'ADLS Gen2', 'User-Assigned Managed Identity',
        '{"URL":"https://<accountname>.dfs.core.windows.net","Client_ID":"<uami_client_id>"}'),

    ('LS_ADLS_AK',
        'ADLS Gen2', 'Account Key',
        '{"URL":"https://<accountname>.dfs.core.windows.net","Secret_Name":"<akv_secret_name>"}'),

    ('LS_ADLS_SAS',
        'ADLS Gen2', 'Shared Access Signature',
        '{"URL":"https://<accountname>.dfs.core.windows.net","Secret_Name":"<akv_sas_token_secret_name>"}'),

    ('LS_ADLS_CREDREF',
        'ADLS Gen2', 'Credential Reference',
        '{"URL":"https://<accountname>.dfs.core.windows.net","Credential_Name":"<credential_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- Azure SQL
    -- ══════════════════════════════════════════════════════
    ('LS_ASQL_SP',
        'Azure SQL', 'Service Principal',
        '{"Server":"<server>.database.windows.net","Database":"<database>","Tenant_ID":"<tenant_id>","Service_Principal_ID":"<sp_client_id>","Secret_Name":"<akv_secret_name>"}'),

    ('LS_ASQL_SAMI',
        'Azure SQL', 'System-Assigned Managed Identity',
        '{"Server":"<server>.database.windows.net","Database":"<database>"}'),

    ('LS_ASQL_UAMI',
        'Azure SQL', 'User-Assigned Managed Identity',
        '{"Server":"<server>.database.windows.net","Database":"<database>","Client_ID":"<uami_client_id>"}'),

    ('LS_ASQL_SQLA',
        'Azure SQL', 'SQL Authentication',
        '{"Server":"<server>.database.windows.net","Database":"<database>","Username":"<username>","Secret_Name":"<akv_secret_name>"}'),

    ('LS_ASQL_CREDREF',
        'Azure SQL', 'Credential Reference',
        '{"Server":"<server>.database.windows.net","Database":"<database>","Credential_Name":"<credential_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- Key Vault
    -- ══════════════════════════════════════════════════════
    ('LS_AKV_SP',
        'Key Vault', 'Service Principal',
        '{"Base_URL":"https://<keyvault_name>.vault.azure.net","Tenant_ID":"<tenant_id>","Service_Principal_ID":"<sp_client_id>","Secret_Name":"<akv_secret_name>"}'),

    ('LS_AKV_SAMI',
        'Key Vault', 'System-Assigned Managed Identity',
        '{"Base_URL":"https://<keyvault_name>.vault.azure.net"}'),

    ('LS_AKV_UAMI',
        'Key Vault', 'User-Assigned Managed Identity',
        '{"Base_URL":"https://<keyvault_name>.vault.azure.net","Client_ID":"<uami_client_id>"}'),

    ('LS_AKV_CREDREF',
        'Key Vault', 'Credential Reference',
        '{"Base_URL":"https://<keyvault_name>.vault.azure.net","Credential_Name":"<credential_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- On-Prem Oracle  (requires Self-Hosted Integration Runtime)
    -- ══════════════════════════════════════════════════════
    ('LS_ORA_BASIC',
        'On-Prem Oracle', 'Basic',
        '{"Host":"<host>","Port":"1521","Service_Name":"<oracle_service_name>","Username":"<username>","Secret_Name":"<akv_password_secret_name>","Integration_Runtime":"<ir_name>"}'),

    ('LS_ORA_SQLA',
        'On-Prem Oracle', 'SQL Authentication',
        '{"Host":"<host>","Port":"1521","Service_Name":"<oracle_service_name>","Username":"<username>","Secret_Name":"<akv_password_secret_name>","Integration_Runtime":"<ir_name>"}'),

    ('LS_ORA_WIN',
        'On-Prem Oracle', 'Windows Authentication',
        '{"Host":"<host>","Port":"1521","Service_Name":"<oracle_service_name>","Integration_Runtime":"<ir_name>"}'),

    ('LS_ORA_CREDREF',
        'On-Prem Oracle', 'Credential Reference',
        '{"Host":"<host>","Port":"1521","Service_Name":"<oracle_service_name>","Credential_Name":"<credential_name>","Integration_Runtime":"<ir_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- On-Prem MySQL  (requires Self-Hosted Integration Runtime)
    -- ══════════════════════════════════════════════════════
    ('LS_MYSQL_BASIC',
        'On-Prem MySQL', 'Basic',
        '{"Server":"<host>","Port":"3306","Database":"<database>","Username":"<username>","Secret_Name":"<akv_password_secret_name>","Integration_Runtime":"<ir_name>"}'),

    ('LS_MYSQL_SQLA',
        'On-Prem MySQL', 'SQL Authentication',
        '{"Server":"<host>","Port":"3306","Database":"<database>","Username":"<username>","Secret_Name":"<akv_password_secret_name>","Integration_Runtime":"<ir_name>"}'),

    ('LS_MYSQL_WIN',
        'On-Prem MySQL', 'Windows Authentication',
        '{"Server":"<host>","Port":"3306","Database":"<database>","Integration_Runtime":"<ir_name>"}'),

    ('LS_MYSQL_CREDREF',
        'On-Prem MySQL', 'Credential Reference',
        '{"Server":"<host>","Port":"3306","Database":"<database>","Credential_Name":"<credential_name>","Integration_Runtime":"<ir_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- Function App
    -- ══════════════════════════════════════════════════════
    ('LS_FUNC_FKEY',
        'Function App', 'Function Key',
        '{"Function_URL":"https://<function_app_name>.azurewebsites.net/api/<function_name>","Secret_Name":"<akv_function_key_secret_name>"}'),

    ('LS_FUNC_SKEY',
        'Function App', 'System Key',
        '{"Function_URL":"https://<function_app_name>.azurewebsites.net/api/<function_name>","Secret_Name":"<akv_system_key_secret_name>"}'),

    ('LS_FUNC_SAMI',
        'Function App', 'System-Assigned Managed Identity',
        '{"Function_URL":"https://<function_app_name>.azurewebsites.net/api/<function_name>"}'),

    ('LS_FUNC_UAMI',
        'Function App', 'User-Assigned Managed Identity',
        '{"Function_URL":"https://<function_app_name>.azurewebsites.net/api/<function_name>","Client_ID":"<uami_client_id>"}'),

    ('LS_FUNC_ANON',
        'Function App', 'Anonymous',
        '{"Function_URL":"https://<function_app_name>.azurewebsites.net/api/<function_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- SFTP
    -- ══════════════════════════════════════════════════════
    ('LS_SFTP_BASIC',
        'SFTP', 'Basic',
        '{"Host":"<sftp_host>","Port":"22","Username":"<username>","Secret_Name":"<akv_password_secret_name>"}'),

    ('LS_SFTP_SSH',
        'SFTP', 'SSH Public Key',
        '{"Host":"<sftp_host>","Port":"22","Username":"<username>","Secret_Name":"<akv_private_key_secret_name>"}'),

    ('LS_SFTP_MFA',
        'SFTP', 'Multi-Factor Authentication',
        '{"Host":"<sftp_host>","Port":"22","Username":"<username>","Password_Secret_Name":"<akv_password_secret_name>","PrivateKey_Secret_Name":"<akv_privatekey_secret_name>"}'),

    ('LS_SFTP_ANON',
        'SFTP', 'Anonymous',
        '{"Host":"<sftp_host>","Port":"22"}'),

    -- ══════════════════════════════════════════════════════
    -- FTP
    -- ══════════════════════════════════════════════════════
    ('LS_FTP_BASIC',
        'FTP', 'Basic',
        '{"Host":"<ftp_host>","Port":"21","Username":"<username>","Secret_Name":"<akv_password_secret_name>"}'),

    ('LS_FTP_ANON',
        'FTP', 'Anonymous',
        '{"Host":"<ftp_host>","Port":"21"}'),

    -- ══════════════════════════════════════════════════════
    -- Cosmos DB
    -- ══════════════════════════════════════════════════════
    ('LS_COSMOS_SP',
        'Cosmos DB', 'Service Principal',
        '{"Account_Endpoint":"https://<account_name>.documents.azure.com:443/","Database":"<database>","Tenant_ID":"<tenant_id>","Service_Principal_ID":"<sp_client_id>","Secret_Name":"<akv_secret_name>"}'),

    ('LS_COSMOS_SAMI',
        'Cosmos DB', 'System-Assigned Managed Identity',
        '{"Account_Endpoint":"https://<account_name>.documents.azure.com:443/","Database":"<database>"}'),

    ('LS_COSMOS_UAMI',
        'Cosmos DB', 'User-Assigned Managed Identity',
        '{"Account_Endpoint":"https://<account_name>.documents.azure.com:443/","Database":"<database>","Client_ID":"<uami_client_id>"}'),

    ('LS_COSMOS_AK',
        'Cosmos DB', 'Account Key',
        '{"Account_Endpoint":"https://<account_name>.documents.azure.com:443/","Database":"<database>","Secret_Name":"<akv_account_key_secret_name>"}'),

    ('LS_COSMOS_CREDREF',
        'Cosmos DB', 'Credential Reference',
        '{"Account_Endpoint":"https://<account_name>.documents.azure.com:443/","Database":"<database>","Credential_Name":"<credential_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- Azure Databricks
    -- ══════════════════════════════════════════════════════
    ('LS_ADB_AT',
        'Azure Databricks', 'Access Token',
        '{"Workspace_URL":"https://<workspace_id>.azuredatabricks.net","Cluster_ID":"<cluster_id>","Secret_Name":"<akv_access_token_secret_name>"}'),

    ('LS_ADB_SAMI',
        'Azure Databricks', 'System-Assigned Managed Identity',
        '{"Workspace_URL":"https://<workspace_id>.azuredatabricks.net","Cluster_ID":"<cluster_id>"}'),

    ('LS_ADB_UAMI',
        'Azure Databricks', 'User-Assigned Managed Identity',
        '{"Workspace_URL":"https://<workspace_id>.azuredatabricks.net","Cluster_ID":"<cluster_id>","Client_ID":"<uami_client_id>"}'),

    ('LS_ADB_SP',
        'Azure Databricks', 'Service Principal',
        '{"Workspace_URL":"https://<workspace_id>.azuredatabricks.net","Cluster_ID":"<cluster_id>","Tenant_ID":"<tenant_id>","Service_Principal_ID":"<sp_client_id>","Secret_Name":"<akv_secret_name>"}'),

    -- ══════════════════════════════════════════════════════
    -- REST API
    -- ══════════════════════════════════════════════════════
    ('LS_REST_ANON',
        'REST API', 'Anonymous',
        '{"URL":"https://<api_base_url>"}'),

    ('LS_REST_BASIC',
        'REST API', 'Basic',
        '{"URL":"https://<api_base_url>","Username":"<username>","Secret_Name":"<akv_password_secret_name>"}'),

    ('LS_REST_SP',
        'REST API', 'Service Principal',
        '{"URL":"https://<api_base_url>","Tenant_ID":"<tenant_id>","Service_Principal_ID":"<sp_client_id>","Secret_Name":"<akv_secret_name>","Resource":"<resource_url>"}'),

    ('LS_REST_SAMI',
        'REST API', 'System-Assigned Managed Identity',
        '{"URL":"https://<api_base_url>","Resource":"<resource_url>"}'),

    ('LS_REST_UAMI',
        'REST API', 'User-Assigned Managed Identity',
        '{"URL":"https://<api_base_url>","Resource":"<resource_url>","Client_ID":"<uami_client_id>"}'),

    ('LS_REST_OAUTH2',
        'REST API', 'OAuth2 Client Credentials',
        '{"URL":"https://<api_base_url>","Token_Endpoint":"https://login.microsoftonline.com/<tenant_id>/oauth2/token","Client_ID":"<client_id>","Secret_Name":"<akv_client_secret_name>","Resource":"<resource_url>"}'),

    ('LS_REST_APIKEY',
        'REST API', 'API Key',
        '{"URL":"https://<api_base_url>","API_Key_Name":"<api_key_header_or_param_name>","API_Key_Location":"Header","Secret_Name":"<akv_api_key_secret_name>"}'),

    ('LS_REST_CREDREF',
        'REST API', 'Credential Reference',
        '{"URL":"https://<api_base_url>","Credential_Name":"<credential_name>"}')

) AS v(LinkedServiceName, SourceName, AuthType, LinkedServiceConnectionString)
JOIN EDP_Metadata.SourceRef  s ON s.Source              = v.SourceName
JOIN EDP_Metadata.SystemAuth a ON a.Authentication_Type = v.AuthType
WHERE NOT EXISTS (
    SELECT 1 FROM EDP_Metadata.LinkedServiceRef l
    WHERE  l.LinkedServiceName = v.LinkedServiceName
);
