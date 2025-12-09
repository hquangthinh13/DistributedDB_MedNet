-- Insert new patient, Insert new encounter
SET NOCOUNT ON;
DECLARE @PatID INT, @EncID INT;

-- 1. PATIENT: MINH NGUYEN
-- A. Insert Patient
EXEC dbo.usp_InsertPatient_B1 'Minh', 'Nguyen', '1990-05-15', 'M', '0901234567', 'minh.nguyen@email.com', 'Q1, TP.HCM';

-- B. Retrieve generated ID
SELECT @PatID = patient_id FROM [PATIENT.1] WHERE email = 'minh.nguyen@email.com';
EXEC dbo.usp_InsertNewEncounter_B1 @PatID, '2025-12-01 08:00:00', 'Consultation', 'Kham tong quat dau ky';
    
    -- Retrieve Encounter ID
    DECLARE @PatID INT, @EncID INT;
    SELECT @EncID = encounter_id FROM [ENCOUNTER.1] WHERE patient_id = @PatID AND encounter_date = '2025-12-01 08:00:00';
    
    -- Insert Specimen (GLU_FAST)'
    EXEC dbo.usp_CreateSpecimen_B1 8, 11, 'Blood', 'GLU_FAST', '2025-12-01 08:15:00', 'InLab';
    select * from [SPECIMEN.1.1];
-- C. Encounter 2: FollowUp (Tai kham)
EXEC dbo.usp_InsertNewEncounter_B1 11, '2025-12-05 14:00:00', 'FollowUp', 'Tai kham sau khi co ket qua';

-- 2. PATIENT: HUNG LE
-- A. Insert Patient
DECLARE @PatID INT, @EncID INT;
EXEC dbo.usp_InsertPatient_B1 'Hung', 'Le', '1985-03-08', 'M', '0912345678', 'hung.le@email.com', 'Binh Thanh, TP.HCM';

-- B. Retrieve generated ID
SELECT @PatID = patient_id FROM [PATIENT.1] WHERE email = 'hung.le@email.com';

-- C. Encounter 1: LabTest (Xet nghiem mau)
EXEC dbo.usp_InsertNewEncounter_B1 12, '2025-12-01 09:30:00', 'LabTest', 'Xet nghiem mau dinh ky';

    -- Retrieve Encounter ID
    DECLARE @PatID INT, @EncID INT;
    SELECT @EncID = encounter_id FROM [ENCOUNTER.1] WHERE patient_id = @PatID AND encounter_date = '2025-12-01 09:30:00';

    -- Insert Specimen 1 (CBC)
    USE Branch_1;
    GO

    EXEC dbo.usp_CreateSpecimen_B1 10, 12, 'Blood', 'CBC', '2025-12-01 09:45:00', 'Collected';
    
    -- Insert Specimen 2 (UA)
    EXEC dbo.usp_CreateSpecimen_B1 10, 12, 'Urine', 'UA', '2025-12-01 09:50:00', 'Collected';
GO


-- Get encounter test result of encounter_id = 10
EXEC dbo.usp_GetEncounterTestResults_B1 10;

-- Update specimen's status of specimen_id = 5 to 'InLab'
EXEC dbo.usp_UpdateSpecimenStatus_B1
    @specimen_id = 5,
    @new_status  = 'InLab';
SELECT * FROM SPECIMEN.1.1;

-- Trigger to Check specimen status flow
UPDATE [SPECIMEN.1.1] 
SET status = 'Disposed' --first update 'Disposed' status
WHERE specimen_id = 4;

UPDATE [SPECIMEN.1.1] 
SET status = 'Disposed' --then try update another status
WHERE specimen_id = 4;

-- Trigger to Prevent same test a day
    ---- Create new encounter to test---
DECLARE @EncID INT;
EXEC dbo.usp_InsertNewEncounter_B1 
    @patient_id = 11, 
    @encounter_date = '2025-12-09 15:30:00', 
    @encounter_type = 'LabTest', 
    @notes = 'Test Trigger Chan Trung Lap';
SELECT * FROM [ENCOUNTER.1] 
-- Try to insert 2 same test of the same patient on the same encounter and date
EXEC dbo.usp_CreateSpecimen_B1 13, 11, 'Urine', 'UA', '2025-12-09', 'Collected';
EXEC dbo.usp_CreateSpecimen_B1 13, 11, 'Urine', 'UA', '2025-12-09', 'Collected';
select * from [PATIENT.1]
-- Try to insert 2 same test of the same patient and date but 2 different encounters
EXEC dbo.usp_InsertNewEncounter_B1 
    @patient_id = 11, 
    @encounter_date = '2025-12-09 17:00:00',
    @encounter_type = 'FollowUp', 
    @notes = 'Test Trigger Chan Trung Lap';
    select * from [ENCOUNTER.1]
EXEC dbo.usp_CreateSpecimen_B1 16, 11, 'Urine', 'UA', '2025-12-09', 'Collected';

-- Delete a specimen
    --Create new data for testing
    DECLARE @PatID INT, @EncID INT, @SpecID INT;
    EXEC dbo.usp_InsertPatient_B1 'Nguyen', 'Van Test', '1999-01-01', 'M', '0999111222', 'test1@email.com', 'HCM';
    SELECT @PatID = patient_id FROM [PATIENT.1] WHERE email = 'test1@email.com';

    EXEC dbo.usp_InsertNewEncounter_B1 @PatID, '2025-12-10', 'LabTest', 'Test Delete Proc';
    SELECT TOP 1 @EncID = encounter_id FROM [ENCOUNTER.1] WHERE patient_id = @PatID ORDER BY encounter_id DESC;

    EXEC dbo.usp_CreateSpecimen_B1 @EncID, @PatID, 'Swab', 'COVID_PCR', '2025-12-10', 'Collected';
    SELECT TOP 1 @SpecID = specimen_id FROM [SPECIMEN.1.1] WHERE encounter_id = @EncID;

    SELECT * FROM [PATIENT.1] 
    SELECT * FROM [SPECIMEN.1.1] 
    --Delete using procedure 
    EXEC dbo.usp_DeleteSpecimen_B1 @specimen_id = 18;
