CREATE DATABASE fitness_tracker;
USE fitness_tracker;
show databases;

-- user table
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10),
    height FLOAT,
    weight FLOAT,
    current_bmi FLOAT,
    bmi_category VARCHAR(20)
);
 
-- Activity Table
CREATE TABLE activity (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    activity_date DATE DEFAULT (CURRENT_DATE),
    steps INT DEFAULT 0,
    calories_burned INT,
    distance FLOAT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
ALTER TABLE activity 
ADD goal_status VARCHAR(10) 
AS (CASE WHEN steps >= 10000 THEN 'Success' ELSE 'Pending' END);

-- workout table 
CREATE TABLE workout (
    workout_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    workout_type VARCHAR(50),
    duration INT,
    calories INT,
    workout_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- MEASUREMENT TABLE
CREATE TABLE measurement (
    measurement_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    measure_date DATE,
    weight FLOAT,
    body_fat FLOAT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- PLANS TABLE
CREATE TABLE plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(50),
    price DECIMAL(10,2),
    duration_days INT
);

-- subscriptions table
CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    plan_id INT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

-- PAYMENTS TABLE
CREATE TABLE payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    subscription_id INT,
    amount DECIMAL(10,2) NOT NULL,
    discount_applied DECIMAL(10,2) DEFAULT 0.00,
    payment_method VARCHAR(50),
    payment_date DATE DEFAULT (CURRENT_DATE),
    payment_status VARCHAR(20) DEFAULT 'Completed',
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE CASCADE
);

--  notifications table 
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    message VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- USER REWARDS TABLE
CREATE TABLE user_rewards (
    reward_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    credit_amount DECIMAL(10,2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- REFERRALS TABLE
 CREATE TABLE referrals (
    referral_id INT PRIMARY KEY AUTO_INCREMENT,
    referrer_id INT,
    referee_id INT,
    referral_date DATE DEFAULT (CURRENT_DATE),
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (referrer_id) REFERENCES users(user_id),
    FOREIGN KEY (referee_id) REFERENCES users(user_id)
);
-- diet table
CREATE TABLE diet (
    diet_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    diet_date DATE,
    calories INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE sleep (
    sleep_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    sleep_date DATE,
    duration FLOAT,
    quality VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);