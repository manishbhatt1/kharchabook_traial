-- Migration: add due_date column to bill_reminders for older deployments
-- Run if you see a 500 error on /user/bills caused by missing due_date column.
-- Safe to run multiple times: the ADD COLUMN is skipped if it already exists.

USE kharchabook;

-- 1. Add the due_date column (skip if it already exists)
SET @db_name := DATABASE();
SELECT COUNT(*)
INTO @due_date_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = @db_name
  AND TABLE_NAME = 'bill_reminders'
  AND COLUMN_NAME = 'due_date';

SET @add_due_date_sql := IF(
    @due_date_exists = 0,
    'ALTER TABLE bill_reminders ADD COLUMN due_date DATE NULL AFTER amount',
    'SELECT ''bill_reminders.due_date already exists'' AS info'
);
PREPARE stmt FROM @add_due_date_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. Backfill due_date from due_day for existing rows.
--    Uses the current month and clamps to the last day of the month.
UPDATE bill_reminders
SET due_date = DATE(CONCAT(
        YEAR(CURDATE()), '-',
        LPAD(MONTH(CURDATE()), 2, '0'), '-',
        LPAD(LEAST(due_day, DAY(LAST_DAY(CURDATE()))), 2, '0')
    ))
WHERE due_date IS NULL;

-- 3. Enforce NOT NULL to match the latest schema
ALTER TABLE bill_reminders
    MODIFY COLUMN due_date DATE NOT NULL;
