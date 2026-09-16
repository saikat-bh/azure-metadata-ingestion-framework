"""
Regenerate hld_metadata_driven_ingestion.docx from scratch.
Run from the docs/ directory or any location — output lands next to this script.
"""
import os
from docx import Document
from docx.shared import Pt, RGBColor, Inches, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_PATH = os.path.join(SCRIPT_DIR, "hld_metadata_driven_ingestion.docx")

# ── Colours ────────────────────────────────────────────────────────────────────
ACCENT   = RGBColor(0x0B, 0x68, 0xB0)
DANGER   = RGBColor(0x99, 0x1B, 0x1B)
WARN     = RGBColor(0x85, 0x4D, 0x0E)
OK       = RGBColor(0x16, 0x65, 0x34)
LABEL    = RGBColor(0x6A, 0x78, 0x8F)
TEXT2    = RGBColor(0x48, 0x56, 0x70)
TABLE_HDR_BG = "1B2238"
TABLE_ROW_ALT = "EBF0F8"
DANGER_CARD_BG = "FEF2F2"
MONO_FONT = "Consolas"


def set_cell_bg(cell, hex_color):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), hex_color)
    tcPr.append(shd)


def set_cell_border(cell, hex_color="991B1B", sz=12):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcBorders = OxmlElement("w:tcBorders")
    for side in ("top", "left", "bottom", "right"):
        border = OxmlElement(f"w:{side}")
        border.set(qn("w:val"), "single")
        border.set(qn("w:sz"), str(sz))
        border.set(qn("w:space"), "0")
        border.set(qn("w:color"), hex_color)
        tcBorders.append(border)
    tcPr.append(tcBorders)


def bold_run(para, text, color=None, size=None, font=None):
    run = para.add_run(text)
    run.bold = True
    if color:
        run.font.color.rgb = color
    if size:
        run.font.size = Pt(size)
    if font:
        run.font.name = font
    return run


def code_run(para, text, color=None):
    run = para.add_run(text)
    run.font.name = MONO_FONT
    run.font.size = Pt(9)
    if color:
        run.font.color.rgb = color
    return run


def add_heading(doc, text, level=1, color=None):
    para = doc.add_heading(text, level=level)
    if color:
        for run in para.runs:
            run.font.color.rgb = color
    return para


def add_para(doc, text="", bold=False, italic=False, size=None, color=None, space_before=0, space_after=6):
    para = doc.add_paragraph()
    para.paragraph_format.space_before = Pt(space_before)
    para.paragraph_format.space_after = Pt(space_after)
    if text:
        run = para.add_run(text)
        run.bold = bold
        run.italic = italic
        if size:
            run.font.size = Pt(size)
        if color:
            run.font.color.rgb = color
    return para


def add_code_block(doc, text):
    para = doc.add_paragraph()
    para.paragraph_format.space_before = Pt(4)
    para.paragraph_format.space_after = Pt(8)
    run = para.add_run(text)
    run.font.name = MONO_FONT
    run.font.size = Pt(8)
    run.font.color.rgb = TEXT2
    # light grey shading
    pPr = para._p.get_or_add_pPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:val"), "clear")
    shd.set(qn("w:color"), "auto")
    shd.set(qn("w:fill"), "EBF0F8")
    pPr.append(shd)
    return para


def add_callout(doc, text, kind="info"):
    bg = {"info": "E3EFF9", "danger": "FEF2F2", "warn": "FFF7E0", "ok": "E6F6EE"}.get(kind, "E3EFF9")
    tc = {"info": ACCENT, "danger": DANGER, "warn": WARN, "ok": OK}.get(kind, ACCENT)
    table = doc.add_table(rows=1, cols=1)
    table.style = "Table Grid"
    cell = table.cell(0, 0)
    set_cell_bg(cell, bg)
    para = cell.paragraphs[0]
    para.paragraph_format.space_before = Pt(4)
    para.paragraph_format.space_after = Pt(4)
    run = para.add_run(text)
    run.font.size = Pt(9.5)
    run.font.color.rgb = tc
    doc.add_paragraph()
    return table


def add_edge_case_card(doc, code, title, badge, body_paragraphs, scope):
    table = doc.add_table(rows=1, cols=1)
    table.style = "Table Grid"
    cell = table.cell(0, 0)
    set_cell_bg(cell, DANGER_CARD_BG)
    set_cell_border(cell, "991B1B", 16)

    # header row: code + title + badge
    hdr = cell.paragraphs[0]
    hdr.paragraph_format.space_before = Pt(4)
    r1 = hdr.add_run(f"[{code}]  ")
    r1.bold = True
    r1.font.name = MONO_FONT
    r1.font.size = Pt(9)
    r1.font.color.rgb = DANGER
    r2 = hdr.add_run(title)
    r2.bold = True
    r2.font.size = Pt(11)
    r3 = hdr.add_run(f"  [{badge}]")
    r3.font.size = Pt(8)
    r3.font.color.rgb = WARN

    for text in body_paragraphs:
        p = cell.add_paragraph()
        p.paragraph_format.space_before = Pt(2)
        p.paragraph_format.space_after = Pt(2)
        p.add_run(text).font.size = Pt(9.5)

    # scope footer
    sep = cell.add_paragraph()
    sep.paragraph_format.space_before = Pt(6)
    sr = sep.add_run(f"Scope: {scope}")
    sr.font.size = Pt(8.5)
    sr.font.color.rgb = LABEL
    sr.italic = True

    doc.add_paragraph()


