-- ============================================================
-- Seed: EDP_Metadata.Watermark
-- Purpose: Inserts the default watermark row using the earliest
--          possible DATETIME2 value. Incremental pipelines use
--          this as the starting point for first-time loads.
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM EDP_Metadata.Watermark WHERE Watermark_ID = 1)
BEGIN
    INSERT INTO EDP_Metadata.Watermark (Value)
    VALUES (CAST('0001-01-01 00:00:00.0000000' AS DATETIME2));
END
