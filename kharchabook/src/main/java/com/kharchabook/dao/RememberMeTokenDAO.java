package com.kharchabook.dao;

import com.kharchabook.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

public class RememberMeTokenDAO {

    public void upsert(int userId, String selector, String tokenHash, LocalDateTime expiresAt) throws SQLException {
        String sql = "INSERT INTO remember_tokens (user_id, selector, token_hash, expires_at) VALUES (?,?,?,?)";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, selector);
            ps.setString(3, tokenHash);
            ps.setTimestamp(4, Timestamp.valueOf(expiresAt));
            ps.executeUpdate();
        }
    }

    public TokenRecord findBySelector(String selector) throws SQLException {
        String sql = "SELECT id, user_id, token_hash, expires_at FROM remember_tokens WHERE selector = ? LIMIT 1";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, selector);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TokenRecord tr = new TokenRecord();
                    tr.id = rs.getInt("id");
                    tr.userId = rs.getInt("user_id");
                    tr.tokenHash = rs.getString("token_hash");
                    Timestamp ts = rs.getTimestamp("expires_at");
                    tr.expiresAt = ts == null ? null : ts.toLocalDateTime();
                    return tr;
                }
            }
        }
        return null;
    }

    public void updateTokenHashAndExpiry(int id, String tokenHash, LocalDateTime expiresAt) throws SQLException {
        String sql = "UPDATE remember_tokens SET token_hash = ?, expires_at = ? WHERE id = ?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ps.setTimestamp(2, Timestamp.valueOf(expiresAt));
            ps.setInt(3, id);
            ps.executeUpdate();
        }
    }

    public void deleteBySelector(String selector) throws SQLException {
        String sql = "DELETE FROM remember_tokens WHERE selector = ?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, selector);
            ps.executeUpdate();
        }
    }

    public void deleteAllForUser(int userId) throws SQLException {
        String sql = "DELETE FROM remember_tokens WHERE user_id = ?";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public void deleteExpired() throws SQLException {
        String sql = "DELETE FROM remember_tokens WHERE expires_at < NOW()";
        try (Connection c = DBUtil.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.executeUpdate();
        }
    }

    public static final class TokenRecord {
        public int id;
        public int userId;
        public String tokenHash;
        public LocalDateTime expiresAt;
    }
}