def add_table(doc, headers, rows, alt_rows=True):
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.LEFT

    # Header row
    hdr_cells = table.rows[0].cells
    for i, h in enumerate(headers):
        set_cell_bg(hdr_cells[i], TABLE_HDR_BG)
        p = hdr_cells[i].paragraphs[0]
        r = p.add_run(h)
        r.bold = True
        r.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
        r.font.size = Pt(9)

    # Data rows
    for ri, row in enumerate(rows):
        row_cells = table.rows[ri + 1].cells
        bg = TABLE_ROW_ALT if (alt_rows and ri % 2 == 1) else "FFFFFF"
        for ci, cell_text in enumerate(row):
            set_cell_bg(row_cells[ci], bg)
            p = row_cells[ci].paragraphs[0]
            if isinstance(cell_text, list):
                # list of (text, bold, mono) tuples
                for chunk, is_bold, is_mono in cell_text:
                    r = p.add_run(chunk)
                    r.bold = is_bold
                    if is_mono:
                        r.font.name = MONO_FONT
                    r.font.size = Pt(9)
            else:
                r = p.add_run(str(cell_text))
                r.font.size = Pt(9)

    doc.add_paragraph()
    return table


# ══════════════════════════════════════════════════════════════════════════════
#  BUILD DOCUMENT
# ══════════════════════════════════════════════════════════════════════════════
doc = Document()

# Page margins
for section in doc.sections:
    section.top_margin    = Cm(2.0)
    section.bottom_margin = Cm(2.0)
    section.left_margin   = Cm(2.5)
    section.right_margin  = Cm(2.5)

# ── Title block ───────────────────────────────────────────────────────────────
title = doc.add_paragraph()
title.alignment = WD_ALIGN_PARAGRAPH.CENTER
tr = title.add_run("Metadata-Driven Ingestion Framework")
tr.bold = True
tr.font.size = Pt(22)
tr.font.color.rgb = ACCENT

sub = doc.add_paragraph()
sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
sr = sub.add_run("High Level Design  |  Version 2.0  |  August 2026  |  Internal")
sr.font.size = Pt(10)
sr.font.color.rgb = LABEL

doc.add_paragraph()

# ── 01 Executive Summary ─────────────────────────────────────────────────────
add_heading(doc, "01 — Executive Summary", level=1, color=ACCENT)
add_para(doc,
    "The Metadata-Driven Ingestion Framework provides a single, reusable, and centrally governed "
    "data integration layer on Azure. Instead of building a dedicated pipeline for each data source, "
    "a suite of generic Azure Data Factory pipelines covers all ingestion scenarios — with runtime "
    "behaviour driven entirely by metadata stored in a central Azure SQL schema (EDP_Metadata).")
add_para(doc,
    "Onboarding a new data source requires no pipeline development or deployment. A metadata record "
    "is inserted into the control table and the existing generic pipeline automatically handles the "
    "ingestion — resolving connections, dataset types, file formats, column delimiters, load strategy, "
    "and target paths at runtime from the metadata.")
add_para(doc,
    "The framework supports both Full Refresh and Incremental (Delta) load patterns, Ingress and Egress "
    "activity directions, and a broad range of source and target connectors. As of v2.0, five pipelines "
    "are fully deployed and operational, covering Azure SQL, ADLS Gen2, and REST API sources — with support "
    "for standard formats (CSV, Parquet, JSON), compressed sources (GZIP, ZIP, TarGzip), binary file "
    "pass-through, and raw JSON landing from REST endpoints.")
add_para(doc,
    "Configuration-level parameters shared across all pipelines — such as the metadata server and database "
    "coordinates — are managed as ADF Global Parameters, removing them entirely from individual pipeline "
    "definitions and providing a single configuration point at the factory level.")

# ── 02 Problem Statement ─────────────────────────────────────────────────────
add_heading(doc, "02 — Problem Statement", level=1, color=ACCENT)
add_para(doc,
    "Without a metadata-driven approach, data engineering teams typically encounter the following "
    "challenges as the number of ingestion requirements grows:")
for item in [
    "Pipeline proliferation — A dedicated pipeline per source/target combination results in hundreds of near-identical, independently maintained artifacts with no shared behaviour.",
    "Hardcoded configuration — Connection strings, file paths, table names, and schema references are embedded in pipeline definitions, requiring a full redeployment cycle for any configuration change.",
    "No central control — Activating or deactivating a specific ingestion job requires modifying triggers or pipeline definitions rather than updating a flag in a control table.",
    "Slow source onboarding — Each new data source demands a full pipeline build, review, test, and deployment cycle — typically days to weeks per source at scale.",
    "Inconsistency — Without enforced naming and structural conventions, pipeline implementations diverge across teams and projects.",
    "Ad hoc watermark management — Incremental load tracking is typically implemented per-pipeline, with no centralised state or visibility.",
    "Poor auditability — There is no structured record of who configured a given ingestion job, when, or what was changed.",
]:
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    p.add_run(item).font.size = Pt(10)

doc.add_paragraph()

# ── 03 Solution Architecture ─────────────────────────────────────────────────
add_heading(doc, "03 — Solution Architecture", level=1, color=ACCENT)
add_para(doc,
    "The framework is structured across three distinct layers. The metadata control plane drives all "
    "behaviour; ADF executes it; source and target systems are treated as interchangeable connectors.")

add_heading(doc, "Runtime Execution Steps", level=2)
steps = [
    "Trigger fires — passes TriggerName pipeline parameter.",
    "Lookup activity queries EDP_Metadata.MasterRef (firstRowOnly: false) — resolves full config for all active jobs in one call. Server/database coordinates from ADF Global Parameters.",
    "ForEach iterates over all returned rows in parallel (batchCount: 5).",
    "Switch evaluates SwitchCaseRef to route to the correct Copy activity.",
    "Copy executes with fully dynamic expressions — no hardcoded paths, queries, or connection details.",
    "Incremental only: validate watermark → filter source → copy → check rows > 0 → update watermark.",
]
for i, step in enumerate(steps, 1):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(3)
    bold_run(p, f"{i}.  ", color=ACCENT)
    p.add_run(step).font.size = Pt(10)

doc.add_paragraph()

# ── 04 Metadata Schema ───────────────────────────────────────────────────────
add_heading(doc, "04 — Metadata Schema", level=1, color=ACCENT)
add_para(doc,
    "All framework configuration lives in the EDP_Metadata schema. It consists of a core control "
    "table (MetadataRef), a set of normalised lookup tables, and a denormalized runtime view (MasterRef) "
    "that ADF queries at pipeline execution time.")

