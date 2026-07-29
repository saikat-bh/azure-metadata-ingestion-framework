Select * from EDP_Metadata.MetadataRef;

INSERT INTO EDP_Metadata.MetadataRef
(Metadata_Job,  -- unique name 
Business_Domain_ID,              -- Lookup EDP_Metadata.BusinessDomainRef;
ADF_Name,
Trigger_Name,                    -- Unique Trigger name
InputDataset_ID,				 -- Lookup EDP_Metadata.DatasetRef;
OutputDataset_ID,				 -- Lookup EDP_Metadata.DatasetRef;
Input_colDelRefID,				 -- Lookup EDP_Metadata.colDelimitterRef;
Output_colDelRefID,				 -- Lookup EDP_Metadata.colDelimitterRef;
InputLinkedServiceConnectionID,  -- EDP_Metadata.LinkedServiceRef;
OutputLinkedServiceConnectionID, -- Lookup EDP_Metadata.LinkedServiceRef;
MetadataSettingsInput,
MetadataSettingsOutput, 
ActivityType,  -- 0 for Igress and 1 for Egress
IsActive,      -- 0 for Inactive and 1 for Active
Load_Type,     -- 0 for Full Refress and 1 for Incremental
Watermark_ID)  -- Lookup EDP_Metadata.Watermark
VALUES(
'ADLS-ADLS-Ingestion-poc',  
1,
'adfaudepoc01',
'Sandbox',
36,
10,
6,
1,
8,
2,
'{"Query":"Select * from SalesLT.Address"}',
'{"container":"landing","directory":"ingestion/asql_adls","filename":"sales_address_full.csv"}',
0,
1,
0,
1)
