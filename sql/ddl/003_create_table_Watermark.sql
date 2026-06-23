-- ============================================================
-- Table: EDP_Metadata.Watermark
-- Purpose: Stores watermark timestamps used by incremental
--          pipelines to track the last successfully loaded
--          high-water mark per data source.
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'Watermark'
)
BEGIN
    CREATE TABLE EDP_Metadata.Watermark (
        Watermark_ID      INT            IDENTITY(1,1)  NOT NULL,
        Watermark_Value   DATETIME       NOT NULL,
        Watermark_Column  NVARCHAR(100)  NULL,

        CONSTRAINT PK_Watermark PRIMARY KEY CLUSTERED (Watermark_ID)
    );
END
