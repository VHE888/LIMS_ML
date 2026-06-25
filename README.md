# NGS LIMS

## 1. Intro

This is a Laboratory Information Management System (LIMS) built for NGS sequencing platforms.

It tracks everything from:
- client project intake  
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
- `User`

### Wet lab sample tracking
- `Sample`
- `Aliquot`
- `StorageLocation`
- `SampleLocationHistory`
- `SampleEvent`

### Library + sequencing workflow
- `Library`
- `Pool`
- `PoolLibrary`
- `SequencingRun`
- `DataFile`

### QC + equipment
- `QCResult`
- `Equipment`

## 4. Relations

### Key relationships

- A **Client** belongs to one Organization
- A **Project** belongs to one Client as the main contactors
- A **Sample** belongs to one Project
- A **Sample** can generate multiple **Aliquots**
- An **Aliquot** can be used to build a **Library**
- Multiple **Libraries** can be pooled together with barcoding
- A **Pool** is sequenced in a **SequencingRun**
- A **SequencingRun** generates **DataFiles**

### QC + tracking

- `QCResult` links to Library (and optionally Equipment)
- `SampleEvent` tracks what happened to an aliquot over time
- `SampleLocationHistory` tracks storage movement

## Notes

- Storage and event tables are added for traceability and lab management.
