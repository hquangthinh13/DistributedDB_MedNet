--Insert test catalog:
EXEC dbo.usp_InsertTestCatalog_AllSites
    @test_code      = 'CBC01',
    @test_name      = 'Complete Blood Count',
    @category       = 'Hematology',
    @price          = 150000,
    @is_active      = 1,
    @method         = 'Automated Analyzer',
    @analyte        = 'Hemoglobin',
    @unit           = 'g/dL',
    @ref_range_low  = 12,
    @ref_range_high = 16,
    @ref_range_text = 'Normal: 12–16 g/dL';

SELECT *
FROM Branch_1.Branch_1.dbo.[TEST_CATALOG.1];

SELECT *
FROM Branch_2.Branch_2.dbo.[TEST_CATALOG.1];

SELECT *
FROM Branch_2.Branch_2.dbo.[SPECIMEN.1.2];

--Update specimen status:
exec dbo.usp_UpdateSpecimenStatus_Lab
    @specimen_id =2 ,
    @new_status='Archived';

--Insert test result:
EXEC dbo.usp_InsertTestResult_Lab
    @specimen_id = 4,
    @result_numeric = 5.6;

select * from TEST_RESULT;

--Delete test catalog:
exec dbo.usp_DeleteTestCatalog_Lab 'CBC01';




--Attempt to delete specimen with test result (should fail):
DELETE FROM [SPECIMEN.2]
WHERE specimen_id = 1;


--Get new patient ID:
DECLARE @newPatientId INT;

EXEC dbo.usp_GetNewPatientId @patient_id = @newPatientId OUTPUT;

SELECT @newPatientId AS NewPatientId;

--Views:
select * from dbo.v_AllSpecimen;
select * from dbo.v_TestCatalog;
select * from dbo.v_AllPatients;

