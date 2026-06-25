# NGS LIMS

## 1. Intro

This is a Laboratory Information Management System (LIMS) built for NGS sequencing platforms.

It tracks everything from:
- client submission intake  
- submitted samples  
- aliquots and libraries  
- pooling and sequencing runs  
- QC results and output files  

In short, it helps a sequencing core lab keep track of **where every sample is, what has been done to it, and what data was generated**.

## 2. Environment

- Database: MySQL
- Design: Backend Database
- Focus: NGS workflow tracking; dataset download function for ML traning (WIP).

## 3. Main tables

### Organization layer
- `Organization`
- `Client`
- `Project`
- `Submission`
- `User`

### Wet lab sample tracking
- `Sample`
- `Aliquot`
- `StorageLocation`
- `SampleLocationHistory`

### Library + sequencing workflow
- `Library`
- `Pool`
- `PoolLibrary`
- `SequencingRun`
- `DataFile`

### QC + equipment
- `QCResult`
- `Equipment`

## 4. Table Relationships

```text
Organization
      ↓
Client
      ↓
Project
      ↓
Submission
      ↓
Sample
      ↓
Aliquot
      ↓
Library
      ↓
Pool
      ↓
Sequencing Run
      ↓
Data Files
```

### Key relationships

- **Client** belongs to one **Organization**
- **Project** belongs to one **Client** as the main contactors
- **Sample** belongs to one **Submission**
- **Sample** can generate multiple **Aliquots**
- **Aliquot** can be used to build a **Library**
- **QCResult** records quality control metrics for each library.
- Multiple **Libraries** can be pooled together with barcoding
- **Pool** is sequenced in a **SequencingRun**
- **SequencingRun** generates **DataFiles**

### Tracking

- **StorageLocation** and **SampleLocationHistory** track aliquot storage and movement.
- **User** records personnel responsible for laboratory operations.