add_heading(doc, "Core Control Table — MetadataRef", level=2)
add_table(doc,
    ["Column", "Type", "Purpose"],
    [
        ["Metadata_ID",               "INT IDENTITY",          "Primary key"],
        ["Metadata_Job",              "NVARCHAR(200) UNIQUE",  "Unique job name — passed as trigger parameter"],
        ["Business_Domain_ID",        "INT (FK)",              "Classifies job by business function (BusinessDomainRef)"],
        ["ADF_Name",                  "NVARCHAR(100)",         "Name of the ADF instance"],
        ["Trigger_Name",              "NVARCHAR(200)",         "ADF trigger name for this job"],
        ["InputDataset_ID",           "INT (FK)",              "Source dataset type (DatasetRef)"],
        ["OutputDataset_ID",          "INT (FK)",              "Target dataset type (DatasetRef)"],
        ["Input_colDelRefID",         "INT (FK)",              "Source column delimiter (colDelimitterRef)"],
        ["Output_colDelRefID",        "INT (FK)",              "Target column delimiter (colDelimitterRef)"],
        ["InputLinkedServiceConnectionID", "INT (FK)",         "Source connection (LinkedServiceRef)"],
        ["OutputLinkedServiceConnectionID","INT (FK)",         "Target connection (LinkedServiceRef)"],
        ["MetadataSettingsInput",     "NVARCHAR(MAX) JSON",    "Runtime source params (container, path, query, schema, table)"],
        ["MetadataSettingsOutput",    "NVARCHAR(MAX) JSON",    "Runtime target params (container, directory, filename)"],
        ["ActivityType",              "NVARCHAR(20)",          "Ingress | Egress"],
        ["IsActive",                  "NVARCHAR(10)",          "Active | Inactive — master on/off switch"],
        ["Load_Type",                 "NVARCHAR(20)",          "Full_Refresh | Incremental"],
        ["Watermark_ID",              "INT (FK, nullable)",    "NULL for Full Refresh; references Watermark table"],
        ["Created_Date",              "DATETIME",              "Auto-set on insert"],
        ["Modified_Date",             "DATETIME",              "Last modification timestamp"],
        ["Modified_By",               "NVARCHAR(100)",         "Database user — auto-set via SUSER_SNAME()"],
    ]
)

add_heading(doc, "Runtime View — MasterRef", level=2)
add_para(doc,
    "EDP_Metadata.MasterRef is a denormalized view that joins MetadataRef with all lookup tables. "
    "ADF's Lookup activity targets this view to retrieve the complete runtime configuration for a "
    "given Trigger_Name in a single query. Two computed columns are derived:")
for bullet in [
    "Pipeline_Name — derived from source/target/load type/direction. Format: PL_{InputSource}_{OutputSource}_{FULL|INCREMENTAL}_{INGRESS|EGRESS}",
    "SwitchCaseRef — derived from linked service names and file formats. Used by the ADF Switch to select the correct Copy activity.",
]:
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    p.add_run(bullet).font.size = Pt(10)

doc.add_paragraph()

add_heading(doc, "Lookup Tables", level=2)
add_table(doc,
    ["Table", "Purpose", "Key Columns"],
    [
        ["SourceRef",         "Registry of all supported data source types. Source_Ref is the short code used in naming.", "Source, Source_Ref"],
        ["FileFormat",        "Lookup of all supported file formats (CSV, Parquet, JSON, GZIP_CSV, ZIP_CSV, BINARY, etc.).", "Format"],
        ["DatasetRef",        "Unique Source + FileFormat combinations. Named DS_{Source_Ref}_{Format}.", "Dataset_Name, Source_ID, FileFormat_ID"],
        ["LinkedServiceRef",  "Catalogue of all ADF linked services. JSON connection string templates resolved at runtime. Named LS_{Source_Ref}_{Auth_Ref}.", "LinkedServiceName, LinkedServiceConnectionString"],
        ["SystemAuth",        "Registry of supported authentication types. Connectors column records applicable source types.", "Authentication_Type, Auth_Ref, Connectors"],
        ["BusinessDomainRef", "Business domain classification. Every ingestion job is classified by its owning business function.", "Business_Domain_Name"],
        ["colDelimitterRef",  "Column delimiter reference. Seeded: Comma, Semicolon, Pipe, Tab, SOH, No Delimiter.", "colDelRefName, colDelRefValue"],
        ["Watermark",         "High-water mark per incremental job. Watermark_Value (DATETIME) updated after each successful run.", "Watermark_Value, Watermark_Column"],
    ]
)

# ── 06 Pipeline Catalog ──────────────────────────────────────────────────────
add_heading(doc, "06 — Pipeline Catalog", level=1, color=ACCENT)
add_para(doc,
    "Five generic pipelines are deployed in adfclaude01, all grouped under the Ingress folder in ADF Studio. "
    "Each pipeline is driven entirely by metadata. The only pipeline-level parameter across all five is "
    "TriggerName, which scopes the Lookup to the correct set of jobs.")

add_table(doc,
    ["Pipeline", "Source", "Target", "Load Type", "Switches / Cases", "ForEach Activities"],
    [
        ["PL_ASQL_ADLS_FULL_INGRESS",         "Azure SQL",  "ADLS Gen2", "Full Refresh",  "1 Switch, 3 cases",        "1 Copy per case"],
        ["PL_ASQL_ADLS_INCREMENTAL_INGRESS",  "Azure SQL",  "ADLS Gen2", "Incremental",   "1 Switch, 3 cases",        "Validate_Watermark (sibling) + Copy + Update_Watermark"],
        ["PL_ADLS_ADLS_FULL_INGRESS",         "ADLS Gen2",  "ADLS Gen2", "Full Refresh",  "2 Switches, 28 cases",     "1 Copy per case"],
        ["PL_ADLS_ADLS_INCREMENTAL_INGRESS",  "ADLS Gen2",  "ADLS Gen2", "Incremental",   "2 Switches, 28 cases",     "Validate_Watermark (sibling) + Copy + Update_Watermark"],
        ["PL_REST_ADLS_FULL_INGRESS",         "REST API",   "ADLS Gen2", "Full Refresh",  "1 Switch, 1 case",         "1 Copy per case (raw JSON landing, no transformation)"],
    ]
)

