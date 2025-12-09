# Distributed Medical Laboratory System

A distributed database system managing clinical operations across 3 physical sites (2 Clinics, 1 Central Lab) using Microsoft SQL Server.

## Prerequisites
- **Microsoft SQL Server** (2019 or newer) installed on 3 separate instances (or 3 distinct databases on one instance for simulation).
- **SQL Server Management Studio (SSMS)**.
- **TCP/IP Protocol** enabled in SQL Server Configuration Manager.

## Installation & Configuration Guide

### Step 1: Database Initialization
1. Open SSMS and connect to your SQL Server instance.
2. Execute the initialization scripts for each site:
   - **Site 1 (Clinic):** Run `Branch1_Clinic/Init_DB1.sql`
   - **Site 2 (Clinic):** Run `Branch2_Clinic/Init_DB2.sql`
   - **Site 3 (Lab):** Run `Branch3_Lab/Init_DB3.sql`

### Step 2: Configure Linked Servers
To enable distributed queries, you must configure the Linked Servers:
- **On Site 1:** Execute `Branch1_Clinic/Setup_LinkedServer.sql` to connect to Lab (Site 3).
- **On Site 2:** Execute `Branch2_Clinic/Setup_LinkedServer.sql` to connect to Lab (Site 3).
- **On Site 3:** Execute `Branch3_Lab/Setup_LinkedServer.sql` to connect back to Clinics.

### Step 3: Deploy Schema Objects
Run the scripts in the following order for **EACH** site folder:
1. `Tables.sql` (Create tables and constraints)
2. `Procedures.sql` (Create Stored Procedures)
3. `Triggers.sql` (Create Business Rule Triggers)

## Testing & Validation
Navigate to the `Testing_Scripts` folder to validate the system:
- **`Test_Duplicate_Check.sql`**: Verifies the trigger that prevents a patient from taking the same test twice

