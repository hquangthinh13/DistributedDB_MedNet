CREATE TABLE BRANCH (
    branch_id INT PRIMARY KEY,
    type VARCHAR(6) CHECK (type IN ('Lab', 'Clinic')),
    address VARCHAR(100)
);

CREATE TABLE [TEST_CATALOG.2] (
    test_code VARCHAR(20) PRIMARY KEY,
    method VARCHAR(50),
    analyte VARCHAR(50),
    unit VARCHAR(20),
    ref_range_low INT,
    ref_range_high INT,
    ref_range_text VARCHAR(100),
    CONSTRAINT CHK_REF_RANGE CHECK (ref_range_low < ref_range_high)
);

CREATE TABLE [SPECIMEN.2] (
    specimen_id INT PRIMARY KEY,
    test_code VARCHAR(20),
    status VARCHAR(10) CHECK (status IN ('Collected', 'InLab', 'Archived', 'Disposed')),
    CONSTRAINT FK_SPECIMEN_TESTCATALOG FOREIGN KEY (test_code)
        REFERENCES [TEST_CATALOG.2](test_code),
);


CREATE TABLE TEST_RESULT (
    result_id INT PRIMARY KEY,
    branch_id INT,
    specimen_id INT,
    result_datetime DATETIME,
    result_numeric FLOAT,
    CONSTRAINT FK_TESTRESULT_BRANCH FOREIGN KEY (branch_id)
        REFERENCES BRANCH(branch_id),
    CONSTRAINT FK_TESTRESULT_SPECIMEN FOREIGN KEY (specimen_id)
        REFERENCES [SPECIMEN.2](specimen_id)
);