add_heading(doc, "ADLS Pipeline Switch Cases (28 total, split across 2 Switch activities)", level=2)
add_para(doc,
    "ADF enforces a hard limit of 25 cases per Switch activity. The ADLS pipelines use two sibling "
    "Switch activities inside ForEach: Switch_OutputFormat (10 uncompressed cases) and "
    "Switch_OutputFormat_Compressed (18 compressed/binary cases). Each Switch has an empty default "
    "so a SwitchCaseRef destined for the other Switch is a silent no-op.")

add_table(doc,
    ["Source Format", "Target Formats", "Cases", "Source Dataset"],
    [
        ["CSV (uncompressed)",       "CSV, Parquet, JSON",  "3",  "DS_ADLS_CSV"],
        ["Parquet (uncompressed)",   "CSV, Parquet, JSON",  "3",  "DS_ADLS_PARQUET"],
        ["JSON (uncompressed)",      "CSV, Parquet, JSON",  "3",  "DS_ADLS_JSON"],
        ["GZIP-compressed CSV",      "CSV, Parquet, JSON",  "3",  "DS_ADLS_GZIP_CSV"],
        ["ZIP-compressed CSV",       "CSV, Parquet, JSON",  "3",  "DS_ADLS_ZIP_CSV"],
        ["TarGzip CSV",              "CSV, Parquet, JSON",  "3",  "DS_ADLS_TARGZIP_CSV"],
        ["GZIP-compressed JSON",     "CSV, Parquet, JSON",  "3",  "DS_ADLS_GZIP_JSON"],
        ["ZIP-compressed JSON",      "CSV, Parquet, JSON",  "3",  "DS_ADLS_ZIP_JSON"],
        ["TarGzip JSON",             "CSV, Parquet, JSON",  "3",  "DS_ADLS_TARGZIP_JSON"],
        ["Binary (any)",             "Binary",              "1",  "DS_ADLS_BINARY"],
    ]
)

add_callout(doc,
    "Compressed source design (Scenario A): Each compression type gets its own dedicated dataset "
    "with the compression codec baked in (e.g. compressionCodec: \"gzip\"). ADF decompresses "
    "transparently at read time, giving each format/compression variant a clean, unique identity "
    "in the SwitchCaseRef routing table.",
    kind="info"
)

# ── 07 Datasets & Global Parameters ─────────────────────────────────────────
add_heading(doc, "07 — Datasets & Global Parameters", level=1, color=ACCENT)

add_heading(doc, "Deployed ADF Datasets (12 total)", level=2)
add_para(doc,
    "All datasets use parameterized linked services — connection details are resolved from "
    "LinkedServiceConnectionString JSON in the metadata at runtime. No connection detail is "
    "hardcoded in any dataset definition.")

add_table(doc,
    ["Dataset", "ADF Type", "Format", "Compression", "Linked Service"],
    [
        ["DS_ASQL_TABLE",       "AzureSqlTable",  "TABLE",           "—",              "LS_ASQL_SAMI"],
        ["DS_ADLS_CSV",         "DelimitedText",  "CSV",             "None",           "LS_ADLS_SAMI"],
        ["DS_ADLS_PARQUET",     "Parquet",        "Parquet",         "None",           "LS_ADLS_SAMI"],
        ["DS_ADLS_JSON",        "Json",           "JSON",            "None",           "LS_ADLS_SAMI"],
        ["DS_ADLS_GZIP_CSV",    "DelimitedText",  "CSV",             "gzip",           "LS_ADLS_SAMI"],
        ["DS_ADLS_ZIP_CSV",     "DelimitedText",  "CSV",             "ZipDeflate",     "LS_ADLS_SAMI"],
        ["DS_ADLS_TARGZIP_CSV", "DelimitedText",  "CSV",             "TarGzip",        "LS_ADLS_SAMI"],
        ["DS_ADLS_GZIP_JSON",   "Json",           "JSON",            "gzip",           "LS_ADLS_SAMI"],
        ["DS_ADLS_ZIP_JSON",    "Json",           "JSON",            "ZipDeflate",     "LS_ADLS_SAMI"],
        ["DS_ADLS_TARGZIP_JSON","Json",           "JSON",            "TarGzip",        "LS_ADLS_SAMI"],
        ["DS_ADLS_BINARY",      "Binary",         "Any binary",      "None (pass-through)", "LS_ADLS_SAMI"],
        ["DS_REST_JSON",        "RestResource",   "JSON (REST resp.)", "—",            "LS_REST_ANON"],
    ]
)

add_heading(doc, "Deployed Linked Services (5 total)", level=2)
add_para(doc,
    "All linked services are fully parameterized — connection details are resolved at runtime from "
    "LinkedServiceRef.LinkedServiceConnectionString JSON. No server name, URL, credential, or key "
    "is hardcoded in any linked service definition.")

add_table(doc,
    ["Linked Service", "ADF Connector", "Auth Type", "Parameters"],
    [
        ["LS_ADLS_SAMI",  "AzureBlobFS",            "System-Assigned Managed Identity", "URL"],
        ["LS_ASQL_SAMI",  "AzureSqlDatabase v2.0",  "System-Assigned Managed Identity", "serverName, databaseName"],
        ["LS_SFTP_BASIC", "Sftp",                   "Basic (username/password)",         "host, port, userName, password (SecureString)"],
        ["LS_SFTP_SSH",   "Sftp",                   "SSH Public Key",                    "host, port, userName, privateKeyContent, passPhrase (SecureString)"],
        ["LS_REST_ANON",  "RestService",             "Anonymous",                         "URL"],
    ]
)

add_heading(doc, "ADF Global Parameters", level=2)
add_para(doc,
    "Factory-level parameters shared across all pipelines are managed as ADF Global Parameters "
    "rather than duplicated pipeline-level parameters. This ensures a single configuration point: "
    "updating the metadata server or database name requires one change at the factory level.")

