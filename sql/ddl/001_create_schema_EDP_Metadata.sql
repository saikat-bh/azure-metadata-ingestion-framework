-- ============================================================
-- Schema: EDP_Metadata
-- Purpose: Houses all metadata control tables for the
--          metadata-driven ingestion framework.
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.schemas WHERE name = 'EDP_Metadata'
)
BEGIN
    EXEC('CREATE SCHEMA EDP_Metadata');
END
