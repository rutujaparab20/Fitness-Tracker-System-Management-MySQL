USE fitness_tracker;

-- =========================================
-- OBJECTIVE 1: Managing Fitness Data Efficiently
-- =========================================

-- ✅ 1. INSERT OPERATION
INSERT INTO users (name, age, gender, height, weight)
VALUES ('Test User', 26, 'Male', 170, 65);

-- Check Insert
SELECT * FROM users WHERE name = 'Test User';

-- ✅ 2. UPDATE OPERATION
UPDATE users
SET weight = 68
WHERE user_id = 21;


-- Check Update
SELECT * FROM users WHERE user_id = '21';

-- ✅ 3. DELETE OPERATION
DELETE FROM users
WHERE user_id = '21';

-- Check Delete
SELECT * FROM users WHERE user_id = '21';

-- ✅ 4. EXTRA CHECK (Optional for demo)
SELECT name, weight
FROM users
WHERE weight > 70;

SHOW COLUMNS FROM users;

-- =========================================
-- OBJECTIVE 2: Connecting Health Information
-- =========================================

-- ✅ 1. Combine User Profiles with Subscribed Plans
SELECT
u.name,
p.plan_name,
s.end_date
FROM users u
JOIN subscriptions s ON u.user_id = s.user_id
JOIN plans p ON s.plan_id = p.plan_id;

-- ✅ 2. Calories Burned vs Consumed Today
SELECT
u.name,
COALESCE(SUM(a.calories_burned), 0) AS daily_burned,
COALESCE(SUM(d.calories), 0) AS daily_consumed
FROM users u
LEFT JOIN activity a
ON u.user_id = a.user_id
AND a.activity_date = CURDATE()
LEFT JOIN diet d
ON u.user_id = d.user_id
AND d.diet_date = CURDATE()
GROUP BY u.name;

-- ✅ 3. Identify Inactive Users
SELECT u.name
FROM users u
LEFT JOIN activity a
ON u.user_id = a.user_id
WHERE a.activity_id IS NULL;


-- =========================================
-- OBJECTIVE 3: Automating Fitness Workflows
-- =========================================

-- Stored Procedure to Log Workout and Auto-Calculate Calories

DELIMITER //

CREATE PROCEDURE LogWorkout(
IN p_user_id INT,
IN p_type VARCHAR(50),
IN p_duration INT
)
BEGIN
-- Assume 10 calories per minute
INSERT INTO workout (user_id, workout_type, duration, calories, workout_date)
VALUES (p_user_id, p_type, p_duration, (p_duration * 10), CURDATE());
END //

DELIMITER ;

-- Usage
CALL LogWorkout(1, 'Running', 30);

-- Check Output
SELECT * FROM workout WHERE user_id = 1;

-- =========================================
-- OBJECTIVE 4: Trigger to Auto-Update User Weight
-- =========================================

DELIMITER //

CREATE TRIGGER UpdateCurrentWeight
AFTER INSERT ON measurement
FOR EACH ROW
BEGIN
UPDATE users
SET weight = NEW.weight
WHERE user_id = NEW.user_id;
END //

DELIMITER ;

-- =========================
-- TEST THE TRIGGER
-- =========================

-- Insert new measurement
INSERT INTO measurement (user_id, measure_date, weight, body_fat)
VALUES (1, CURDATE(), 68.0, 15.2);

-- Check if users table updated automatically
SELECT user_id, name, weight
FROM users
WHERE user_id = 1;

-- =========================================
-- OBJECTIVE 5: BMI Calculation Trigger
-- =========================================

DELIMITER //

CREATE TRIGGER UpdateUserHealthProfile
AFTER INSERT ON measurement
FOR EACH ROW
BEGIN
DECLARE user_height_cm FLOAT;

-- Get user height
SELECT height INTO user_height_cm 
FROM users 
WHERE user_id = NEW.user_id;

-- Update weight and BMI
UPDATE users 
SET weight = NEW.weight,
    current_bmi = NEW.weight / ((user_height_cm / 100) * (user_height_cm / 100))
WHERE user_id = NEW.user_id;
END //

DELIMITER ;

-- =========================
-- TEST THE TRIGGER
-- =========================

INSERT INTO measurement (user_id, measure_date, weight, body_fat)
VALUES (2, CURDATE(), 60.0, 20.0);

-- Check result
SELECT name, weight, current_bmi
FROM users
WHERE user_id = 2;

-- =========================================
-- OBJECTIVE 6: BMI CATEGORY CLASSIFICATION
-- =========================================

