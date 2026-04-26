-- Create table for remittance allocations
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