add_table(doc,
    ["Global Parameter", "Type", "Value", "Referenced As"],
    [
        ["MetadataServerName",  "String", "asqlserverclaude01.database.windows.net",  "@pipeline().globalParameters.MetadataServerName"],
        ["MetadataDatabaseName","String", "asqlclaude01",                             "@pipeline().globalParameters.MetadataDatabaseName"],
    ]
)

add_callout(doc,
    "All five deployed pipelines reference these global parameters for Lookup dataset resolution. "
    "The only pipeline-level parameter across all five is TriggerName.",
    kind="info"
)

# ── 08 Load Patterns ─────────────────────────────────────────────────────────
add_heading(doc, "08 — Load Patterns", level=1, color=ACCENT)

add_heading(doc, "Full Refresh  [Load_Type = Full_Refresh]", level=2)
add_para(doc,
    "The entire dataset is read from source and written to the target on each run. Used for reference "
    "data, small dimension tables, or sources where change tracking is not available or required.")
for bullet in [
    "Watermark_ID is NULL — no high-water mark is maintained.",
    "No source-side filter is applied; all records are copied on every run.",
    "Each Switch case contains a single Copy activity.",
    "Pipeline name carries the FULL suffix.",
]:
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    p.add_run(bullet).font.size = Pt(10)
doc.add_paragraph()

add_heading(doc, "Incremental / Delta  [Load_Type = Incremental]", level=2)
add_para(doc,
    "Only records added or changed since the last successful run are copied. The high-water mark "
    "is maintained in the Watermark table and updated after each successful load that transfers "
    "at least one record.")
for bullet in [
    "Watermark_ID references a row in the Watermark table.",
    "For SQL sources: Watermark_Column identifies the datetime column. Source query wraps user-supplied query with WHERE {Watermark_Column} > '{Watermark_Value}'.",
    "For file-based sources (ADLS): modifiedDatetimeStart in AzureBlobFSReadSettings filters files by last-modified timestamp. Watermark_Column is a documentation label only.",
    "After a successful copy that transfers data, a Script activity updates Watermark_Value to UTC now.",
    "Pipeline name carries the INCREMENTAL suffix.",
]:
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    p.add_run(bullet).font.size = Pt(10)
doc.add_paragraph()

# ── 09 Incremental Pipeline Resilience ───────────────────────────────────────
add_heading(doc, "09 — Incremental Pipeline Resilience", level=1, color=DANGER)
add_para(doc,
    "The incremental pipelines implement multiple defensive patterns to handle edge cases that "
    "would otherwise result in silent data loss, incorrect watermark advancement, or hard-to-diagnose "
    "failures. Each guard is implemented as a discrete ADF activity with explicit dependency conditions.",
    color=RGBColor(0x1B, 0x22, 0x38))

add_callout(doc,
    "Why these guards matter: Without them, a pipeline could advance the watermark on a failed copy "
    "(losing the retry window), silently advance on an empty result (masking a missing data issue), "
    "or run indefinitely with a null watermark (copying all records on every run with no filtering). "
    "Each scenario below has been considered and explicitly handled.",
    kind="danger"
)

add_edge_case_card(doc,
    "WM001", "Null Watermark Validation", "Guard",
    [
        "Risk: If Watermark_Column or Watermark_Value is null in the metadata, the incremental "
        "source filter cannot be constructed. The copy would proceed unfiltered, loading the entire "
        "source on every run — silently corrupting the incremental state.",

        "Implementation: An IfCondition activity (Validate_Watermark) is placed as a sibling of the "
        "Switch activity inside ForEach. The Switch depends on Validate_Watermark succeeding. If either "
        "watermark field is null, a Fail_Invalid_Watermark activity fires with error code WM001, "
        "halting that ForEach iteration before the Switch — and therefore the Copy — ever runs.",

        "Expression:  @or(equals(item().Watermark_Column, null), equals(item().Watermark_Value, null))",
        "Switch dependency:  \"dependsOn\": [{\"activity\": \"Validate_Watermark\", \"dependencyConditions\": [\"Succeeded\"]}]",

        "Why a sibling, not nested: ADF does not permit control flow activities (IfCondition, Switch, "
        "ForEach, Until) to be nested inside a Switch case. Promoting Validate_Watermark to ForEach "
        "level achieves the same guard without violating this constraint.",
    ],
    "All incremental cases in both PL_ASQL_ADLS_INCREMENTAL_INGRESS and PL_ADLS_ADLS_INCREMENTAL_INGRESS "
    "— the guard fires once per ForEach iteration, before either Switch executes"
)

add_edge_case_card(doc,
    "ZR001", "Zero-Rows / Zero-Files Guard", "Guard",
    [
        "Risk: If the watermark-filtered source query returns zero rows (no new records), advancing the "
        "watermark would shift the boundary forward — causing the next run to miss records that arrive "
        "late within the original window.",

        "Implementation: Rather than a separate IfCondition activity, the zero-rows check is folded "
        "directly into the Update_Watermark Script text as an @if() expression. If rowsCopied > 0 "
        "(or filesRead > 0 for binary), the UPDATE runs; otherwise the script executes a no-op "
        "SELECT 1 and the watermark stays unchanged.",

        "Standard cases:  @if(greater(activity('Copy_...').output.rowsCopied, 0), concat('UPDATE w SET ...'), 'SELECT 1')",
        "Binary case:  @if(greater(activity('Copy_ADLS_BINARY_to_ADLS_BINARY').output.filesRead, 0), concat('UPDATE w SET ...'), 'SELECT 1')",

        "This approach eliminates a dedicated IfCondition activity, keeping each Switch case to two "
        "activities (Copy + Update_Watermark) while preserving the zero-rows safety guarantee.",
    ],
    "All incremental cases in both pipelines  |  Binary case checks filesRead; all other cases check rowsCopied"
)

