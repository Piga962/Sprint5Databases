# Database Migration Project - Students Table Creation

## Project Overview
This project demonstrates a complete database migration workflow using Liquibase with Oracle Database. The goal is to add a new `students` table to an existing database schema following proper migration practices.

## Workflow Summary
1. **Schema Modification in Development** - Create table directly in database
2. **Liquibase Script Generation** - Convert changes to migration script
3. **Testing the Migration Script** - Drop and recreate using Liquibase
4. **Production Deployment** - Apply migration to production environment
5. **Documentation** - Update project documentation

---

## Step 1: Schema Modification in Development

### 1.1 Connect to Development Database
```bash
docker exec -it oracle-xe sqlplus dev_user/dev_password@localhost:1521/XE
```

### 1.2 Create Students Table Directly
```sql
-- Create the students table with all required fields
CREATE TABLE students (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    enrollment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add table and column comments for documentation
COMMENT ON TABLE students IS 'Table to store student information and enrollment data';
COMMENT ON COLUMN students.id IS 'Unique identifier for each student';
COMMENT ON COLUMN students.first_name IS 'Student first name';
COMMENT ON COLUMN students.last_name IS 'Student last name';
COMMENT ON COLUMN students.email IS 'Student email address, must be unique';
COMMENT ON COLUMN students.enrollment_date IS 'Date when student enrolled';

-- Verify table creation
DESC students;
SELECT table_name FROM user_tables WHERE table_name = 'STUDENTS';

EXIT;
```

### 1.3 Verify Table Structure
- Confirm the table was created successfully
- Document the exact structure and constraints
- Note any indexes automatically created by Oracle

---

## Step 2: Liquibase Script Generation

### 2.1 Create Migration Script File
Create file: `project/db-migrations/changelog/changesets/003-create-students-table.sql`

```sql
--liquibase formatted sql
--changeset yourname:003-create-students-table

-- Create students table for enrollment management
CREATE TABLE students (
    id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) NOT NULL UNIQUE,
    enrollment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add documentation comments
COMMENT ON TABLE students IS 'Table to store student information and enrollment data';
COMMENT ON COLUMN students.id IS 'Unique identifier for each student';
COMMENT ON COLUMN students.first_name IS 'Student first name';
COMMENT ON COLUMN students.last_name IS 'Student last name';
COMMENT ON COLUMN students.email IS 'Student email address, must be unique';
COMMENT ON COLUMN students.enrollment_date IS 'Date when student enrolled';
```

### 2.2 Update Master Changelog
Update `project/db-migrations/changelog/changelog.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.8.xsd">
    
    <changeSet id="001-initial-schema" author="yourname">
        <sqlFile path="project/db-migrations/changelog/changesets/001-initial-schema.sql"/>
    </changeSet>
    
    <changeSet id="002-add-users-table" author="yourname">
        <sqlFile path="project/db-migrations/changelog/changesets/002-add-users-table.sql"/>
    </changeSet>
    
    <!-- NEW CHANGESET FOR STUDENTS TABLE -->
    <changeSet id="003-create-students-table" author="yourname">
        <sqlFile path="project/db-migrations/changelog/changesets/003-create-students-table.sql"/>
    </changeSet>
    
</databaseChangeLog>
```

---

## Step 3: Testing the Migration Script

### 3.1 Drop the Manually Created Table
```bash
# Connect to development database
docker exec -it oracle-xe sqlplus dev_user/dev_password@localhost:1521/XE
```

```sql
-- Drop the manually created table
DROP TABLE students;

-- Verify table was dropped
SELECT table_name FROM user_tables WHERE table_name = 'STUDENTS';
-- Should return no rows

EXIT;
```

### 3.2 Apply Migration Using Liquibase
```bash
# Check current migration status
liquibase --defaultsFile=liquibase-dev.properties status

# Apply the new migration
liquibase --defaultsFile=liquibase-dev.properties update

# Verify migration was successful
liquibase --defaultsFile=liquibase-dev.properties status
```

### 3.3 Verify Table Recreation
```bash
# Connect to verify table structure
docker exec -it oracle-xe sqlplus dev_user/dev_password@localhost:1521/XE
```

```sql
-- Verify table exists
SELECT table_name FROM user_tables WHERE table_name = 'STUDENTS';

-- Check table structure matches requirements
DESC students;

-- Verify table is empty
SELECT COUNT(*) FROM students;

-- Check constraints
SELECT constraint_name, constraint_type, search_condition 
FROM user_constraints 
WHERE table_name = 'STUDENTS';

EXIT;
```

---

## Step 4: Production Deployment

