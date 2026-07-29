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
--   InputDataset_ID                : FK to DatasetRef — dataset type (Source + Format)
--   OutputDataset_ID               : FK to DatasetRef — dataset type (Source + Format)
--   InputLinkedServiceConnectionID : FK to LinkedServiceRef — which connection to use
--   OutputLinkedServiceConnectionID: FK to LinkedServiceRef — which connection to use
--   MetadataSettingsInput/Output   : JSON carrying runtime params (path, table, server etc.)
-- ============================================================

/****** Object:  Table [EDP_Metadata].[MetadataRef]    Script Date: 30/06/2026 2:21:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [EDP_Metadata].[MetadataRef](
	[Metadata_ID] [int] IDENTITY(1,1) NOT NULL,
	[Metadata_Job] [nvarchar](200) NOT NULL,
	[Business_Domain_ID] [int] NULL,
	[ADF_Name] [nvarchar](100) NOT NULL,
	[Trigger_Name] [nvarchar](200) NOT NULL,
	[InputDataset_ID] [int] NULL,
	[OutputDataset_ID] [int] NULL,
	[Input_colDelRefID] [int] NULL,
	[Output_colDelRefID] [int] NULL,
	[InputLinkedServiceConnectionID] [int] NULL,
	[OutputLinkedServiceConnectionID] [int] NULL,
	[MetadataSettingsInput] [nvarchar](max) NOT NULL,
	[MetadataSettingsOutput] [nvarchar](max) NOT NULL,
	[ActivityType] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[Load_Type] [bit] NOT NULL,
	[Watermark_ID] [int] NULL,
	[Created_Date] [datetime] NOT NULL,
	[Modified_Date] [datetime] NOT NULL,
	[Modified_By] [nvarchar](100) NOT NULL
	
 CONSTRAINT [PK_MetadataRef] PRIMARY KEY CLUSTERED 
(
	[Metadata_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_MetadataRef_Job] UNIQUE NONCLUSTERED 
(
	[Metadata_Job] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_SettingsInput]  DEFAULT ('{}') FOR [MetadataSettingsInput]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_SettingsOutput]  DEFAULT ('{}') FOR [MetadataSettingsOutput]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_ActivityType]  DEFAULT ((0)) FOR [ActivityType]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_LoadType]  DEFAULT ((0)) FOR [Load_Type]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_CreatedDate]  DEFAULT (getdate()) FOR [Created_Date]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_ModifiedDate]  DEFAULT (getdate()) FOR [Modified_Date]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] ADD  CONSTRAINT [DF_MetadataRef_ModifiedBy]  DEFAULT (suser_sname()) FOR [Modified_By]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_BusinessDomain] FOREIGN KEY([Business_Domain_ID])
REFERENCES [EDP_Metadata].[BusinessDomainRef] ([Business_Domain_ID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_BusinessDomain]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_InputColDelimiter] FOREIGN KEY([Input_colDelRefID])
REFERENCES [EDP_Metadata].[colDelimitterRef] ([colDelRefID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_InputColDelimiter]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_InputDataset] FOREIGN KEY([InputDataset_ID])
REFERENCES [EDP_Metadata].[DatasetRef] ([Dataset_ID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_InputDataset]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_InputLS] FOREIGN KEY([InputLinkedServiceConnectionID])
REFERENCES [EDP_Metadata].[LinkedServiceRef] ([LinkedService_ID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_InputLS]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_OutputColDelimiter] FOREIGN KEY([Output_colDelRefID])
REFERENCES [EDP_Metadata].[colDelimitterRef] ([colDelRefID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_OutputColDelimiter]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_OutputDataset] FOREIGN KEY([OutputDataset_ID])
REFERENCES [EDP_Metadata].[DatasetRef] ([Dataset_ID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_OutputDataset]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_OutputLS] FOREIGN KEY([OutputLinkedServiceConnectionID])
REFERENCES [EDP_Metadata].[LinkedServiceRef] ([LinkedService_ID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_OutputLS]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [FK_MetadataRef_Watermark] FOREIGN KEY([Watermark_ID])
REFERENCES [EDP_Metadata].[Watermark] ([Watermark_ID])
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [FK_MetadataRef_Watermark]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [CK_MetadataRef_ActivityType] CHECK  (([ActivityType]=(1) OR [ActivityType]=(0)))
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [CK_MetadataRef_ActivityType]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [CK_MetadataRef_IsActive] CHECK  (([IsActive]=(1) OR [IsActive]=(0)))
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [CK_MetadataRef_IsActive]
GO

ALTER TABLE [EDP_Metadata].[MetadataRef]  WITH CHECK ADD  CONSTRAINT [CK_MetadataRef_LoadType] CHECK  (([Load_Type]=(1) OR [Load_Type]=(0)))
GO

ALTER TABLE [EDP_Metadata].[MetadataRef] CHECK CONSTRAINT [CK_MetadataRef_LoadType]
GO


