-- ============================================================
-- Seed: EDP_Metadata.FileFormat
-- Purpose: Inserts all file formats natively supported by ADF
--          copy activity and dataset connectors.
-- ============================================================

SET IDENTITY_INSERT EDP_Metadata.FileFormat OFF;

INSERT INTO EDP_Metadata.FileFormat (Format)
SELECT v.Format
FROM (
    VALUES
        ('CSV'),
        ('JSON'),
        ('Parquet'),
        ('Avro'),
        ('ORC'),
        ('Excel'),
        ('XML'),
        ('Binary'),
        ('Delta')
) AS v(Format)
WHERE NOT EXISTS (
    SELECT 1
    FROM   EDP_Metadata.FileFormat f
    WHERE  f.Format = v.Format
);
