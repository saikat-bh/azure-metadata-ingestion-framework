# Azure Metadata-Driven Ingestion Framework

## Project Overview
A metadata-driven ingestion framework built on Azure. ADF pipelines (Full and Incremental) are generated dynamically per data source, driven by metadata stored in Azure SQL Database.

## Azure Resources (Subscription: Saikat_Subscription)
- **Subscription ID:** d56ace31-d353-4f3c-8944-4673522b75ac
- **Tenant ID:** 32233fea-ba06-4cef-a970-59f8be3d5d04
- **Resource Group:** rg-claude-ind (centralindia)
- **ADF:** adfclaude01
- **Storage (ADLS):** adlsclaude01
- **Key Vault:** akvclaude01
- **SQL Server:** asqlserverclaude01
- **SQL Database:** asqlclaude01

## Architecture
- Metadata tables in `asqlclaude01` drive all pipeline behaviour
- ADF uses Lookup activities to read metadata at runtime
- Two pipelines per data source: **Full Refresh** and **Incremental**
- Linked services, datasets, and parameters are all dynamically populated

## Project Structure
```
Azure_Claude/
├── .claude/
│   └── settings.json          # MCP server config (Azure MCP)
├── adf/
│   ├── pipelines/             # ADF pipeline JSON definitions
│   ├── datasets/              # ADF dataset JSON definitions
│   └── linked_services/       # ADF linked service JSON definitions
├── metadata/                  # Metadata config files / exports
├── sql/
│   ├── ddl/                   # CREATE TABLE scripts for metadata tables
│   └── seed/                  # INSERT scripts to seed metadata
└── docs/                      # Architecture diagrams, design notes
```

## MCP Server
The Azure MCP server is configured in `.claude/settings.json` and runs via `npx @azure/mcp@latest`. It uses the Azure CLI credentials already authenticated on this machine.
