---TEST PROCEDURE---- 
---1. INSERT PATIENT, ENCOUNTER, AND SPECIMEN---
SET NOCOUNT ON;
DECLARE @PatID INT, @EncID INT;
-- 2. PATIENT: LAN TRAN
-- A. Insert Patient
EXEC dbo.usp_InsertPatient_B2 'Lan', 'Tran', '1995-10-20', 'F', '0909876543', 'lan.tran@email.com', 'Thu Duc, TP.HCM';
-- B. Retrieve generated ID,  Encounter
DECLARE @PatID INT;
SELECT @PatID = patient_id FROM [PATIENT.2] WHERE email = 'lan.tran@email.com';
EXEC dbo.usp_InsertNewEncounter_B2 @PatID, '2025-12-02 10:15:00', 'Consultation', 'Dau hong va sot nhe';

-- 3. PATIENT: MAI PHAM
DECLARE @PatID INT, @EncID INT;
-- A. Insert Patient
EXEC dbo.usp_InsertPatient_B2 'Mai', 'Pham', '2000-12-01', 'F', '0987654321', 'mai.pham@email.com', 'Q3, TP.HCM';
-- B. Retrieve generated ID, ENCOUNTER 
SELECT @PatID = patient_id FROM [PATIENT.2] WHERE email = 'mai.pham@email.com';
EXEC dbo.usp_InsertNewEncounter_B2 @PatID, '2025-12-03 11:00:00', 'LabTest', 'Kiem tra suc khoe xin viec';

    -- Insert Specimens
    EXEC dbo.usp_CreateSpecimen_B2 4, 5, 'Swab', 'COVID_PCR', '2025-12-02 10:30:00', 'Disposed';
    EXEC dbo.usp_CreateSpecimen_B2 5, 6, 'Blood', 'GLU_FAST', '2025-12-03 11:15:00', 'InLab';

-- D. Encounter 2 (COVID Test)
   EXEC dbo.usp_InsertNewEncounter_B2 6, '2025-12-04 15:30:00', 'LabTest', 'Xet nghiem COVID';
-- Insert Specimen
   EXEC dbo.usp_CreateSpecimen_B2 5, 6, 'Swab', 'COVID_PCR', '2025-12-04 15:45:00', 'Archived';
GO

----2. Test procedure Update Specimen Status---
select * from [SPECIMEN.1.2]
EXEC dbo.usp_UpdateSpecimenStatus_B2
    @specimen_id = 2,
    @new_status  = 'InLab';

---3. Test procedure Get Results ----
EXEC dbo.usp_GetEncounterTestResults_B2 5;

---4. Test procedure Delete Specimen---
--CREATE NEW DATA FOR TESTING
DECLARE @PatID INT, @EncID INT, @SpecID INT;
EXEC dbo.usp_InsertPatient_B2 'Nguyen', 'Van Test', '1999-01-01', 'M', '0999111222', 'test.msdtc@email.com', 'HCM';
SELECT @PatID = patient_id FROM [PATIENT.2] WHERE email = 'test.msdtc@email.com';

EXEC dbo.usp_InsertNewEncounter_B2 @PatID, '2025-12-10', 'LabTest', 'Test Delete Proc';
SELECT TOP 1 @EncID = encounter_id FROM [ENCOUNTER.2] WHERE patient_id = @PatID ORDER BY encounter_id DESC;

EXEC dbo.usp_CreateSpecimen_B2 @EncID, @PatID, 'Swab', 'COVID_PCR', '2025-12-10', 'Collected';
SELECT TOP 1 @SpecID = specimen_id FROM [SPECIMEN.1.2] WHERE encounter_id = @EncID;

SELECT * FROM [PATIENT.2] 
SELECT * FROM [SPECIMEN.1.2] 
-- DELETE USING PROCEDURE 
EXEC dbo.usp_DeleteSpecimen_B2 @specimen_id = 17;