-- Drop old trigger first (important)
DROP TRIGGER IF EXISTS UpdateUserHealthProfile;

DELIMITER //

CREATE TRIGGER UpdateUserHealthProfile
AFTER INSERT ON measurement
FOR EACH ROW
BEGIN
DECLARE v_height_m FLOAT;
DECLARE v_bmi FLOAT;
DECLARE v_category VARCHAR(20);

-- Convert height to meters
SELECT (height / 100) INTO v_height_m 
FROM users 
WHERE user_id = NEW.user_id;

-- Calculate BMI
SET v_bmi = NEW.weight / (v_height_m * v_height_m);

-- Assign category
SET v_category = CASE 
    WHEN v_bmi < 18.5 THEN 'Underweight'
    WHEN v_bmi BETWEEN 18.5 AND 24.9 THEN 'Healthy Weight'
    WHEN v_bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
    WHEN v_bmi >= 30 THEN 'Obese'
    ELSE 'Unknown'
END;

-- Update users table
UPDATE users 
SET weight = NEW.weight,
    current_bmi = v_bmi,
    bmi_category = v_category
WHERE user_id = NEW.user_id;

END //

DELIMITER ;

-- =========================
-- TEST THE TRIGGER
-- =========================

INSERT INTO measurement (user_id, measure_date, weight, body_fat)
VALUES (2, CURDATE(), 75.0, 25.0);

-- Check result
SELECT name, weight, current_bmi, bmi_category
FROM users
WHERE user_id = 2;

-- =========================================
-- OBJECTIVE 7: Sleep Alert Trigger
-- =========================================

-- Drop old trigger if exists
DROP TRIGGER IF EXISTS CheckSleepDeprivation;

DELIMITER //

CREATE TRIGGER CheckSleepDeprivation
AFTER INSERT ON sleep
FOR EACH ROW
BEGIN
DECLARE low_sleep_count INT;

-- Count last 3 sleep records (< 6 hours)
SELECT COUNT(*) INTO low_sleep_count
FROM (
    SELECT duration
    FROM sleep
    WHERE user_id = NEW.user_id
    ORDER BY sleep_date DESC
    LIMIT 3
) AS recent_sleep
WHERE duration < 6;

-- If all 3 days are < 6 hours → insert notification
IF low_sleep_count = 3 THEN
    INSERT INTO notifications (user_id, message)
    VALUES (
        NEW.user_id,
        'Alert: You slept less than 6 hours for 3 consecutive days!'
    );
END IF;
END //

DELIMITER ;

-- =========================
-- TEST THE TRIGGER
-- =========================

-- Insert 3 days low sleep
INSERT INTO sleep (user_id, sleep_date, duration, quality)
VALUES (1, '2024-01-01', 5.5, 'Poor');

INSERT INTO sleep (user_id, sleep_date, duration, quality)
VALUES (1, '2024-01-02', 5.0, 'Poor');

INSERT INTO sleep (user_id, sleep_date, duration, quality)
VALUES (1, '2024-01-03', 4.5, 'Poor');

-- Check notification
SELECT * FROM notifications WHERE user_id = 1;

-- =========================================
-- OBJECTIVE 8: AUTO EXPIRY EVENT
-- =========================================

CREATE EVENT IF NOT EXISTS Auto_Expiry_Check
ON SCHEDULE EVERY 1 HOUR
DO
UPDATE subscriptions
SET status = 'Inactive'
WHERE status = 'Active'
AND end_date < CURDATE();

-- =========================================
-- OBJECTIVE 8: AUTO RENEWAL PROCEDURE
-- =========================================

DELIMITER //

CREATE PROCEDURE ProcessAutoRenewal(IN p_user_id INT)
BEGIN
DECLARE v_plan_days INT;

-- Get plan duration
SELECT p.duration_days INTO v_plan_days
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.user_id = p_user_id AND s.status = 'Active'
LIMIT 1;

-- Extend subscription
UPDATE subscriptions
SET end_date = DATE_ADD(end_date, INTERVAL v_plan_days DAY)
WHERE user_id = p_user_id AND status = 'Active';

-- Insert payment record
INSERT INTO payments (subscription_id, amount, payment_method, payment_date, payment_status)
SELECT 
    s.subscription_id,
    p.price,
    'Auto-Pay',
    CURDATE(),
    'Completed'
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE s.user_id = p_user_id AND s.status = 'Active'
LIMIT 1;

END //

DELIMITER ;

-- =========================
-- TEST PROCEDURE
-- =========================

CALL ProcessAutoRenewal(1);

-- Check results
SELECT * FROM subscriptions WHERE user_id = 1;
SELECT * FROM payments WHERE subscription_id = 1;


-- =========================================
-- OBJECTIVE 9: REFERRAL TRIGGER + PROCEDURE
-- =========================================

-- ✅ TRIGGER (Auto Reward)
DROP TRIGGER IF EXISTS GrantReferralReward;

DELIMITER //

CREATE TRIGGER GrantReferralReward
AFTER INSERT ON subscriptions
FOR EACH ROW
BEGIN
DECLARE v_referrer_id INT;

```
-- Check if user was referred
SELECT referrer_id INTO v_referrer_id
FROM referrals
WHERE referee_id = NEW.user_id
AND status = 'Pending'
LIMIT 1;

-- If referral exists → give reward
IF v_referrer_id IS NOT NULL THEN

    INSERT INTO user_rewards (user_id, credit_amount)
    VALUES (v_referrer_id, 100.00)
    ON DUPLICATE KEY UPDATE 
        credit_amount = credit_amount + 100.00;

    -- Mark referral as completed
    UPDATE referrals 
    SET status = 'Completed'
    WHERE referee_id = NEW.user_id;

END IF;
```

END //

DELIMITER ;

-- =========================================
-- STORED PROCEDURE: PURCHASE WITH DISCOUNT
-- =========================================

DELIMITER //

CREATE PROCEDURE PurchasePlanWithDiscount(
IN p_user_id INT,
IN p_plan_id INT
)
BEGIN
DECLARE v_price DECIMAL(10,2);
DECLARE v_discount DECIMAL(10,2) DEFAULT 0;
DECLARE v_final DECIMAL(10,2);

-- Get plan price
SELECT price INTO v_price FROM plans WHERE plan_id = p_plan_id;

-- Get reward balance
SELECT COALESCE(credit_amount,0) INTO v_discount
FROM user_rewards WHERE user_id = p_user_id;

-- Calculate final price
SET v_final = GREATEST(v_price - v_discount, 0);

-- Create subscription
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status)
VALUES (p_user_id, p_plan_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'Active');

-- Deduct reward
UPDATE user_rewards
SET credit_amount = GREATEST(credit_amount - v_price, 0)
WHERE user_id = p_user_id;

-- Show result
SELECT v_price AS Original_Price, 
       v_discount AS Discount, 
       v_final AS Final_Price;

END //

DELIMITER ;

-- =========================================
-- TEST
-- =========================================

-- Add referral
INSERT INTO referrals (referrer_id, referee_id)
VALUES (1, 2);

-- New subscription (trigger runs)
INSERT INTO subscriptions (user_id, plan_id, start_date, end_date)
VALUES (2, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY));

-- Check reward
SELECT * FROM user_rewards WHERE user_id = 1;

-- =========================================
-- OBJECTIVE 10: LEADERBOARD VIEW
-- =========================================

CREATE OR REPLACE VIEW Monthly_Fitness_Leaderboard AS
SELECT
DENSE_RANK() OVER (
ORDER BY (SUM(a.steps) * 0.1 + SUM(a.calories_burned) * 0.5) DESC
) AS rank_position,

u.name AS user_name,
SUM(a.steps) AS total_steps,
SUM(a.calories_burned) AS total_calories,

-- Fitness Score
ROUND(SUM(a.steps) * 0.1 + SUM(a.calories_burned) * 0.5, 0) AS fitness_score

FROM users u
JOIN activity a ON u.user_id = a.user_id
WHERE a.activity_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY u.user_id, u.name;

-- =========================
-- VIEW TOP USERS
-- =========================

SELECT * FROM Monthly_Fitness_Leaderboard
LIMIT 10;

-- =========================================
-- OBJECTIVE 11: WEEKLY HEALTH REPORT
-- =========================================

DELIMITER //

CREATE PROCEDURE GenerateWeeklyHealthReport(IN p_user_id INT)
BEGIN

-- =========================
-- 1. Summary (Activity + Sleep + Weight)
-- =========================

