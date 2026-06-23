-- ============================================================
-- Table: EDP_Metadata.MetadataRef
-- Purpose: Core control table for the metadata-driven ingestion
--          framework. Each row represents one ingestion job and
--          carries all parameters required by ADF pipelines at
--          runtime via Lookup activity.
--
-- Column notes:
--   ActivityType : 0 = Ingress  | 1 = Egress
--   IsActive     : 0 = InActive | 1 = Active
--   Load_Type    : 0 = Full Refresh | 1 = Incremental
--   Watermark_ID : defaults to 1 (epoch row in Watermark table)
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
        Metadata_ID                      INT            IDENTITY(1,1)  NOT NULL,
        Metadata_Job                     NVARCHAR(200)  NOT NULL,
        Business_Domain_ID               INT            NULL,
        ADF_Name                         NVARCHAR(100)  NOT NULL,
        Trigger_Name                     NVARCHAR(200)  NOT NULL,
        InputLinkedServiceConnectionID   INT            NULL,
        OutputLinkedServiceConnectionID  INT            NULL,
        MetadataSettingsInput            NVARCHAR(MAX)  NOT NULL  CONSTRAINT DF_MetadataRef_SettingsInput  DEFAULT ('{}'),
        MetadataSettingsOutput           NVARCHAR(MAX)  NOT NULL  CONSTRAINT DF_MetadataRef_SettingsOutput DEFAULT ('{}'),
        ActivityType                     BIT            NOT NULL  CONSTRAINT DF_MetadataRef_ActivityType   DEFAULT (0),
        IsActive                         BIT            NOT NULL  CONSTRAINT DF_MetadataRef_IsActive       DEFAULT (0),
        Load_Type                        BIT            NOT NULL  CONSTRAINT DF_MetadataRef_LoadType       DEFAULT (0),
        Watermark_ID                     INT            NOT NULL  CONSTRAINT DF_MetadataRef_WatermarkID    DEFAULT (1),

        CONSTRAINT PK_MetadataRef
            PRIMARY KEY CLUSTERED (Metadata_ID),

        CONSTRAINT UQ_MetadataRef_Job
            UNIQUE (Metadata_Job),

        CONSTRAINT FK_MetadataRef_BusinessDomain
            FOREIGN KEY (Business_Domain_ID)
            REFERENCES EDP_Metadata.BusinessDomainRef (Business_Domain_ID),

        CONSTRAINT FK_MetadataRef_InputLS
            FOREIGN KEY (InputLinkedServiceConnectionID)
            REFERENCES EDP_Metadata.LinkedServiceRef (LinkedService_ID),

        CONSTRAINT FK_MetadataRef_OutputLS
            FOREIGN KEY (OutputLinkedServiceConnectionID)
            REFERENCES EDP_Metadata.LinkedServiceRef (LinkedService_ID),

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
