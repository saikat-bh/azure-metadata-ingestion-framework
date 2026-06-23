-- ============================================================
-- Table: EDP_Metadata.BusinessDomainRef
-- Purpose: Lookup table for business domains. Business_Domain_ID is
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
        Business_Domain_ID    INT            IDENTITY(1,1)  NOT NULL,
        Business_Domain_Name  NVARCHAR(100)  NOT NULL,

        CONSTRAINT PK_BusinessDomainRef          PRIMARY KEY CLUSTERED (Business_Domain_ID),
        CONSTRAINT UQ_BusinessDomainRef_Name     UNIQUE (Business_Domain_Name)
    );
END
ELSE
BEGIN
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.BusinessDomainRef') AND name = 'Domain_ID')
        EXEC sp_rename 'EDP_Metadata.BusinessDomainRef.Domain_ID',   'Business_Domain_ID',   'COLUMN';
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.BusinessDomainRef') AND name = 'Domain_Name')
        EXEC sp_rename 'EDP_Metadata.BusinessDomainRef.Domain_Name', 'Business_Domain_Name', 'COLUMN';
END