### 4.1 Check Production Status
```bash
# Verify current state of production
liquibase --defaultsFile=liquibase-prod.properties status
```

### 4.2 Apply Migration to Production
```bash
# Apply all pending migrations to production
liquibase --defaultsFile=liquibase-prod.properties update

# Verify successful deployment
liquibase --defaultsFile=liquibase-prod.properties status
```

### 4.3 Verify Production Deployment
```bash
# Connect to production database
docker exec -it oracle-xe sqlplus prod_user/prod_password@localhost:1521/XE
```

```sql
-- Verify table exists in production
SELECT table_name FROM user_tables WHERE table_name = 'STUDENTS';

-- Check table structure
DESC students;

-- Verify table is empty
SELECT COUNT(*) FROM students;

EXIT;
```

---

## Step 5: Documentation and Verification

### 5.1 Required Screenshots
Capture the following evidence:

1. **Table Structure in Development**
   ```sql
   DESC students;
   ```

2. **Successful Migration Application in Development**
   ```bash
   liquibase --defaultsFile=liquibase-dev.properties status
   # Should show "is up to date"
   ```

3. **Successful Migration Application in Production**
   ```bash
   liquibase --defaultsFile=liquibase-prod.properties status
   # Should show "is up to date"
   ```

### 5.2 Final Verification Commands
```sql
-- Verify table exists in both environments
SELECT table_name FROM user_tables WHERE table_name = 'STUDENTS';

-- Check table structure
DESC students;

-- Verify constraints
SELECT constraint_name, constraint_type 
FROM user_constraints 
WHERE table_name = 'STUDENTS';

-- Confirm table is empty initially
SELECT COUNT(*) FROM students;
```

---

## Project Structure
```
DatabasesClass/
├── project/
│   └── db-migrations/
│       └── changelog/
│           ├── changelog.xml
│           └── changesets/
│               ├── 001-initial-schema.sql
│               ├── 002-add-users-table.sql
│               └── 003-create-students-table.sql ← NEW
├── liquibase-dev.properties
├── liquibase-prod.properties
└── README.md ← UPDATED
```

## Table Schema Details

### Students Table Structure
| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| `id` | NUMBER | PRIMARY KEY, AUTO-INCREMENT | Unique identifier |
| `first_name` | VARCHAR2(50) | NOT NULL | Student's first name |
| `last_name` | VARCHAR2(50) | NOT NULL | Student's last name |
| `email` | VARCHAR2(100) | NOT NULL, UNIQUE | Student's email address |
| `enrollment_date` | DATE | NOT NULL | Date of enrollment |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation timestamp |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record update timestamp |

### Constraints
- **Primary Key**: `id` column with auto-increment
- **Unique Constraint**: `email` column to prevent duplicate emails
- **Not Null Constraints**: All columns except timestamps

---

## Rollback Procedures

### Development Rollback
```bash
# Rollback last migration in development
liquibase --defaultsFile=liquibase-dev.properties rollback-count 1
```

### Production Rollback
```bash
# Rollback last migration in production (use with extreme caution)
liquibase --defaultsFile=liquibase-prod.properties rollback-count 1
```

**⚠️ Warning**: Rollback operations will DROP the students table and all its data.

---

## Dependencies and Considerations

### Prerequisites
- Oracle Database container running
- Liquibase properly configured
- Database users (dev_user, prod_user) created with appropriate permissions
- Existing schema with previous migrations applied

### Technical Notes
- Oracle automatically creates indexes for PRIMARY KEY and UNIQUE constraints
- `GENERATED BY DEFAULT AS IDENTITY` provides auto-increment functionality
- Email uniqueness prevents duplicate student registrations
- Timestamps track record creation and modification

### Best Practices Demonstrated
1. **Environment Separation**: Separate development and production databases
2. **Migration Testing**: Test in development before production deployment
3. **Version Control**: All schema changes tracked through Liquibase
4. **Documentation**: Comprehensive documentation of changes and procedures
5. **Rollback Planning**: Clear procedures for reversing changes if needed

---

## Troubleshooting

### Common Issues
1. **Checksum Mismatch**: Use `liquibase clear-checksums` if file contents change
2. **Connection Errors**: Verify Oracle container is running and users exist
3. **Constraint Violations**: Check for existing data that violates new constraints
4. **Permission Errors**: Ensure database users have necessary privileges

### Verification Commands
```bash
# Check Docker container status
docker ps

# Verify Liquibase configuration
liquibase --defaultsFile=liquibase-dev.properties validate

# Check database connectivity
docker exec -it oracle-xe sqlplus dev_user/dev_password@localhost:1521/XE
```

---
