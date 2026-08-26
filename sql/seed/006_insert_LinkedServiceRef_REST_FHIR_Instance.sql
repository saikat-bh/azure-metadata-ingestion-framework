-- ============================================================
-- Seed: EDP_Metadata.LinkedServiceRef — REST API connection instance
-- Purpose: LinkedServiceRef.LinkedServiceName is a catalog of LS
--          *types* (005_insert_LinkedServiceRef.sql) with placeholder
--          connection strings. Real jobs need a concrete instance row
--          with the actual endpoint filled in - multiple rows may
--          share the same LinkedServiceName, distinguished by
--          LinkedServiceConnectionName (duplicates are allowed by
--          design, see 007_create_table_LinkedServiceRef.sql).
--
--          This row points LS_REST_ANON at the public HAPI FHIR R4
--          test server (https://hapi.fhir.org/baseR4) - free, no
--          authentication required - for smoke-testing
--          PL_REST_ADLS_FULL_INGRESS before a real REST source and
--          credentials are available.
-- ============================================================

INSERT INTO EDP_Metadata.LinkedServiceRef
    (LinkedServiceName, LinkedServiceConnectionName, Source_ID, Auth_ID, LinkedServiceConnectionString)
SELECT
    'LS_REST_ANON',
    'HAPI_FHIR_Public_R4',
    s.Source_ID,
    a.Auth_ID,
    '{"URL":"https://hapi.fhir.org/baseR4"}'
FROM EDP_Metadata.SourceRef  s
CROSS JOIN EDP_Metadata.SystemAuth a
WHERE s.Source              = 'REST API'
AND   a.Authentication_Type = 'Anonymous'
AND NOT EXISTS (
    SELECT 1 FROM EDP_Metadata.LinkedServiceRef l
    WHERE  l.LinkedServiceName           = 'LS_REST_ANON'
    AND    l.LinkedServiceConnectionName = 'HAPI_FHIR_Public_R4'
);
