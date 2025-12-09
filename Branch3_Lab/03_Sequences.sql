-- Global patient ID sequence
CREATE SEQUENCE dbo.PatientIdSeq
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

-- Global encounter ID sequence
CREATE SEQUENCE dbo.EncounterIdSeq
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

-- Global specimen ID sequence
CREATE SEQUENCE dbo.SpecimenIdSeq
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

-- Global test result ID sequence
CREATE SEQUENCE dbo.TestResultIdSeq
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO
