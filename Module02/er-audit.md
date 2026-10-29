# Module 2 — ER Audit

## 1. Entities and attributes

### Machine

* Attributes: machine_name, serial_no, site, installed
* Intended primary key: machine_name (or preferably a generated machine_id)
* Defects: no primary key or NOT NULL constraints; installed is free text.

### Part

* Attributes: part_no, description, unit_price
* Intended primary key: part_no
* Defects: part_no is not unique; unit_price is stored as text.

### MaintenanceJob

* Attributes: job_id, machine_name, technician, done_on, parts_used
* Intended primary key: job_id
* Defects: no primary key; machine_name is not a foreign key; parts_used contains a comma-separated list.

### Technician

* Attributes: technician_id, technician_name
* Intended primary key: technician_id
* Intended relationship: one technician can perform many maintenance jobs.

## 2. Intended relationships and cardinalities

* Machine to MaintenanceJob: one machine can have many maintenance jobs; each job should belong to one machine (1:n).
* Technician to MaintenanceJob: one technician can perform many jobs; each job should be assigned to one technician (1:n).
* MaintenanceJob to Part: a job can use many parts, and a part can be used in many jobs (m:n). This should be implemented using a junction table such as job_part.
* 1:1: no clear 1:1 relationship is represented in the supplied data or schema.

## 3. Cardinality evidence

The actual counts and query outputs will be recorded below after executing the queries.

## 4. Integrity defects

The five defect queries, their actual outputs, and their production impacts will be recorded in the accompanying evidence.


