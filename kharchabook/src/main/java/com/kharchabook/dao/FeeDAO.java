package com.kharchabook.dao;

import com.kharchabook.model.Fee;
import com.kharchabook.util.DBUtil;

import java.sql.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class FeeDAO {
    
    public void insert(Fee fee) throws SQLException {
        String sql = "INSERT INTO fees (user_id, fee_name, amount, due_date, description, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, fee.getUserId());
            stmt.setString(2, fee.getFeeName());
            stmt.setBigDecimal(3, fee.getAmount());
            stmt.setDate(4, fee.getDueDate() != null ? Date.valueOf(fee.getDueDate()) : null);
            stmt.setString(5, fee.getDescription());
            stmt.setString(6, fee.getStatus());
            stmt.setTimestamp(7, fee.getCreatedAt() != null ? Timestamp.valueOf(fee.getCreatedAt()) : Timestamp.valueOf(LocalDateTime.now()));
            stmt.setTimestamp(8, fee.getUpdatedAt() != null ? Timestamp.valueOf(fee.getUpdatedAt()) : Timestamp.valueOf(LocalDateTime.now()));
            
            stmt.executeUpdate();
            
            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    fee.setId(generatedKeys.getInt(1));
                }
            }
        }
    }
    
    public void update(Fee fee) throws SQLException {
        String sql = "UPDATE fees SET fee_name = ?, amount = ?, due_date = ?, description = ?, status = ?, updated_at = ? WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, fee.getFeeName());
            stmt.setBigDecimal(2, fee.getAmount());
            stmt.setDate(3, fee.getDueDate() != null ? Date.valueOf(fee.getDueDate()) : null);
            stmt.setString(4, fee.getDescription());
            stmt.setString(5, fee.getStatus());
            stmt.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            stmt.setInt(7, fee.getId());
            stmt.setInt(8, fee.getUserId());
            
            stmt.executeUpdate();
        }
    }
    
    public void delete(int id, int userId) throws SQLException {
        String sql = "DELETE FROM fees WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        }
    }
    
    public Fee findById(int id, int userId) throws SQLException {
        String sql = "SELECT * FROM fees WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            stmt.setInt(2, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFee(rs);
                }
            }
        }
        return null;
    }
    
    public List<Fee> findByUser(int userId) throws SQLException {
        String sql = "SELECT * FROM fees WHERE user_id = ? ORDER BY due_date ASC";
        List<Fee> fees = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    fees.add(mapResultSetToFee(rs));
                }
            }
        }
        return fees;
    }
    
    public List<Fee> findDueSoon(int userId, LocalDate currentDate, LocalDate thresholdDate) throws SQLException {
        String sql = "SELECT * FROM fees WHERE user_id = ? AND status = 'active' AND due_date >= ? AND due_date <= ? ORDER BY due_date ASC";
        List<Fee> fees = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setDate(2, Date.valueOf(currentDate));
            stmt.setDate(3, Date.valueOf(thresholdDate));
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Fee fee = mapResultSetToFee(rs);
                    // Calculate days until due
                    if (fee.getDueDate() != null) {
                        long daysUntil = java.time.temporal.ChronoUnit.DAYS.between(currentDate, fee.getDueDate());
                        fee.setDaysUntilDue(daysUntil);
                        fee.setOverdue(daysUntil < 0);
                    }
                    fees.add(fee);
                }
            }
        }
        return fees;
    }
    
    public List<Fee> findCriticalFees(int userId, LocalDate currentDate, int daysThreshold) throws SQLException {
        LocalDate thresholdDate = currentDate.plusDays(daysThreshold);
        return findDueSoon(userId, currentDate, thresholdDate);
    }
    
    public BigDecimal sumUpcomingFees(int userId, LocalDate currentDate, LocalDate endDate) throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount), 0) as total FROM fees WHERE user_id = ? AND status = 'active' AND due_date >= ? AND due_date <= ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userId);
            stmt.setDate(2, Date.valueOf(currentDate));
            stmt.setDate(3, Date.valueOf(endDate));
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getBigDecimal("total");
                }
            }
        }
        return BigDecimal.ZERO;
    }
    
    public void markAsPaid(int id, int userId) throws SQLException {
        String sql = "UPDATE fees SET status = 'paid', updated_at = ? WHERE id = ? AND user_id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setTimestamp(1, Timestamp.valueOf(LocalDateTime.now()));
            stmt.setInt(2, id);
            stmt.setInt(3, userId);
            
            stmt.executeUpdate();
        }
    }
    
    private Fee mapResultSetToFee(ResultSet rs) throws SQLException {
        Fee fee = new Fee();
        fee.setId(rs.getInt("id"));
        fee.setUserId(rs.getInt("user_id"));
        fee.setFeeName(rs.getString("fee_name"));
        fee.setAmount(rs.getBigDecimal("amount"));
        
        Date dueDate = rs.getDate("due_date");
        if (dueDate != null) {
            fee.setDueDate(dueDate.toLocalDate());
        }
        
        fee.setDescription(rs.getString("description"));
        fee.setStatus(rs.getString("status"));
        
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            fee.setCreatedAt(createdAt.toLocalDateTime());
        }
        
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            fee.setUpdatedAt(updatedAt.toLocalDateTime());
        }
        
        return fee;
    }
}