add_edge_case_card(doc,
    "CF001", "Copy Failure Guard", "Guard",
    [
        "Risk: If the Copy activity fails mid-run (network error, schema mismatch, throttling), a "
        "watermark update that runs regardless would lock the pipeline into a future time window — "
        "permanently skipping all records from the failed run's interval.",

        "Implementation: The Update_Watermark Script activity has a direct Succeeded dependency on the "
        "Copy activity. If the Copy fails, Update_Watermark is skipped entirely. The watermark remains "
        "at the last known good boundary, ensuring the next retry re-processes the same time window.",

        "Dependency:  \"dependsOn\": [{\"activity\": \"Copy_...\", \"dependencyConditions\": [\"Succeeded\"]}]",
    ],
    "All incremental cases in both PL_ASQL_ADLS_INCREMENTAL_INGRESS and PL_ADLS_ADLS_INCREMENTAL_INGRESS"
)

add_edge_case_card(doc,
    "FW001", "ADLS File-Modification Watermark", "Design",
    [
        "Challenge: File-based sources on ADLS Gen2 have no SQL column that can be used to filter "
        "rows by a watermark value. The standard SQL approach (WHERE column > value) cannot be "
        "applied to files.",

        "Implementation: ADF's native modifiedDatetimeStart setting in AzureBlobFSReadSettings is "
        "used to filter files by their last-modified timestamp:",

        "\"modifiedDatetimeStart\": { \"value\": \"@formatDateTime(item().Watermark_Value, 'yyyy-MM-ddTHH:mm:ss')\", \"type\": \"Expression\" }",

        "Watermark_Column in the metadata row for file-based sources acts as a human-readable "
        "documentation label (e.g. FileModifiedDate) and is NOT used in the ADF filter expression. "
        "Only Watermark_Value is consumed at runtime.",
    ],
    "All 28 cases in PL_ADLS_ADLS_INCREMENTAL_INGRESS  |  Not applicable to ASQL incremental (SQL column filter used instead)"
)

add_edge_case_card(doc,
    "BN001", "Binary File Metric Substitution", "Design",
    [
        "Challenge: ADF's Binary Copy activities do not report rowsCopied — binary transfers report "
        "filesRead and filesWritten instead. Using rowsCopied for the zero-rows guard would always "
        "evaluate to zero, causing the watermark to never advance for binary jobs.",

        "Implementation: The binary incremental case uses filesRead in the guard condition:",
        "@greater(activity('Copy_ADLS_BINARY_to_ADLS_BINARY').output.filesRead, 0)",

        "The Update_Watermark Script activity is otherwise identical to all other incremental cases "
        "— only the guard metric differs.",
    ],
    "Binary-to-binary switch case only (SW_ADLS_SAMI_BINARY_ADLS_SAMI_BINARY) in PL_ADLS_ADLS_INCREMENTAL_INGRESS"
)

add_edge_case_card(doc,
    "NC001", "No Nested Control Activities", "Constraint",
    [
        "Constraint: ADF does not allow control flow activities (IfCondition, Switch, ForEach, Until) "
        "to be nested inside another control flow activity of those same types. An IfCondition inside "
        "a Switch case, or a Switch inside an IfCondition, is a validation error.",

        "Impact on this framework: The original design placed Validate_Watermark inside each Switch "
        "case and Check_Rows_Copied inside the Copy success branch — both nested control activities. "
        "ADF rejected both pipelines on validation.",

        "Resolution:",
        "  - Validate_Watermark was promoted to a ForEach-level sibling of the Switch, with the Switch "
        "    carrying a Succeeded dependency on it (see WM001).",
        "  - Check_Rows_Copied was eliminated entirely and its logic folded into the Update_Watermark "
        "    Script as an @if() expression (see ZR001).",
    ],
    "Applies to all ADF pipelines — any design that requires conditional logic inside a Switch case "
    "must use expression-level branching (@if()) rather than a separate IfCondition activity"
)

add_edge_case_card(doc,
    "SW025", "Switch 25-Case Limit", "Constraint",
    [
        "Constraint: ADF enforces a hard limit of 25 cases per Switch activity. The ADLS pipelines "
        "originally had 28 cases in a single Switch, which exceeded this limit.",

        "Resolution: Each ADLS pipeline uses two sibling Switch activities inside ForEach:",
        "  - Switch_OutputFormat — 10 uncompressed cases (CSV/Parquet/JSON sources x CSV/Parquet/JSON targets + Binary)",
        "  - Switch_OutputFormat_Compressed — 18 compressed cases (GZIP/ZIP/TarGzip x CSV/JSON sources x CSV/Parquet/JSON targets)",

        "Each Switch has an empty defaultActivities block. A SwitchCaseRef that does not match in one "
        "Switch silently no-ops there and is handled by the other Switch.",

        "Activity count (ADLS incremental): Lookup + ForEach + Validate_Watermark + Switch (20) + Switch_Compressed (36) = 62  (well within 120-activity limit)",
    ],
    "PL_ADLS_ADLS_FULL_INGRESS and PL_ADLS_ADLS_INCREMENTAL_INGRESS  |  "
    "Any future pipeline with more than 25 source/format combinations must use the same split-Switch pattern"
)

add_heading(doc, "Watermark Update — Script Activity", level=2)
add_para(doc,
    "Each incremental Switch case contains a single Update_Watermark Script activity that depends on "
    "the Copy activity succeeding (CF001). The script text is an @if() expression that checks "
    "rowsCopied (or filesRead for binary) and either executes the UPDATE or falls back to a no-op "
    "SELECT 1 (ZR001). Full expression for a standard case:")

add_code_block(doc,
"""@if(
  greater(activity('Copy_...').output.rowsCopied, 0),
  concat(
    'UPDATE w SET w.Watermark_Value = CONVERT(DATETIME, ''',
    formatDateTime(utcNow(), 'yyyy-MM-dd HH:mm:ss'),
    ''') FROM EDP_Metadata.Watermark w ',
    'JOIN EDP_Metadata.MetadataRef m ON m.Watermark_ID = w.Watermark_ID ',
    'WHERE m.Metadata_ID = ', string(item().Metadata_ID)
  ),
  'SELECT 1'
)""")

