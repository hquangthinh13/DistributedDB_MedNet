-- 1. Trigger to prevent restoring a Disposed specimen.
CREATE TRIGGER TR_SPECIMEN_1_2_CHECK_STATUS_FLOW
ON [SPECIMEN.1.2]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Logic check: Do not update from 'Disposed' to any other state
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN inserted i ON d.specimen_id = i.specimen_id
        WHERE d.status = 'Disposed' AND i.status != 'Disposed'
    )
    BEGIN
        -- Standardized error message in English
        RAISERROR ('[BUSINESS RULE VIOLATION] Unable to recover a specimen that has been Disposed.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

--- 2. A patient is not allowed to do the same test more than once on the same day.---
CREATE TRIGGER TR_SPECIMEN_1_2_PREVENT_DUPLICATE_TODAY
ON [SPECIMEN.1.2]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

-- Check if there is another sample with the same Patient, same TestCode, same sampling date
    IF EXISTS (
        SELECT 1
        FROM [SPECIMEN.1.2] S
        JOIN inserted I ON S.patient_id = I.patient_id 
                        AND S.test_code = I.test_code
        WHERE S.specimen_id <> I.specimen_id -- Different ID or not  
          AND CAST(S.collection_date AS DATE) = CAST(I.collection_date AS DATE) -- Same day 
    )
    BEGIN
        RAISERROR ('[ERROR] This patient has already had this test today!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO