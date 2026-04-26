-- Database initialization script for KharchaBook
-- Run this script to create missing tables for new features

-- Create fees table for fee reminder functionality
CREATE TABLE IF NOT EXISTS fees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    fee_name VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    due_date DATE NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, due_date),
    INDEX idx_user_status (user_id, status),
    INDEX idx_due_date (due_date)
);

-- Create remittance_allocations table for remittance allocation functionality
CREATE TABLE IF NOT EXISTS remittance_allocations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(15,2) NOT NULL,
    rent_amount DECIMAL(15,2) DEFAULT 0,
    food_amount DECIMAL(15,2) DEFAULT 0,
    savings_amount DECIMAL(15,2) DEFAULT 0,
    other_amount DECIMAL(15,2) DEFAULT 0,
    description TEXT,
    allocation_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_date (user_id, allocation_date),
    INDEX idx_user_status (user_id, status)
);

-- Insert sample data for testing (optional)
-- INSERT INTO fees (user_id, fee_name, amount, due_date, description) VALUES 
-- (1, 'School Fee', 5000.00, DATE_ADD(CURDATE(), INTERVAL 5 DAY), 'Monthly school tuition fee'),
-- (1, 'Hostel Fee', 3000.00, DATE_ADD(CURDATE(), INTERVAL 8 DAY), 'Monthly hostel accommodation');

-- INSERT INTO remittance_allocations (user_id, total_amount, rent_amount, food_amount, savings_amount, other_amount, allocation_date, description) VALUES 
-- (1, 25000.00, 8000.00, 6000.00, 7000.00, 4000.00, CURDATE(), 'Monthly remittance from Qatar');
