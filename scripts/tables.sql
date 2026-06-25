CREATE TABLE Organization (
    organization_id INT AUTO_INCREMENT PRIMARY KEY,
    organization_name VARCHAR(255) NOT NULL,
    address VARCHAR(500),
    email VARCHAR(255),
    phone VARCHAR(50)
);

CREATE TABLE User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role VARCHAR(100)
);

CREATE TABLE Client (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    organization_id INT NOT NULL,
    client_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    created_date DATETIME,

    FOREIGN KEY (organization_id)
        REFERENCES Organization(organization_id)
);

CREATE TABLE Project (
    project_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,

    project_name VARCHAR(255) NOT NULL,
    description TEXT,

    status ENUM(
        'Awaiting Samples',
        'Samples Received',
        'In Progress',
        'Sequencing',
        'Data Analysis',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Awaiting Samples',

    created_date DATETIME,

    FOREIGN KEY (client_id)
        REFERENCES Client(client_id)
);

CREATE TABLE Submission (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    project_id INT NOT NULL,
    library_prep_required BOOLEAN DEFAULT FALSE,
    rna_extraction_required BOOLEAN DEFAULT FALSE,
    library_prep_kit VARCHAR(255),
    rna_extraction_kit VARCHAR(255),
    custom_sequencing_primer BOOLEAN DEFAULT FALSE,
    custom_primer VARCHAR(255),
    requested_sequencer VARCHAR(100),
    num_requested_lanes INT,
    multiplex BOOLEAN DEFAULT FALSE,
    samples_per_lane INT,
    read_length VARCHAR(50),
    alignment_required BOOLEAN DEFAULT FALSE,
    reference_genome VARCHAR(100),
    alignment_program VARCHAR(100),
    billing_comments TEXT,
    other_comments TEXT,
    submitted_date DATETIME DEFAULT CURRENT_TIMESTAMP,

    status ENUM(
        'Pending',
        'Approved',
        'In Progress',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Pending',

    FOREIGN KEY (project_id)
        REFERENCES Project(project_id)
);

CREATE TABLE Sample (
    sample_id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    sample_name VARCHAR(255) NOT NULL,
    sample_type VARCHAR(100),
    species VARCHAR(100),
    tissue_type VARCHAR(100),
    collection_date DATE,
    received_date DATE,

    status ENUM(
        'Awaiting Receipt',
        'Received',
        'QC Pending',
        'QC Passed',
        'QC Failed',
        'Aliquoted',
        'Library Preparation',
        'Sequenced',
        'Archived',
        'Disposed'
    ) DEFAULT 'Awaiting Receipt',

    FOREIGN KEY (submission_id)
        REFERENCES Submission(submission_id)
);

CREATE TABLE Aliquot (
    aliquot_id INT AUTO_INCREMENT PRIMARY KEY,

    sample_id INT NOT NULL,

    volume DECIMAL(10,2),
    volume_unit VARCHAR(20),

    concentration DECIMAL(10,2),
    concentration_unit VARCHAR(20),

    status ENUM(
        'Available',
        'Reserved',
        'In Use',
        'Consumed',
        'Discarded'
    ) DEFAULT 'Available',

    created_date DATETIME,

    FOREIGN KEY (sample_id)
        REFERENCES Sample(sample_id)
);

CREATE TABLE StorageLocation (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    building VARCHAR(100),
    room VARCHAR(100),
    freezer VARCHAR(100),
    shelf VARCHAR(50),
    rack VARCHAR(50),
    drawer VARCHAR(50),
    position VARCHAR(50)
);

CREATE TABLE SampleLocationHistory (
    history_id INT AUTO_INCREMENT PRIMARY KEY,
    aliquot_id INT NOT NULL,
    location_id INT NOT NULL,
    date_in DATETIME,
    date_out DATETIME,
    moved_by INT,

    FOREIGN KEY (aliquot_id)
        REFERENCES Aliquot(aliquot_id),

    FOREIGN KEY (location_id)
        REFERENCES StorageLocation(location_id),

    FOREIGN KEY (moved_by)
        REFERENCES User(user_id)
);

CREATE TABLE Equipment (
    equipment_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    manufacturer VARCHAR(255),
    model VARCHAR(255),
    serial_number VARCHAR(255),

    status ENUM(
        'Available',
        'In Use',
        'Reserved',
        'Maintenance',
        'Out of Service'
    ) DEFAULT 'Available',

    calibration_due DATE,
    location VARCHAR(255)
);

CREATE TABLE Library (
    library_id INT AUTO_INCREMENT PRIMARY KEY,
    aliquot_id INT NOT NULL,

    library_type ENUM(
        'WGS',
        'WES',
        'RNA-seq',
        'scRNA-seq',
        'ATAC-seq',
        'ChIP-seq',
        'Amplicon',
        'Metagenomics',
        'Other'
    ) NOT NULL,

    barcode VARCHAR(100),
    index1 VARCHAR(100),
    index2 VARCHAR(100),
    concentration DECIMAL(10,2),
    fragment_size_min INT,
    fragment_size_max INT,

    status ENUM(
        'Created',
        'QC Pending',
        'QC Passed',
        'QC Failed',
        'Pooled',
        'Sequenced',
        'Archived'
    ) DEFAULT 'Created',

    FOREIGN KEY (aliquot_id)
        REFERENCES Aliquot(aliquot_id)
);

CREATE TABLE QCResult (
    qc_id INT AUTO_INCREMENT PRIMARY KEY,
    library_id INT NOT NULL,
    equipment_id INT,
    metric_name VARCHAR(255),
    metric_value VARCHAR(255),
    unit VARCHAR(50),
		
    status ENUM(
        'Pending',
        'Pass',
        'Fail'
    ) DEFAULT 'Pending',
		
		date DATETIME,

    FOREIGN KEY (library_id)
        REFERENCES Library(library_id),

    FOREIGN KEY (equipment_id)
        REFERENCES Equipment(equipment_id)
);

CREATE TABLE Pool (
    pool_id INT AUTO_INCREMENT PRIMARY KEY,
    pool_name VARCHAR(255),
    creation_date DATETIME
);

CREATE TABLE PoolLibrary (
    pool_id INT NOT NULL,
    library_id INT NOT NULL,
    description TEXT,

    PRIMARY KEY (pool_id, library_id),

    FOREIGN KEY (pool_id)
        REFERENCES Pool(pool_id)
        ON DELETE CASCADE,

    FOREIGN KEY (library_id)
        REFERENCES Library(library_id)
        ON DELETE CASCADE
);

CREATE TABLE SequencingRun (
    run_id INT AUTO_INCREMENT PRIMARY KEY,
    pool_id INT NOT NULL,
    run_name VARCHAR(255),
    equipment_id INT,
    run_date DATETIME,

    status ENUM(
        'Scheduled',
        'Preparing',
        'Running',
        'Completed',
        'Failed',
        'Cancelled',
        'Archived'
    ) DEFAULT 'Scheduled',

    operator INT,

    FOREIGN KEY (pool_id)
        REFERENCES Pool(pool_id),

    FOREIGN KEY (equipment_id)
        REFERENCES Equipment(equipment_id),

    FOREIGN KEY (operator)
        REFERENCES User(user_id)
);

CREATE TABLE DataFile (
    file_id INT AUTO_INCREMENT PRIMARY KEY,
    run_id INT NOT NULL,
    file_type VARCHAR(100),
    file_path VARCHAR(1000),
    created_date DATETIME,
    created_by INT,

    FOREIGN KEY (run_id)
        REFERENCES SequencingRun(run_id),

    FOREIGN KEY (created_by)
        REFERENCES User(user_id)
);