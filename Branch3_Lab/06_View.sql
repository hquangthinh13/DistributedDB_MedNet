-- Create view to combine specimen data from Branch 1 and Branch 2
CREATE VIEW dbo.v_AllSpecimen
AS
    SELECT specimen_id, status, 1 AS branch_id
    FROM Branch_1.Branch_1.dbo.[SPECIMEN.1.1]
    UNION ALL
    SELECT specimen_id, status, 2 AS branch_id
    FROM Branch_2.Branch_2.dbo.[SPECIMEN.1.2];
GO