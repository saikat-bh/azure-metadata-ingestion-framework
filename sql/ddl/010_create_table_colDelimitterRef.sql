
CREATE TABLE EDP_Metadata.colDelimitterRef
(
    colDelRefID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    colDelRefName VARCHAR(100) NOT NULL,
    colDelRefValue VARCHAR(20) NULL
);


-- Insert reference values
INSERT INTO EDP_Metadata.colDelimitterRef
(
    colDelRefName,
    colDelRefValue
)
VALUES
    ('Comma', ','),
    ('Semicolon', ';'),
    ('Pipe', '|'),
    ('Tab', '\t'),
    ('Start of heading', '\u0001'),
    ('No delimiter', NULL);
GO

-- Verify data
SELECT *
FROM EDP_Metadata.colDelimitterRef
ORDER BY colDelRefID;
