-- ============================================================
-- View: EDP_Metadata.MasterRef
-- Purpose: Single denormalised view over MetadataRef and all
--          its lookup tables. ADF Lookup activity targets this
--          view to retrieve the complete runtime configuration
--          for a given Metadata_Job in one query.
--
-- Architecture:
--   MetadataRef.InputDataset_ID     → DatasetRef (Source + Format type)
--   MetadataRef.InputLinkedServiceConnectionID → LinkedServiceRef (connection)
--   MetadataRef.MetadataSettingsInput → runtime JSON (path, table, server …)
--
-- Decoded columns:
--   ActivityType : 0 -> 'Ingress'      | 1 -> 'Egress'
--   IsActive     : 0 -> 'InActive'     | 1 -> 'Active'
--   Load_Type    : 0 -> 'Full Refresh' | 1 -> 'Incremental'
-- ============================================================

CREATE OR ALTER VIEW EDP_Metadata.MasterRef
AS
SELECT
    -- ── Job identity ─────────────────────────────────────────────
    m.Metadata_ID,
    m.Metadata_Job,

    -- ── Business domain ───────────────────────────────────────────
    bd.Business_Domain_Name,

    -- ── ADF / trigger ─────────────────────────────────────────────
    m.ADF_Name,
    m.Trigger_Name,

    -- ── Input: dataset type ───────────────────────────────────────
    ds_in.Dataset_Name                       AS InputDatasetName,
    src_in.Source                            AS InputSource,
    src_in.Source_Ref                        AS InputSourceRef,
    ff_in.Format                             AS InputFileFormat,

    -- ── Input: linked service (connection) ────────────────────────
    ls_in.LinkedServiceName                  AS InputLinkedServiceName,
    ls_in.LinkedServiceConnectionName        AS InputLinkedServiceConnectionName,
    ls_in.LinkedServiceConnectionString      AS InputLinkedServiceConnectionString,

    -- ── Output: dataset type ──────────────────────────────────────
    ds_out.Dataset_Name                      AS OutputDatasetName,
    src_out.Source                           AS OutputSource,
    src_out.Source_Ref                       AS OutputSourceRef,
    ff_out.Format                            AS OutputFileFormat,

    -- ── Output: linked service (connection) ───────────────────────
    ls_out.LinkedServiceName                 AS OutputLinkedServiceName,
    ls_out.LinkedServiceConnectionName       AS OutputLinkedServiceConnectionName,
    ls_out.LinkedServiceConnectionString     AS OutputLinkedServiceConnectionString,

    -- ── Runtime parameters (JSON) ─────────────────────────────────
    m.MetadataSettingsInput,
    m.MetadataSettingsOutput,

    -- ── Decoded flags ─────────────────────────────────────────────
    CASE m.ActivityType
        WHEN 0 THEN 'Ingress'
        WHEN 1 THEN 'Egress'
    END                                      AS ActivityType,

    CASE m.IsActive
        WHEN 0 THEN 'InActive'
        WHEN 1 THEN 'Active'
    END                                      AS IsActive,

    CASE m.Load_Type
        WHEN 0 THEN 'Full Refresh'
        WHEN 1 THEN 'Incremental'
    END                                      AS Load_Type,

    -- ── Watermark (NULL for Full Refresh jobs) ────────────────────
    w.Watermark_Value,
    w.Watermark_Column,

    -- ── Audit ─────────────────────────────────────────────────────
    m.Created_Date,
    m.Modified_Date,
    m.Modified_By

FROM       EDP_Metadata.MetadataRef        m

LEFT JOIN  EDP_Metadata.BusinessDomainRef  bd
        ON bd.Business_Domain_ID           = m.Business_Domain_ID

-- Input dataset type
LEFT JOIN  EDP_Metadata.DatasetRef         ds_in
        ON ds_in.Dataset_ID                = m.InputDataset_ID
LEFT JOIN  EDP_Metadata.SourceRef          src_in
        ON src_in.Source_ID                = ds_in.Source_ID
LEFT JOIN  EDP_Metadata.FileFormat         ff_in
        ON ff_in.FileFormat_ID             = ds_in.FileFormat_ID

-- Input linked service (from MetadataRef directly)
LEFT JOIN  EDP_Metadata.LinkedServiceRef   ls_in
        ON ls_in.LinkedService_ID          = m.InputLinkedServiceConnectionID

-- Output dataset type
LEFT JOIN  EDP_Metadata.DatasetRef         ds_out
        ON ds_out.Dataset_ID               = m.OutputDataset_ID
LEFT JOIN  EDP_Metadata.SourceRef          src_out
        ON src_out.Source_ID               = ds_out.Source_ID
LEFT JOIN  EDP_Metadata.FileFormat         ff_out
        ON ff_out.FileFormat_ID            = ds_out.FileFormat_ID

-- Output linked service (from MetadataRef directly)
LEFT JOIN  EDP_Metadata.LinkedServiceRef   ls_out
        ON ls_out.LinkedService_ID         = m.OutputLinkedServiceConnectionID

LEFT JOIN  EDP_Metadata.Watermark          w
        ON w.Watermark_ID                  = m.Watermark_ID;
