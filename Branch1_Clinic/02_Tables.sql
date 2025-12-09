CREATE TABLE [PATIENT.1] (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50)  NOT NULL,
    date_of_birth DATE,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F', 'O')),
    phone_number VARCHAR(10),
    email VARCHAR(50) UNIQUE,
    address VARCHAR(100)
);

CREATE TABLE BRANCH (
    branch_id INT PRIMARY KEY,
    type VARCHAR(6) CHECK (type IN ('Lab', 'Clinic')),
    address VARCHAR(100)
);

CREATE TABLE [TEST_CATALOG.1] (
    test_code VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(50),
    category VARCHAR(20),
    price INT CHECK (price >= 0),
    is_active BIT
);

CREATE TABLE [ENCOUNTER.1] (
    encounter_id INT PRIMARY KEY,
    patient_id INT,
    branch_id INT,
    encounter_date DATETIME,
    encounter_type VARCHAR(20) CHECK (encounter_type IN ('Consultation', 'FollowUp', 'LabTest')),
    notes VARCHAR(300),
    CONSTRAINT FK_ENCOUNTER_PATIENT FOREIGN KEY (patient_id)
        REFERENCES [PATIENT.1](patient_id),
    CONSTRAINT FK_ENCOUNTER_BRANCH FOREIGN KEY (branch_id)
        REFERENCES BRANCH(branch_id)
);


CREATE TABLE [SPECIMEN.1.1] (
    specimen_id INT PRIMARY KEY,
    encounter_id INT,
    patient_id INT,
    specimen_type VARCHAR(30) CHECK (specimen_type IN ('Blood', 'Urine', 'Tissue', 'Stool', 'Swab', 'Other')),
    test_code VARCHAR(20),
    collection_date DATETIME,
    status VARCHAR(10) CHECK (status IN ('Collected', 'InLab', 'Archived', 'Disposed')),
    CONSTRAINT FK_SPECIMEN_ENCOUNTER FOREIGN KEY (encounter_id)
        REFERENCES [ENCOUNTER.1](encounter_id),
    CONSTRAINT FK_SPECIMEN_PATIENT FOREIGN KEY (patient_id)
        REFERENCES [PATIENT.1](patient_id),
    CONSTRAINT FK_SPECIMEN_TESTCATALOG FOREIGN KEY (test_code)
        REFERENCES [TEST_CATALOG.1](test_code)
);
