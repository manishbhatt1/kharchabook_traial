@echo off
echo Running database setup for KharchaBook...
echo.

REM Try to find and run Maven
where mvn >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Maven found, running database setup...
    mvn exec:java -Dexec.mainClass="com.kharchabook.util.DatabaseSetup"
) else (
    echo Maven not found in PATH.
    echo Please run this command manually from your terminal:
    echo mvn exec:java -Dexec.mainClass="com.kharchabook.util.DatabaseSetup"
    echo.
    echo Or run the SQL commands directly in your MySQL client:
    echo.
    echo CREATE TABLE IF NOT EXISTS fees (
    echo     id INT AUTO_INCREMENT PRIMARY KEY,
    echo     user_id INT NOT NULL,
    echo     fee_name VARCHAR(100) NOT NULL,
    echo     amount DECIMAL(15,2) NOT NULL,
    echo     due_date DATE NOT NULL,
    echo     description TEXT,
    echo     status VARCHAR(20) DEFAULT 'active',
    echo     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    echo     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    echo     FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    echo );
    echo.
    echo CREATE TABLE IF NOT EXISTS remittance_allocations (
    echo     id INT AUTO_INCREMENT PRIMARY KEY,
    echo     user_id INT NOT NULL,
    echo     total_amount DECIMAL(15,2) NOT NULL,
    echo     rent_amount DECIMAL(15,2) DEFAULT 0,
    echo     food_amount DECIMAL(15,2) DEFAULT 0,
    echo     savings_amount DECIMAL(15,2) DEFAULT 0,
    echo     other_amount DECIMAL(15,2) DEFAULT 0,
    echo     description TEXT,
    echo     allocation_date DATE NOT NULL,
    echo     status VARCHAR(20) DEFAULT 'active',
    echo     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    echo     FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    echo );
)

pause
