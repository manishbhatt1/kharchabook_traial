@echo off
echo Creating missing database tables for KharchaBook...
echo.

echo Connecting to MySQL and creating tables...
mysql -u root -pNewPassword123 -h localhost -P 3306 kharchabook < "database/create_missing_tables.sql"

echo.
echo If no errors appeared above, tables should be created successfully.
echo You can now restart your application and the fee reminder functionality should work.
pause
