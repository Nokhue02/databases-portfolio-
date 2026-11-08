CREATE TABLE flat5 (
    job_id INTEGER,
    machine_id TEXT,
    site TEXT,
    technician TEXT,
    part_no TEXT,
    part_price REAL
);

INSERT INTO flat5 VALUES
(1,'cnc-01','Gütersloh','tech-0','P-0001',6.00),
(1,'cnc-01','Gütersloh','tech-0','P-0002',7.00),
(2,'cnc-02','Gütersloh','tech-1','P-0001',6.00),
(2,'cnc-02','Gütersloh','tech-1','P-0003',8.50),
(3,'cnc-01','Gütersloh','tech-0','P-0003',8.50);

SELECT * FROM flat5;

╭────────┬────────────┬───────────┬────────────┬─────────┬────────────╮
│ job_id │ machine_id │   site    │ technician │ part_no │ part_price │
╞════════╪════════════╪═══════════╪════════════╪═════════╪════════════╡
│      1 │ cnc-01     │ Gütersloh │ tech-0     │ P-0001  │        6.0 │
│      1 │ cnc-01     │ Gütersloh │ tech-0     │ P-0002  │        7.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0001  │        6.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0003  │        8.5 │
│      3 │ cnc-01     │ Gütersloh │ tech-0     │ P-0003  │        8.5 │
╰────────┴────────────┴───────────┴────────────┴─────────┴────────────╯

UPDATE flat5
SET site = 'Bielefeld'
WHERE job_id = 1 AND part_no = 'P-0001';

│ job_id │ machine_id │   site    │ technician │ part_no │ part_price │
╞════════╪════════════╪═══════════╪════════════╪═════════╪════════════╡
│      1 │ cnc-01     │ Bielefeld │ tech-0     │ P-0001  │        6.0 │
│      1 │ cnc-01     │ Gütersloh │ tech-0     │ P-0002  │        7.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0001  │        6.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0003  │        8.5 │
│      3 │ cnc-01     │ Gütersloh │ tech-0     │ P-0003  │        8.5 │
╰────────┴────────────┴───────────┴────────────┴─────────┴────────────╯ This caused the same machine to  have two different sites, which is an anomaly. 

UPDATE flat5
SET site = 'Bielefeld'
WHERE machine_id = 'cnc-01';

╭────────┬────────────┬───────────┬────────────┬─────────┬────────────╮
│ job_id │ machine_id │   site    │ technician │ part_no │ part_price │
╞════════╪════════════╪═══════════╪════════════╪═════════╪════════════╡
│      1 │ cnc-01     │ Bielefeld │ tech-0     │ P-0001  │        6.0 │
│      1 │ cnc-01     │ Bielefeld │ tech-0     │ P-0002  │        7.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0001  │        6.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0003  │        8.5 │
│      3 │ cnc-01     │ Bielefeld │ tech-0     │ P-0003  │        8.5 │
╰────────┴────────────┴───────────┴────────────┴─────────┴────────────╯ This fixed the anomaly, 


INSERT INTO flat5
(part_no, part_price)
VALUES ('P-0004', 10.00);

╭────────┬────────────┬───────────┬────────────┬─────────┬────────────╮
│ job_id │ machine_id │   site    │ technician │ part_no │ part_price │
╞════════╪════════════╪═══════════╪════════════╪═════════╪════════════╡
│      1 │ cnc-01     │ Bielefeld │ tech-0     │ P-0001  │        6.0 │
│      1 │ cnc-01     │ Bielefeld │ tech-0     │ P-0002  │        7.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0001  │        6.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0003  │        8.5 │
│      3 │ cnc-01     │ Bielefeld │ tech-0     │ P-0003  │        8.5 │
│ NULL   │ NULL       │ NULL      │ NULL       │ P-0004  │       10.0 │
╰────────┴────────────┴───────────┴────────────┴─────────┴────────────╯  This is the insert anomaly: the table design mixes part information with job information.

DELETE FROM flat5
WHERE job_id = 1
AND part_no = 'P-0002';

SELECT * FROM flat5
WHERE part_no = 'P-0002';

╭────────┬────────────┬───────────┬────────────┬─────────┬────────────╮
│ job_id │ machine_id │   site    │ technician │ part_no │ part_price │
╞════════╪════════════╪═══════════╪════════════╪═════════╪════════════╡
│      1 │ cnc-01     │ Bielefeld │ tech-0     │ P-0001  │        6.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0001  │        6.0 │
│      2 │ cnc-02     │ Gütersloh │ tech-1     │ P-0003  │        8.5 │
│      3 │ cnc-01     │ Bielefeld │ tech-0     │ P-0003  │        8.5 │
│ NULL   │ NULL       │ NULL      │ NULL       │ P-0004  │       10.0 │
────────┴────────────┴───────────┴────────────┴─────────┴────────────╯Deleting an anomaly.

UPDATE flat5
SET site = 'Gütersloh'
WHERE job_id = 1
AND part_no = 'P-0001';

SELECT job_id, machine_id, site
FROM flat5
WHERE machine_id = 'cnc-01';

╭────────┬────────────┬───────────╮
│ job_id │ machine_id │   site    │
╞════════╪════════════╪═══════════╡
│      1 │ cnc-01     │ Gütersloh │
│      3 │ cnc-01     │ Bielefeld │
╰────────┴────────────┴───────────╯Updating an anomaly
