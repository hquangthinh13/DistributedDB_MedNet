-- Procedure to insert a new patient
CREATE PROCEDURE dbo.usp_InsertPatient_B1
    @first_name     VARCHAR(50),
    @last_name      VARCHAR(50),
    @date_of_birth  DATE        = NULL,
    @gender         CHAR(1),
    @phone_number   VARCHAR(10) = NULL,
    @email          VARCHAR(50) = NULL,
    @address        VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @patient_id INT;

    -- Get a global ID from Branch_3
    EXEC Branch_3.Branch_3.dbo.usp_GetNewPatientId @patient_id OUTPUT;
    INSERT INTO [PATIENT.1] (
        patient_id,
        first_name,
        last_name,
        date_of_birth,
        gender,
        phone_number,
        email,
        address
    )
    VALUES (
        @patient_id,
        @first_name,
        @last_name,
        @date_of_birth,
        @gender,
        @phone_number,
        @email,
        @address
    );
END;
GO

-- Procedure to insert a new encounter
CREATE PROCEDURE dbo.usp_InsertNewEncounter_B1
    @patient_id     INT,
    @encounter_date DATE,
    @encounter_type VARCHAR(20),
    @notes          VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM [PATIENT.1] WHERE patient_id = @patient_id)
    BEGIN
        RAISERROR('Patient does not exist at Branch_2.', 16, 1);
        RETURN;
    END;

    -- Get a globally unique encounter_id from Branch_3
    DECLARE @encounter_id INT;
    EXEC Branch_3.Branch_3.dbo.usp_GetNewEncounterId @encounter_id OUTPUT;

    INSERT INTO [ENCOUNTER.1] (
        encounter_id,
        patient_id,
        branch_id,
        encounter_date,
        encounter_type,
        notes
    )
    VALUES (
        @encounter_id,
        @patient_id,
        1,                -- Branch_1
        @encounter_date,
        @encounter_type,
        @notes
    );
END;
GO

-- Procedure to insert a new specimen
CREATE PROCEDURE dbo.usp_CreateSpecimen_B1
    @encounter_id    INT,
    @patient_id      INT,
    @specimen_type   VARCHAR(30),
    @test_code       VARCHAR(20),
    @collection_date DATETIME,
    @status          VARCHAR(10) = 'Collected'
AS
BEGIN
    SET NOCOUNT ON;

    -- Basic checks
    IF NOT EXISTS (SELECT 1 FROM [ENCOUNTER.1] WHERE encounter_id = @encounter_id AND patient_id = @patient_id)
    BEGIN
        RAISERROR('Encounter does not exist for this patient at Branch_1.', 16, 1);
        RETURN;
    END;

    IF @status NOT IN ('Collected', 'InLab', 'Archived', 'Disposed')
    BEGIN
        RAISERROR('Invalid specimen status.', 16, 1);
        RETURN;
    END;

    -- Get a globally unique specimen_id from Branch_3
    DECLARE @specimen_id INT;
    EXEC Branch_3.Branch_3.dbo.usp_GetNewSpecimenId @specimen_id OUTPUT;

    BEGIN TRY
        -- Insert into Branch_2
        INSERT INTO [SPECIMEN.1.1] (
            specimen_id,
            encounter_id,
            patient_id,
            specimen_type,
            test_code,
            collection_date,
            status
        )
        VALUES (
            @specimen_id,
            @encounter_id,
            @patient_id,
            @specimen_type,
            @test_code,
            @collection_date,
            @status
        );

        -- Insert into Branch_3 (Lab fragment)
        INSERT INTO Branch_3.Branch_3.dbo.[SPECIMEN.2] (
            specimen_id,
            test_code,
            status
        )
        VALUES (
            @specimen_id,
            @test_code,
            @status
        );

    END TRY
    BEGIN CATCH
        THROW;  -- let the caller see the error
    END CATCH
END;
GO

-- Procedure to get encounter test results
CREATE PROCEDURE dbo.usp_GetEncounterTestResults_B1
    @encounter_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.encounter_id,
        e.encounter_date,
        p.patient_id,
        p.first_name,
        p.last_name,
        s.specimen_id,
        s.specimen_type,
        s.collection_date,
        s.status           AS clinic_specimen_status,
        s2.status          AS lab_specimen_status,
        s.test_code,
        tc.test_name,
        tr.result_id,
        tr.result_datetime,
        tr.result_numeric
    FROM [ENCOUNTER.1] e
    JOIN [PATIENT.1]      p   ON p.patient_id   = e.patient_id
    JOIN [SPECIMEN.1.1]   s   ON s.encounter_id = e.encounter_id
    LEFT JOIN [TEST_CATALOG.1] tc
        ON tc.test_code = s.test_code
    LEFT JOIN Branch_3.Branch_3.dbo.[SPECIMEN.2] s2
        ON s2.specimen_id = s.specimen_id
    LEFT JOIN Branch_3.Branch_3.dbo.TEST_RESULT tr
        ON tr.specimen_id = s.specimen_id
        AND tr.branch_id   = 1        -- Site 2
    WHERE e.encounter_id = @encounter_id;
END;
GO

-- Procedure to update specimen's status
CREATE PROCEDURE dbo.usp_UpdateSpecimenStatus_B1
    @specimen_id INT,
    @new_status  VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Update local fragment
        UPDATE s
        SET s.status = @new_status
        FROM [SPECIMEN.1.1] AS s
        WHERE s.specimen_id = @specimen_id;

        -- Update Lab fragment (linked server)
        UPDATE s1
        SET s1.status = @new_status
        FROM Branch_3.Branch_3.dbo.[SPECIMEN.2] AS s1
        WHERE s1.specimen_id = @specimen_id;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Procedure to sync Delete a specimen
CREATE OR ALTER PROCEDURE dbo.usp_DeleteSpecimen_B1
    @specimen_id INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Using a direct check: Does this specimen have test results?
    IF EXISTS (SELECT 1 FROM Branch_3.Branch_3.dbo.TEST_RESULT WHERE specimen_id = @specimen_id)
    BEGIN
        RAISERROR('Cannot delete specimen that has test results.', 16, 1);
        RETURN;
    END

    -- Execute delete    
    BEGIN TRY
        -- Delete at Site 3 FIRST
        DELETE FROM Branch_3.Branch_3.dbo.[SPECIMEN.2] 
        WHERE specimen_id = @specimen_id;

        -- Delete at Site 2 AFTER
        DELETE FROM [SPECIMEN.1.1] 
        WHERE specimen_id = @specimen_id;

        PRINT '>>> SUCCESS: Synchronized delete completed on both Sites!';
    END TRY
    BEGIN CATCH
        PRINT '>>> ERROR: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
