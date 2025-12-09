-- View to combine specimen data from Branch 1 and Branch 2
CREATE VIEW dbo.v_AllSpecimen
AS
    SELECT 
        specimen_id,
        encounter_id,
        patient_id,
        specimen_type COLLATE Vietnamese_CI_AS AS specimen_type,
        test_code     COLLATE Vietnamese_CI_AS AS test_code,
        collection_date,
        status        COLLATE Vietnamese_CI_AS AS status,
        1 AS branch_id
    FROM Branch_1.Branch_1.dbo.[SPECIMEN.1.1]

    UNION ALL

    SELECT 
        specimen_id,
        encounter_id,
        patient_id,
        specimen_type COLLATE Vietnamese_CI_AS AS specimen_type,
        test_code     COLLATE Vietnamese_CI_AS AS test_code,
        collection_date,
        status        COLLATE Vietnamese_CI_AS AS status,
        2 AS branch_id
    FROM Branch_2.Branch_2.dbo.[SPECIMEN.1.2];
GO

-- View to join test catalog data
CREATE VIEW dbo.v_TestCatalog
AS
SELECT 
    f1.test_code      COLLATE Latin1_General_CI_AS AS test_code,
    f1.test_name      COLLATE Latin1_General_CI_AS AS test_name,
    f1.category       COLLATE Latin1_General_CI_AS AS category,
    f1.price,
    f1.is_active,
    f2.method         COLLATE Latin1_General_CI_AS AS method,
    f2.analyte        COLLATE Latin1_General_CI_AS AS analyte,
    f2.unit           COLLATE Latin1_General_CI_AS AS unit,
    f2.ref_range_low,
    f2.ref_range_high,
    f2.ref_range_text COLLATE Latin1_General_CI_AS AS ref_range_text
FROM Branch_2.Branch_2.dbo.[TEST_CATALOG.1] AS f1
JOIN dbo.[TEST_CATALOG.2] AS f2
    ON f1.test_code COLLATE Latin1_General_CI_AS
     = f2.test_code COLLATE Latin1_General_CI_AS;
GO

-- View to union patient data from Branch 1 and Branch 2
CREATE OR ALTER VIEW dbo.v_AllPatients
AS
SELECT
    patient_id,
    first_name   COLLATE SQL_Latin1_General_CP1_CI_AS AS first_name,
    last_name    COLLATE SQL_Latin1_General_CP1_CI_AS AS last_name,
    date_of_birth,
    gender       COLLATE SQL_Latin1_General_CP1_CI_AS AS gender,
    phone_number COLLATE SQL_Latin1_General_CP1_CI_AS AS phone_number,
    email        COLLATE SQL_Latin1_General_CP1_CI_AS AS email,
    address      COLLATE SQL_Latin1_General_CP1_CI_AS AS address,
    1 AS branch_id
FROM Branch_1.Branch_1.dbo.[PATIENT.1]

UNION ALL

SELECT
    patient_id,
    first_name   COLLATE SQL_Latin1_General_CP1_CI_AS AS first_name,
    last_name    COLLATE SQL_Latin1_General_CP1_CI_AS AS last_name,
    date_of_birth,
    gender       COLLATE SQL_Latin1_General_CP1_CI_AS AS gender,
    phone_number COLLATE SQL_Latin1_General_CP1_CI_AS AS phone_number,
    email        COLLATE SQL_Latin1_General_CP1_CI_AS AS email,
    address      COLLATE SQL_Latin1_General_CP1_CI_AS AS address,
    2 AS branch_id
FROM Branch_2.Branch_2.dbo.[PATIENT.2];
GO