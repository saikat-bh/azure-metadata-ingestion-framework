-- ============================================================
-- Seed: EDP_Metadata.MetadataRef — REST API Full Refresh Ingress example
-- Purpose: Sample ingestion job for PL_REST_ADLS_FULL_INGRESS. Pulls
--          Patient resources from the public HAPI FHIR test server
--          (no auth required) and lands the raw JSON response in the
--          ADLS Gen2 "landing" container. Run the pipeline with
--          TriggerName = 'Sandbox' to exercise it end-to-end.
--
-- Prerequisite: 006_insert_LinkedServiceRef_REST_FHIR_Instance.sql
--               must have been run first.
-- ============================================================

INSERT INTO EDP_Metadata.MetadataRef
(
    Metadata_Job,
    Business_Domain_ID,
    ADF_Name,
    Trigger_Name,
    InputDataset_ID,
    OutputDataset_ID,
    Input_colDelRefID,
    Output_colDelRefID,
    InputLinkedServiceConnectionID,
    OutputLinkedServiceConnectionID,
    MetadataSettingsInput,
    MetadataSettingsOutput,
    ActivityType,
    IsActive,
    Load_Type,
    Watermark_ID
)
SELECT
    'REST-ADLS-FHIR-Patient-poc',
    NULL,
    'adfclaude01',
    'Sandbox',
    (SELECT Dataset_ID FROM EDP_Metadata.DatasetRef WHERE Dataset_Name = 'DS_REST_JSON'),
    (SELECT Dataset_ID FROM EDP_Metadata.DatasetRef WHERE Dataset_Name = 'DS_ADLS_JSON'),
    NULL,
    NULL,
    (SELECT LinkedService_ID FROM EDP_Metadata.LinkedServiceRef
        WHERE LinkedServiceName = 'LS_REST_ANON' AND LinkedServiceConnectionName = 'HAPI_FHIR_Public_R4'),
    (SELECT TOP 1 LinkedService_ID FROM EDP_Metadata.LinkedServiceRef WHERE LinkedServiceName = 'LS_ADLS_SAMI'),
    '{"relativeUrl":"Patient?_count=50&_format=json"}',
    '{"container":"landing","directory":"ingestion/rest_adls/fhir_patient","filename":"fhir_patient_full.json"}',
    0,
    1,
    0,
    NULL
WHERE NOT EXISTS (
    SELECT 1 FROM EDP_Metadata.MetadataRef WHERE Metadata_Job = 'REST-ADLS-FHIR-Patient-poc'
);