add_para(doc,
    "The script uses commandType: NonQuery, connected to LS_ASQL_SAMI with serverName and databaseName "
    "resolved from ADF Global Parameters. No watermark coordinates are hardcoded in the pipeline definition.")

# ── 10 Naming Conventions ────────────────────────────────────────────────────
add_heading(doc, "10 — Naming Conventions", level=1, color=ACCENT)
add_para(doc,
    "All ADF artifact names are derived from metadata, not manually assigned. The MasterRef view "
    "computes pipeline names and switch case references at runtime from the source, target, load type, "
    "and connector combination registered in the reference tables.")

add_heading(doc, "Pipeline Name", level=2)
add_code_block(doc,
"""PL_{InputSource}_{OutputSource}_{FULL|INCREMENTAL}_{INGRESS|EGRESS}

Examples:
  PL_ASQL_ADLS_FULL_INGRESS          Full refresh, Azure SQL source to ADLS Gen2 target
  PL_ASQL_ADLS_INCREMENTAL_INGRESS   Incremental, Azure SQL source to ADLS Gen2 target
  PL_ADLS_ADLS_FULL_INGRESS          Full refresh, ADLS Gen2 source to ADLS Gen2 target
  PL_ADLS_ADLS_INCREMENTAL_INGRESS   Incremental, ADLS Gen2 source to ADLS Gen2 target
  PL_REST_ADLS_FULL_INGRESS          Full refresh, REST API source to ADLS Gen2 target""")

add_heading(doc, "Dataset Name", level=2)
add_code_block(doc,
"""DS_{Source_Ref}_{Format}

Examples:
  DS_ADLS_PARQUET        ADLS Gen2 with Parquet format (uncompressed)
  DS_ADLS_CSV            ADLS Gen2 with CSV format (uncompressed)
  DS_ADLS_GZIP_CSV       ADLS Gen2 with CSV format, GZIP compressed
  DS_ADLS_ZIP_CSV        ADLS Gen2 with CSV format, ZIP (ZipDeflate) compressed
  DS_ADLS_TARGZIP_CSV    ADLS Gen2 with CSV format, TarGzip compressed
  DS_ADLS_GZIP_JSON      ADLS Gen2 with JSON format, GZIP compressed
  DS_ADLS_BINARY         ADLS Gen2, binary pass-through (no format parsing)
  DS_ASQL_TABLE          Azure SQL -- table-based, no file format
  DS_REST_JSON           REST API -- JSON response landing""")

add_heading(doc, "Linked Service Name", level=2)
add_code_block(doc,
"""LS_{Source_Ref}_{Auth_Ref}

Examples:
  LS_ADLS_SAMI       ADLS Gen2 with System-Assigned Managed Identity
  LS_ASQL_SAMI       Azure SQL with System-Assigned Managed Identity (v2.0)
  LS_SFTP_BASIC      SFTP with Basic (username/password) authentication
  LS_SFTP_SSH        SFTP with SSH public key authentication
  LS_REST_ANON       REST API with Anonymous authentication""")

add_heading(doc, "Switch Case Reference", level=2)
add_code_block(doc,
"""SW_{InputLinkedService}_{InputFormat}_{OutputLinkedService}_{OutputFormat}

Where LinkedService = linked service name with leading "LS_" removed.

Examples:
  SW_ASQL_SAMI_TABLE_ADLS_SAMI_CSV         Azure SQL to ADLS CSV
  SW_ADLS_SAMI_GZIP_CSV_ADLS_SAMI_PARQUET  ADLS GZIP-CSV source to ADLS Parquet
  SW_ADLS_SAMI_BINARY_ADLS_SAMI_BINARY     ADLS binary pass-through
  SW_REST_ANON_JSON_ADLS_SAMI_JSON         REST API JSON to ADLS JSON

Computed by MasterRef at runtime to uniquely identify each source/target/format combination.""")

# ── 11 Design Principles ─────────────────────────────────────────────────────
add_heading(doc, "11 — Design Principles", level=1, color=ACCENT)

principles = [
    ("Metadata-Driven Architecture",
     "Pipeline behaviour is fully parameterized. No source path, connection detail, file format, or load type "
     "is hardcoded in any ADF pipeline definition. All execution decisions are resolved at runtime from the metadata control plane."),
    ("Separation of Configuration from Execution",
     "The metadata layer owns what to do; ADF owns how to do it. Operational and configuration changes require no "
     "pipeline modification or redeployment — they are made purely in the metadata."),
    ("Single Source of Truth",
     "All ingestion configuration lives in EDP_Metadata.MetadataRef. No configuration is duplicated across pipelines, "
     "environments, or teams. The MasterRef view exposes a complete denormalized runtime view over this single source."),
    ("Centralised Operational Control",
     "The IsActive flag provides a master on/off switch for any ingestion job without touching ADF triggers or pipeline "
     "definitions. Operational state is managed in data, not in infrastructure."),
    ("Convention over Configuration",
     "Strict, computed naming conventions for pipelines, datasets, linked services, and switch cases are enforced "
     "by the metadata schema. Consistent naming reduces cognitive load and enables automated operational tooling."),
    ("Auditability by Design",
     "Every row in MetadataRef carries Created_Date, Modified_Date, and Modified_By — populated automatically by "
     "database defaults. Configuration change history is inherent to the data model, not an afterthought."),
    ("Defensive Incremental Loading",
     "Incremental pipelines implement multiple explicit guards: null watermark validation, zero-rows checks before "
     "advancing the boundary, and Copy Succeeded dependency conditions on watermark updates. Watermarks are never "
     "advanced on failure or empty results."),
    ("Extensibility",
     "Adding a new data source, file format, or authentication type requires only inserting reference rows into "
     "the appropriate lookup tables. The generic pipeline accommodates new source/target combinations without any "
     "pipeline modification."),
    ("Idempotent Infrastructure",
     "All DDL scripts use IF NOT EXISTS guards and include schema upgrade paths. The schema can be safely "
     "re-applied across environments without destructive side effects."),
]

