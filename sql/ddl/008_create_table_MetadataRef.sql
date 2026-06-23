-- ============================================================
-- Table: EDP_Metadata.MetadataRef
-- Purpose: Core control table for the metadata-driven ingestion
--          framework. Each row represents one ingestion job and
--          carries all parameters required by ADF pipelines at
--          runtime via Lookup activity.
--
-- Column notes:
--   ActivityType   : 0 = Ingress       | 1 = Egress
--   IsActive       : 0 = InActive      | 1 = Active
--   Load_Type      : 0 = Full Refresh  | 1 = Incremental
--   Watermark_ID   : NULL for Full Refresh jobs; must reference a
--                    dedicated Watermark row for Incremental jobs
--   InputDataset_ID  : FK to DatasetRef (source dataset)
--   OutputDataset_ID : FK to DatasetRef (target dataset)
-- ============================================================

IF NOT EXISTS (
    SELECT 1
    FROM   sys.tables  t
    JOIN   sys.schemas s ON s.schema_id = t.schema_id
    WHERE  s.name = 'EDP_Metadata'
    AND    t.name = 'MetadataRef'
)
BEGIN
    CREATE TABLE EDP_Metadata.MetadataRef (
        Metadata_ID        INT            IDENTITY(1,1)  NOT NULL,
        Metadata_Job       NVARCHAR(200)  NOT NULL,
        Business_Domain_ID INT            NULL,
        ADF_Name           NVARCHAR(100)  NOT NULL,
        Trigger_Name       NVARCHAR(200)  NOT NULL,
        InputDataset_ID    INT            NULL,
        OutputDataset_ID   INT            NULL,
        MetadataSettingsInput  NVARCHAR(MAX) NOT NULL CONSTRAINT DF_MetadataRef_SettingsInput  DEFAULT ('{}'),
        MetadataSettingsOutput NVARCHAR(MAX) NOT NULL CONSTRAINT DF_MetadataRef_SettingsOutput DEFAULT ('{}'),
        ActivityType       BIT            NOT NULL  CONSTRAINT DF_MetadataRef_ActivityType DEFAULT (0),
        IsActive           BIT            NOT NULL  CONSTRAINT DF_MetadataRef_IsActive     DEFAULT (0),
        Load_Type          BIT            NOT NULL  CONSTRAINT DF_MetadataRef_LoadType     DEFAULT (0),
        Watermark_ID       INT            NULL,
        Created_Date       DATETIME       NOT NULL  CONSTRAINT DF_MetadataRef_CreatedDate  DEFAULT (GETDATE()),
        Modified_Date      DATETIME       NOT NULL  CONSTRAINT DF_MetadataRef_ModifiedDate DEFAULT (GETDATE()),
        Modified_By        NVARCHAR(100)  NOT NULL  CONSTRAINT DF_MetadataRef_ModifiedBy   DEFAULT (SYSTEM_USER),

        CONSTRAINT PK_MetadataRef
            PRIMARY KEY CLUSTERED (Metadata_ID),

        CONSTRAINT UQ_MetadataRef_Job
            UNIQUE (Metadata_Job),

        CONSTRAINT FK_MetadataRef_BusinessDomain
            FOREIGN KEY (Business_Domain_ID)
            REFERENCES EDP_Metadata.BusinessDomainRef (Business_Domain_ID),

        CONSTRAINT FK_MetadataRef_InputDataset
            FOREIGN KEY (InputDataset_ID)
            REFERENCES EDP_Metadata.DatasetRef (Dataset_ID),

        CONSTRAINT FK_MetadataRef_OutputDataset
            FOREIGN KEY (OutputDataset_ID)
            REFERENCES EDP_Metadata.DatasetRef (Dataset_ID),

        CONSTRAINT FK_MetadataRef_Watermark
            FOREIGN KEY (Watermark_ID)
            REFERENCES EDP_Metadata.Watermark (Watermark_ID),

        CONSTRAINT CK_MetadataRef_ActivityType
            CHECK (ActivityType IN (0, 1)),

        CONSTRAINT CK_MetadataRef_IsActive
            CHECK (IsActive IN (0, 1)),

        CONSTRAINT CK_MetadataRef_LoadType
            CHECK (Load_Type IN (0, 1))
    );
END
ELSE
BEGIN
    -- Drop old LS FK constraints and columns if upgrading
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MetadataRef_InputLS' AND parent_object_id = OBJECT_ID('EDP_Metadata.MetadataRef'))
        ALTER TABLE EDP_Metadata.MetadataRef DROP CONSTRAINT FK_MetadataRef_InputLS;
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MetadataRef_OutputLS' AND parent_object_id = OBJECT_ID('EDP_Metadata.MetadataRef'))
        ALTER TABLE EDP_Metadata.MetadataRef DROP CONSTRAINT FK_MetadataRef_OutputLS;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'InputLinkedServiceConnectionID')
        ALTER TABLE EDP_Metadata.MetadataRef DROP COLUMN InputLinkedServiceConnectionID;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'OutputLinkedServiceConnectionID')
        ALTER TABLE EDP_Metadata.MetadataRef DROP COLUMN OutputLinkedServiceConnectionID;

    -- Drop old Watermark default+constraint (NOT NULL -> NULL)
    IF EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_MetadataRef_WatermarkID' AND parent_object_id = OBJECT_ID('EDP_Metadata.MetadataRef'))
        ALTER TABLE EDP_Metadata.MetadataRef DROP CONSTRAINT DF_MetadataRef_WatermarkID;
    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'Watermark_ID')
        ALTER TABLE EDP_Metadata.MetadataRef ALTER COLUMN Watermark_ID INT NULL;

    -- Add DatasetRef FK columns
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'InputDataset_ID')
        ALTER TABLE EDP_Metadata.MetadataRef ADD InputDataset_ID INT NULL
            CONSTRAINT FK_MetadataRef_InputDataset FOREIGN KEY REFERENCES EDP_Metadata.DatasetRef(Dataset_ID);
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'OutputDataset_ID')
        ALTER TABLE EDP_Metadata.MetadataRef ADD OutputDataset_ID INT NULL
            CONSTRAINT FK_MetadataRef_OutputDataset FOREIGN KEY REFERENCES EDP_Metadata.DatasetRef(Dataset_ID);

    -- Add audit columns
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'Created_Date')
        ALTER TABLE EDP_Metadata.MetadataRef ADD Created_Date DATETIME NOT NULL CONSTRAINT DF_MetadataRef_CreatedDate DEFAULT (GETDATE());
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'Modified_Date')
        ALTER TABLE EDP_Metadata.MetadataRef ADD Modified_Date DATETIME NOT NULL CONSTRAINT DF_MetadataRef_ModifiedDate DEFAULT (GETDATE());
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('EDP_Metadata.MetadataRef') AND name = 'Modified_By')
        ALTER TABLE EDP_Metadata.MetadataRef ADD Modified_By NVARCHAR(100) NOT NULL CONSTRAINT DF_MetadataRef_ModifiedBy DEFAULT (SYSTEM_USER);
END
