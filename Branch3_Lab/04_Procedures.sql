-- Procedure to get a new global patient_id
CREATE PROCEDURE dbo.usp_GetNewPatientId
    @patient_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @patient_id = NEXT VALUE FOR dbo.PatientIdSeq;
END;
GO

-- Procedure to get a new global encounter_id
CREATE PROCEDURE dbo.usp_GetNewEncounterId
    @encounter_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @encounter_id = NEXT VALUE FOR dbo.EncounterIdSeq;
END;
GO

-- Procedure to get a new global specimen_id
CREATE PROCEDURE dbo.usp_GetNewSpecimenId
    @specimen_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @specimen_id = NEXT VALUE FOR dbo.SpecimenIdSeq;
END;
GO