SELECT 
    u.name AS user_name,
    ROUND(AVG(a.steps), 0) AS avg_weekly_steps,
    ROUND(SUM(a.calories_burned), 0) AS total_calories_burned,
    ROUND(AVG(s.duration), 1) AS avg_sleep_hours,

    -- Weight Change (latest - 7 days ago)
    (
        SELECT weight FROM measurement 
        WHERE user_id = p_user_id 
        ORDER BY measure_date DESC LIMIT 1
    ) -
    (
        SELECT weight FROM measurement 
        WHERE user_id = p_user_id 
        AND measure_date <= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
        ORDER BY measure_date DESC LIMIT 1
    ) AS weekly_weight_change

FROM users u
LEFT JOIN activity a 
    ON u.user_id = a.user_id 
    AND a.activity_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
LEFT JOIN sleep s 
    ON u.user_id = s.user_id 
    AND s.sleep_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
WHERE u.user_id = p_user_id
GROUP BY u.name;


-- =========================
-- 2. Workout Details
-- =========================

SELECT workout_type, duration, calories, workout_date
FROM workout
WHERE user_id = p_user_id 
AND workout_date BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
ORDER BY workout_date DESC;


END //

DELIMITER ;

-- =========================
-- CALL PROCEDURE
-- =========================

CALL GenerateWeeklyHealthReport(1);
-- =========================================
-- OBJECTIVE 12: FIXED QUERY
-- =========================================

SELECT 
    DATE_FORMAT(payment_date, '%M %Y') AS billing_month,

    SUM(amount + COALESCE(discount_applied, 0)) AS gross_potential_revenue,
    SUM(COALESCE(discount_applied, 0)) AS total_credits_redeemed,
    SUM(amount) AS net_cash_received,

    ROUND(
        (SUM(COALESCE(discount_applied, 0)) / 
        SUM(amount + COALESCE(discount_applied, 0))) * 100, 
        2
    ) AS reward_usage_rate

FROM payments
WHERE payment_status = 'Completed'
GROUP BY DATE_FORMAT(payment_date, '%M %Y');

-- =========================================
-- OBJECTIVE 13: PROJECTED REVENUE
-- =========================================

CREATE OR REPLACE VIEW projected_revenue_next_month AS
SELECT
COUNT(s.subscription_id) AS expected_renewals,

SUM(p.price) AS projected_gross_revenue,

-- Estimated net (after possible discounts)
ROUND(SUM(p.price) * 0.90, 2) AS projected_net_revenue_est,

DATE_FORMAT(
    DATE_ADD(CURDATE(), INTERVAL 1 MONTH), 
    '%M %Y'
) AS projection_for_month

FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id

WHERE s.status = 'Active'
AND s.end_date BETWEEN CURDATE()
AND DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- =========================
-- VIEW RESULT
-- =========================

SELECT * FROM projected_revenue_next_month;

-- =========================================
-- OBJECTIVE 14: FINANCIAL SUMMARY
-- =========================================

SELECT
COUNT(payment_id) AS total_transactions,

SUM(amount + discount_applied) AS gross_revenue,

SUM(discount_applied) AS total_discounts_given,

SUM(amount) AS net_revenue_collected,

ROUND(
    (SUM(discount_applied) / 
    NULLIF(SUM(amount + discount_applied), 0)) * 100, 
    2
) AS discount_rate_pct

FROM payments
WHERE payment_status = 'Completed';

-- =========================
-- MONTHLY BREAKDOWN
-- =========================

SELECT
YEAR(payment_date) AS fiscal_year,
MONTH(payment_date) AS fiscal_month,
SUM(amount) AS monthly_net_revenue,
COUNT(payment_id) AS subscription_count

FROM payments
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY fiscal_year DESC, fiscal_month DESC;


-- =========================================
-- OBJECTIVE 15: USER MASTER DASHBOARD
-- =========================================

CREATE OR REPLACE VIEW User_Master_Dashboard AS
SELECT
u.user_id,
u.name,
u.current_bmi,
u.bmi_category,

s.plan_id,
p.plan_name,
s.status AS subscription_status,
s.end_date AS expiry_date,

-- Leaderboard rank
COALESCE(l.rank_position, 'Unranked') AS current_rank,
COALESCE(l.fitness_score, 0) AS monthly_score,

-- Days left
DATEDIFF(s.end_date, CURDATE()) AS days_left

FROM users u
LEFT JOIN subscriptions s ON u.user_id = s.user_id
LEFT JOIN plans p ON s.plan_id = p.plan_id
LEFT JOIN Monthly_Fitness_Leaderboard l
ON u.name = l.user_name;

-- =========================
-- VIEW USER DASHBOARD
-- =========================

SELECT * FROM User_Master_Dashboard
WHERE user_id = 1;


