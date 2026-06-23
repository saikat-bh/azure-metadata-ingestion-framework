-- ============================================================
-- Seed: EDP_Metadata.SystemAuth
-- Purpose: Inserts all authentication types supported by ADF
--          linked services, covering:
--            ADLS Gen2, Azure SQL, Key Vault,
--            On-Prem Oracle / MySQL, Function App,
--            SFTP, FTP, Cosmos DB, Azure Databricks, Rest API
-- ============================================================

INSERT INTO EDP_Metadata.SystemAuth (Authentication_Type)
SELECT v.Authentication_Type
FROM (
    VALUES
        -- ── Identity & Service Principal ─────────────────────
        -- ADLS Gen2, Azure SQL, Key Vault, Cosmos DB, Databricks, Rest API
        ('Service Principal'),
        ('System-Assigned Managed Identity'),
        ('User-Assigned Managed Identity'),

        -- ── Storage-level keys ───────────────────────────────
        -- ADLS Gen2, Cosmos DB
        ('Account Key'),
        ('Shared Access Signature'),

        -- ── SQL / Windows credential ─────────────────────────
        -- Azure SQL, On-Prem Oracle, On-Prem MySQL
        ('SQL Authentication'),
        ('Windows Authentication'),

        -- ── Generic credential-based ─────────────────────────
        -- FTP, SFTP, On-Prem Oracle, On-Prem MySQL, Rest API
        ('Basic'),
        ('Anonymous'),

        -- ── SSH / Multi-factor ───────────────────────────────
        -- SFTP
        ('SSH Public Key'),
        ('Multi-Factor Authentication'),

        -- ── Token-based ──────────────────────────────────────
        -- Azure Databricks
        ('Access Token'),

        -- ── OAuth2 / API Key ─────────────────────────────────
        -- Rest API
        ('OAuth2 Client Credentials'),
        ('API Key'),

        -- ── Azure Function App ────────────────────────────────
        ('Function Key'),
        ('System Key'),

        -- ── Key Vault-backed credential reference ─────────────
        -- Any connector using AKV-stored secrets
        ('Credential Reference')

) AS v(Authentication_Type)
WHERE NOT EXISTS (
    SELECT 1
    FROM   EDP_Metadata.SystemAuth a
    WHERE  a.Authentication_Type = v.Authentication_Type
);
