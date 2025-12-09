--- Trigger to enforce monotonic specimen status transitions at Lab
CREATE TRIGGER TR_SPECIMEN_STATUS_MONOTONIC_LAB
ON SPECIMEN
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(status) RETURN;

    ;WITH Changes AS (
        SELECT
            d.specimen_id,
            d.status AS old_status,
            i.status AS new_status
        FROM deleted d
        JOIN inserted i
            ON d.specimen_id = i.specimen_id
    )
    SELECT *
    INTO #InvalidTransitions
    FROM Changes c
    WHERE NOT (
            -- same status is always allowed
            c.old_status = c.new_status

            -- Collected → InLab / Archived / Disposed
         OR (c.old_status = 'Collected'
             AND c.new_status IN ('InLab', 'Archived', 'Disposed'))

            -- InLab → Archived / Disposed
         OR (c.old_status = 'InLab'
             AND c.new_status IN ('Archived', 'Disposed'))

            -- Archived → Disposed
         OR (c.old_status = 'Archived'
             AND c.new_status = 'Disposed')
    );

    IF EXISTS (SELECT 1 FROM #InvalidTransitions)
    BEGIN
        RAISERROR('Invalid status transition at lab.', 16, 1);
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
