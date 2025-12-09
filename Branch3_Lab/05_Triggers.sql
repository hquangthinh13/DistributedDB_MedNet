-- Trigger to enforce business rule on specimen status transitions
CREATE TRIGGER TR_SPECIMEN_2_CHECK_STATUS_FLOW
ON [SPECIMEN.2]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------
    -- Business Rule:
    -- Once a specimen is marked as 'Disposed', it cannot
    -- transition back to any other status.
    ---------------------------------------------------------
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN inserted i ON d.specimen_id = i.specimen_id
        WHERE d.status = 'Disposed'
          AND i.status <> 'Disposed'
    )
    BEGIN
        RAISERROR (
            '[BUSINESS RULE VIOLATION] Unable to recover a specimen that has been Disposed.',
            16,
            1
        );
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


-- Trigger to prevent deletion of specimens that have test results
CREATE TRIGGER TR_SPECIMEN_PREVENT_DELETE_IF_RESULT
ON [SPECIMEN.2]
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN TEST_RESULT tr
          ON tr.specimen_id = d.specimen_id
    )
    BEGIN
        RAISERROR('Cannot delete specimen that has test results.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    DELETE s
    FROM [SPECIMEN.2] s
    JOIN deleted d ON s.specimen_id = d.specimen_id;
END;
GO