for title_text, desc in principles:
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after = Pt(4)
    bold_run(p, title_text + ": ", color=ACCENT)
    p.add_run(desc).font.size = Pt(10)

doc.add_paragraph()

# ── 12 Data Fabric Alignment ─────────────────────────────────────────────────
add_heading(doc, "12 — Data Fabric Alignment", level=1, color=ACCENT)
add_para(doc,
    "The framework aligns with several foundational principles of modern Data Fabric architecture, "
    "specifically those concerned with active metadata management, unified cataloguing, and governed connectivity.")

add_table(doc,
    ["Data Fabric Principle", "How the Framework Addresses It"],
    [
        ["Active Metadata Management",
         "MetadataRef is a live operational control plane — not passive documentation. It actively governs "
         "pipeline behaviour at execution time, making metadata the direct engine of data movement."],
        ["Unified Data Catalogue",
         "All sources, target types, file formats, authentication methods, and connection configurations are "
         "centrally registered in the EDP_Metadata schema. No shadow configurations exist outside this registry."],
        ["Business Domain Orientation",
         "BusinessDomainRef classifies every ingestion job by business function. Every data movement activity "
         "is traceable to its owning domain — supporting data product thinking and domain-driven governance."],
        ["Governed Connectivity",
         "SystemAuth and LinkedServiceRef enforce a structured, centralised approach to connection management. "
         "All authentication types and connection templates are catalogued and reused — no unregistered connections."],
        ["Reusable Data Services",
         "The generic pipeline layer acts as a reusable data service. The same pipeline infrastructure serves all "
         "projects, domains, and customers without modification; variation is expressed purely in metadata records."],
    ]
)

# ── 13 Benefits ──────────────────────────────────────────────────────────────
add_heading(doc, "13 — Benefits", level=1, color=ACCENT)

add_heading(doc, "Operational", level=2)
for item in [
    "New data source onboarded with a single metadata row — no pipeline build or deployment required",
    "Centralised on/off control for any ingestion job without touching ADF pipelines or triggers",
    "Connection and path changes applied in metadata — no pipeline redeployment cycle",
    "Full visibility of all active ingestion jobs by querying a single control table",
    "Consistent pipeline behaviour across all sources — one proven pattern, not hundreds of variations",
    "Factory-level parameters (server, database) managed in one place via ADF Global Parameters",
]:
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    p.add_run(item).font.size = Pt(10)

add_heading(doc, "Engineering", level=2)
for item in [
    "Dramatically reduced pipeline maintenance surface — one generic pipeline replaces one-per-source",
    "Environment portability — the same pipelines run across dev, test, and production with different metadata records",
    "Full Refresh and Incremental patterns supported from a single framework with no pipeline duplication",
    "Compressed source files (GZIP, ZIP, TarGzip) and binary pass-through handled via dedicated datasets",
    "Enforced naming conventions enable automated tooling, monitoring dashboards, and documentation generation",
    "Idempotent DDL supports safe schema deployment and controlled schema evolution across environments",
]:
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    p.add_run(item).font.size = Pt(10)

add_heading(doc, "Resilience & Governance", level=2)
for item in [
    "Null watermark guard (WM001) prevents unfiltered full-table reads on misconfigured incremental jobs",
    "Zero-rows guard ensures watermark is only advanced when data was actually transferred",
    "Copy failure dependency ensures watermark is never advanced on a failed run — retry picks up from the same boundary",
    "Audit trail on every ingestion job — who configured what, and when",
    "Business domain classification on every job — supports data lineage and ownership tracking",
    "Centralised watermark state — incremental load boundaries are visible and auditable across all jobs",
]:
    p = doc.add_paragraph(style="List Bullet")
    p.paragraph_format.space_after = Pt(3)
    p.add_run(item).font.size = Pt(10)

doc.add_paragraph()

# ── Appendix ─────────────────────────────────────────────────────────────────
add_heading(doc, "Appendix — Schema Quick Reference", level=1, color=ACCENT)
add_table(doc,
    ["Object", "Type", "Purpose", "ADF Role"],
    [
        ["EDP_Metadata.MetadataRef", "Table", "Core control table — one row per ingestion job", "Primary config store; queried via MasterRef"],
        ["EDP_Metadata.MasterRef",   "View",  "Denormalized runtime view; derives Pipeline_Name and SwitchCaseRef", "Target of the Lookup activity"],
        ["EDP_Metadata.Watermark",   "Table", "High-water mark per incremental job; updated after each successful run", "Read by Lookup via MasterRef; written by Update_Watermark Script activity"],
        ["EDP_Metadata.DatasetRef",  "Table", "Unique Source + FileFormat combinations, including compressed variants", "Resolved via MasterRef"],
        ["EDP_Metadata.LinkedServiceRef","Table","ADF linked service catalog with JSON connection templates","Resolved via MasterRef"],
        ["EDP_Metadata.SourceRef",   "Table", "Supported data source types and short codes", "Resolved via MasterRef"],
        ["EDP_Metadata.FileFormat",  "Table", "Supported file formats including compression variants", "Resolved via MasterRef"],
        ["EDP_Metadata.SystemAuth",  "Table", "Supported authentication types and applicable connectors", "Resolved via MasterRef"],
        ["EDP_Metadata.BusinessDomainRef","Table","Business domain classification","Resolved via MasterRef"],
        ["EDP_Metadata.colDelimitterRef","Table","Column delimiter reference values","Resolved via MasterRef"],
    ]
)

# ── Footer ────────────────────────────────────────────────────────────────────
footer_p = doc.add_paragraph()
footer_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
footer_p.paragraph_format.space_before = Pt(20)
fr = footer_p.add_run(
    "Enterprise Data Platform  |  Metadata-Driven Ingestion Framework  |  Version 2.0  |  August 2026  |  Internal Use Only"
)
fr.font.size = Pt(8)
fr.font.color.rgb = LABEL

# ── Save ──────────────────────────────────────────────────────────────────────
doc.save(OUTPUT_PATH)
print(f"Saved: {OUTPUT_PATH}")
