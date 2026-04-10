-- Joshqun Todo App - MySQL Database Schema
-- Prepared for Future Synchronization

CREATE DATABASE IF NOT EXISTS joshqun_planner;
USE joshqun_planner;

CREATE TABLE IF NOT EXISTS fta_todos (
    id VARCHAR(50) PRIMARY KEY,          -- UUID from Flutter
    user_id VARCHAR(50) DEFAULT NULL,    -- Future User Authentication
    title VARCHAR(255) NOT NULL,
    description TEXT DEFAULT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    category VARCHAR(50) DEFAULT 'General',
    due_date DATETIME DEFAULT NULL,
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,    -- For Soft Deletes/Sync
    version INT DEFAULT 1,               -- For Conflict Resolution
    
    INDEX idx_user (user_id),
    INDEX idx_deleted (is_deleted),
    INDEX idx_updated (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample query to fetch items to sync (local has higher version or newer updatedAt)
-- SELECT * FROM fta_todos WHERE updated_at > ? AND user_id = ?;
