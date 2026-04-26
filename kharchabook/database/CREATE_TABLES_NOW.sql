-- COPY AND PASTE THESE COMMANDS INTO YOUR MYSQL CLIENT
-- =====================================================

-- Create fees table
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

-- Create remittance_allocations table
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

-- Verify tables were created
SHOW TABLES LIKE 'fees';
SHOW TABLES LIKE 'remittance_allocations';

-- If successful, you should see:
-- +-------------------+
-- | Tables_in_kharchabook (fees%) |
-- +-------------------+
-- | fees              |
-- +-------------------+
-- +----------------------------+
-- | Tables_in_kharchabook (remittance_allocations%) |
-- +----------------------------+
-- | remittance_allocations     |
-- +----------------------------+
