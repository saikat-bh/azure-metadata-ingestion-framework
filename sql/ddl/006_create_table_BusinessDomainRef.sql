-- ============================================================
-- Table: EDP_Metadata.BusinessDomainRef
-- Purpose: Lookup table for business domains. Domain_ID is
--          referenced by pipeline metadata rows to classify
--          data sources by business function.
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'BusinessDomainRef'
)
BEGIN
    CREATE TABLE EDP_Metadata.BusinessDomainRef (
        Domain_ID    INT            IDENTITY(1,1)  NOT NULL,
        Domain_Name  NVARCHAR(100)  NOT NULL,

        CONSTRAINT PK_BusinessDomainRef          PRIMARY KEY CLUSTERED (Domain_ID),
        CONSTRAINT UQ_BusinessDomainRef_Name     UNIQUE (Domain_Name)
    );
END
