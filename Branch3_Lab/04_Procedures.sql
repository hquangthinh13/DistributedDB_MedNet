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

-- Procedure to get a new test_result_id
CREATE PROCEDURE dbo.usp_GetNewTestResultId
    @test_result_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @test_result_id = NEXT VALUE FOR dbo.TestResultIdSeq;
END;
GO

-- Procedure to insert a new test into the fragmented TEST_CATALOG table across all branches
CREATE PROCEDURE dbo.usp_InsertTestCatalog_AllSites
    @test_code      VARCHAR(20),
    @test_name      VARCHAR(100),
    @category       VARCHAR(50),
    @price          INT,
    @is_active      BIT,
    @method         VARCHAR(50),
    @analyte        VARCHAR(50),
    @unit           VARCHAR(20),
    @ref_range_low  INT,
    @ref_range_high INT,
    @ref_range_text VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Fragment 1 on Branch_1
        INSERT INTO Branch_1.Branch_1.dbo.[TEST_CATALOG.1] (
            test_code, test_name, category, price, is_active
        )
        VALUES (
            @test_code, @test_name, @category, @price, @is_active
        );

        -- Fragment 1 on Branch_2
        INSERT INTO Branch_2.Branch_2.dbo.[TEST_CATALOG.1] (
            test_code, test_name, category, price, is_active
        )
        VALUES (
            @test_code, @test_name, @category, @price, @is_active
        );

        -- Fragment 2 on Branch_3 (current DB)
        INSERT INTO [TEST_CATALOG.2] (
            test_code, method, analyte, unit, ref_range_low, ref_range_high, ref_range_text
        )
        VALUES (
            @test_code, @method, @analyte, @unit, @ref_range_low, @ref_range_high, @ref_range_text
        );
    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000),
                @ErrSeverity INT;

        SELECT
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY();

        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH;
END;
GO

-- Procedure to update specimen status across all branches
CREATE PROCEDURE dbo.usp_UpdateSpecimenStatus_Lab
    @specimen_id INT,
    @new_status  VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        ---------------------------------------------------------
        -- 1. Update Lab fragment
        ---------------------------------------------------------
        UPDATE [SPECIMEN.2]
        SET status = @new_status
        WHERE specimen_id = @specimen_id;

        ---------------------------------------------------------
        -- 2. Push to Clinic 1
        ---------------------------------------------------------
        UPDATE Branch_1.Branch_1.dbo.[SPECIMEN.1.1]
        SET status = @new_status
        WHERE specimen_id = @specimen_id;

        ---------------------------------------------------------
        -- 3. Push to Clinic 2
        ---------------------------------------------------------
        UPDATE Branch_2.Branch_2.dbo.[SPECIMEN.1.2]
        SET status = @new_status
        WHERE specimen_id = @specimen_id;

    END TRY
    BEGIN CATCH
        ---------------------------------------------------------
        -- Rethrow the error (no transaction rollback needed)
        ---------------------------------------------------------
        THROW;
    END CATCH
END;
GO

-- Procedure to insert a test result at Lab and update specimen status
CREATE PROCEDURE dbo.usp_InsertTestResult_Lab
    @specimen_id     INT,
    @result_numeric  FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------
    -- 0. Generate new result_id from sequence
    ---------------------------------------------------------
    DECLARE @result_id INT;
    EXEC dbo.usp_GetNewTestResultId @test_result_id = @result_id OUTPUT;

    ---------------------------------------------------------
    -- 1. Auto-generate result_datetime
    ---------------------------------------------------------
    DECLARE @result_datetime DATETIME = GETDATE();

    ---------------------------------------------------------
    -- 2. Ensure specimen exists in Lab
    ---------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 FROM [SPECIMEN.2] WHERE specimen_id = @specimen_id
    )
    BEGIN
        RAISERROR('Specimen does not exist in Lab.', 16, 1);
        RETURN;
    END;

    ---------------------------------------------------------
    -- 3. Determine branch_id
    ---------------------------------------------------------
    DECLARE @branch_id INT;

    IF EXISTS (
        SELECT 1 FROM Branch_1.Branch_1.dbo.[SPECIMEN.1.1]
        WHERE specimen_id = @specimen_id
    )
        SET @branch_id = 1;
    ELSE IF EXISTS (
        SELECT 1 FROM Branch_2.Branch_2.dbo.[SPECIMEN.1.2]
        WHERE specimen_id = @specimen_id
    )
        SET @branch_id = 2;
    ELSE
    BEGIN
        RAISERROR('Specimen does not exist in clinic tables.', 16, 1);
        RETURN;
    END;

    ---------------------------------------------------------
    -- 4. Insert result
    ---------------------------------------------------------
    INSERT INTO TEST_RESULT (
        result_id,
        branch_id,
        specimen_id,
        result_datetime,
        result_numeric
    )
    VALUES (
        @result_id,
        @branch_id,
        @specimen_id,
        @result_datetime,
        @result_numeric
    );

    ---------------------------------------------------------
    -- 5. Archive specimen in Lab + branch
    ---------------------------------------------------------
    UPDATE [SPECIMEN.2]
    SET status = 'Archived'
    WHERE specimen_id = @specimen_id;

    IF @branch_id = 1
    BEGIN
        UPDATE Branch_1.Branch_1.dbo.[SPECIMEN.1.1]
        SET status = 'Archived'
        WHERE specimen_id = @specimen_id;
    END
    ELSE
    BEGIN
        UPDATE Branch_2.Branch_2.dbo.[SPECIMEN.1.2]
        SET status = 'Archived'
        WHERE specimen_id = @specimen_id;
    END;
END;
GO