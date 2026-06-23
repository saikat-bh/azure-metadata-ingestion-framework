-- ============================================================
-- View: EDP_Metadata.MasterRef
-- Purpose: Single denormalised view over MetadataRef and all
--          its lookup tables. ADF Lookup activity targets this
--          view to retrieve the complete runtime configuration
--          for a given Metadata_Job in one query.
--
-- Decoded columns:
--   ActivityType : 0 -> 'Ingress'       | 1 -> 'Egress'
--   IsActive     : 0 -> 'InActive'      | 1 -> 'Active'
--   Load_Type    : 0 -> 'Full Refresh'  | 1 -> 'Incremental'
-- ============================================================

CREATE OR ALTER VIEW EDP_Metadata.MasterRef
AS
SELECT
    -- ── Job identity ─────────────────────────────────────────
    m.Metadata_ID,
    m.Metadata_Job,

    -- ── Business domain ──────────────────────────────────────
    bd.Business_Domain_Name,

    -- ── ADF / trigger ────────────────────────────────────────
    m.ADF_Name,
    m.Trigger_Name,

    -- ── Input linked service ─────────────────────────────────
    ls_in.LinkedServiceName             AS InputLinkedServiceName,
    ls_in.LinkedServiceConnectionName   AS InputLinkedServiceConnectionName,
    ls_in.LinkedServiceConnectionString AS InputLinkedServiceConnectionString,

    -- ── Output linked service ────────────────────────────────
    ls_out.LinkedServiceName            AS OutputLinkedServiceName,
    ls_out.LinkedServiceConnectionName  AS OutputLinkedServiceConnectionName,
    ls_out.LinkedServiceConnectionString AS OutputLinkedServiceConnectionString,

    -- ── Metadata settings (JSON) ─────────────────────────────
    m.MetadataSettingsInput,
    m.MetadataSettingsOutput,

    -- ── Decoded flags ────────────────────────────────────────
    CASE m.ActivityType
        WHEN 0 THEN 'Ingress'
        WHEN 1 THEN 'Egress'
    END                                 AS ActivityType,

    CASE m.IsActive
        WHEN 0 THEN 'InActive'
        WHEN 1 THEN 'Active'
    END                                 AS IsActive,

    CASE m.Load_Type
        WHEN 0 THEN 'Full Refresh'
        WHEN 1 THEN 'Incremental'
    END                                 AS Load_Type,

    -- ── Watermark ────────────────────────────────────────────
    w.Watermark_Value

FROM       EDP_Metadata.MetadataRef        m
LEFT JOIN  EDP_Metadata.BusinessDomainRef  bd
        ON bd.Business_Domain_ID           = m.Business_Domain_ID
LEFT JOIN  EDP_Metadata.LinkedServiceRef   ls_in
        ON ls_in.LinkedService_ID          = m.InputLinkedServiceConnectionID
LEFT JOIN  EDP_Metadata.LinkedServiceRef   ls_out
        ON ls_out.LinkedService_ID         = m.OutputLinkedServiceConnectionID
LEFT JOIN  EDP_Metadata.Watermark          w
        ON w.Watermark_ID                  = m.Watermark_ID;
