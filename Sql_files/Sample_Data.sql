USE fitness_tracker;

SELECT * FROM users;
SELECT * FROM activity;
SELECT * FROM workout;
SELECT * FROM measurement;
SELECT * FROM plans;
SELECT * FROM subscriptions;
SELECT * FROM payments;
SELECT * FROM sleep;
SELECT * FROM diet;
INSERT INTO users (name, age, gender, height, weight) VALUES
('User1', 21, 'Male', 170, 65),
('User2', 22, 'Female', 160, 55),
('User3', 23, 'Male', 175, 70),
('User4', 24, 'Female', 165, 60),
('User5', 25, 'Male', 180, 80),
('User6', 26, 'Female', 158, 52),
('User7', 27, 'Male', 172, 68),
('User8', 28, 'Female', 162, 58),
('User9', 29, 'Male', 178, 75),
('User10', 30, 'Female', 168, 62),
('User11', 31, 'Male', 169, 66),
('User12', 22, 'Female', 155, 50),
('User13', 23, 'Male', 177, 72),
('User14', 24, 'Female', 163, 59),
('User15', 25, 'Male', 182, 85),
('User16', 26, 'Female', 159, 54),
('User17', 27, 'Male', 174, 69),
('User18', 28, 'Female', 161, 57),
('User19', 29, 'Male', 176, 73),
('User20', 30, 'Female', 167, 61);


INSERT INTO plans (plan_name, price, duration_days) VALUES
('Basic', 500, 30),
('Standard', 1000, 60),
('Premium', 2000, 90),
('Annual', 5000, 365),
('Weight Loss', 1500, 60);

INSERT INTO subscriptions (user_id, plan_id, start_date, end_date) VALUES
(1,1,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 30 DAY)),
(2,2,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY)),
(3,3,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 90 DAY)),
(4,4,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 365 DAY)),
(5,5,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY)),
(6,1,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 30 DAY)),
(7,2,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY)),
(8,3,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 90 DAY)),
(9,4,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 365 DAY)),
(10,5,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY)),
(11,1,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 30 DAY)),
(12,2,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY)),
(13,3,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 90 DAY)),
(14,4,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 365 DAY)),
(15,5,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY)),
(16,1,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 30 DAY)),
(17,2,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY)),
(18,3,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 90 DAY)),
(19,4,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 365 DAY)),
(20,5,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY));

INSERT INTO activity (user_id, activity_date, steps, calories_burned, distance) VALUES
(1,CURDATE(),12000,400,8),
(2,CURDATE(),8000,300,5),
(3,CURDATE(),15000,600,10),
(4,CURDATE(),5000,200,3),
(5,CURDATE(),11000,450,7),
(6,CURDATE(),9000,350,6),
(7,CURDATE(),13000,500,9),
(8,CURDATE(),7000,250,4),
(9,CURDATE(),14000,550,9),
(10,CURDATE(),6000,220,3),
(11,CURDATE(),10000,400,7),
(12,CURDATE(),7500,270,5),
(13,CURDATE(),16000,650,11),
(14,CURDATE(),8500,300,6),
(15,CURDATE(),17000,700,12),
(16,CURDATE(),4000,150,2),
(17,CURDATE(),12500,480,8),
(18,CURDATE(),9500,360,6),
(19,CURDATE(),13500,520,9),
(20,CURDATE(),10500,410,7);

INSERT INTO workout (user_id, workout_type, duration, calories, workout_date) VALUES
(1,'Running',30,300,CURDATE()),
(2,'Yoga',45,200,CURDATE()),
(3,'Cycling',60,500,CURDATE()),
(4,'Gym',50,400,CURDATE()),
(5,'Running',40,350,CURDATE()),
(6,'Yoga',30,150,CURDATE()),
(7,'Cycling',55,450,CURDATE()),
(8,'Gym',60,500,CURDATE()),
(9,'Running',35,320,CURDATE()),
(10,'Yoga',50,220,CURDATE()),
(11,'Gym',45,380,CURDATE()),
(12,'Cycling',65,520,CURDATE()),
(13,'Running',30,300,CURDATE()),
(14,'Yoga',40,200,CURDATE()),
(15,'Gym',70,600,CURDATE()),
(16,'Cycling',50,420,CURDATE()),
(17,'Running',45,350,CURDATE()),
(18,'Yoga',35,180,CURDATE()),
(19,'Gym',60,500,CURDATE()),
(20,'Cycling',55,460,CURDATE());

INSERT INTO measurement (user_id, measure_date, weight, body_fat) VALUES
(1,CURDATE(),65,15),(2,CURDATE(),55,20),(3,CURDATE(),70,18),
(4,CURDATE(),60,22),(5,CURDATE(),80,25),(6,CURDATE(),52,19),
(7,CURDATE(),68,21),(8,CURDATE(),58,23),(9,CURDATE(),75,24),
(10,CURDATE(),62,20),(11,CURDATE(),66,18),(12,CURDATE(),50,17),
(13,CURDATE(),72,22),(14,CURDATE(),59,21),(15,CURDATE(),85,26),
(16,CURDATE(),54,20),(17,CURDATE(),69,23),(18,CURDATE(),57,19),
(19,CURDATE(),73,22),(20,CURDATE(),61,21);

INSERT INTO payments (subscription_id, amount, payment_method) VALUES
(1,500,'UPI'),(2,1000,'Card'),(3,2000,'UPI'),(4,5000,'Net Banking'),
(5,1500,'UPI'),(6,500,'Card'),(7,1000,'UPI'),(8,2000,'Card'),
(9,5000,'UPI'),(10,1500,'Card'),(11,500,'UPI'),(12,1000,'Card'),
(13,2000,'UPI'),(14,5000,'Net Banking'),(15,1500,'UPI'),
(16,500,'Card'),(17,1000,'UPI'),(18,2000,'Card'),
(19,5000,'UPI'),(20,1500,'Card');

INSERT INTO diet (user_id, diet_date, calories) VALUES
(1, CURDATE(), 2000),
(2, CURDATE(), 1800),
(3, CURDATE(), 2200),
(4, CURDATE(), 1500),
(5, CURDATE(), 2100),
(6, CURDATE(), 1700),
(7, CURDATE(), 2300),
(8, CURDATE(), 1600),
(9, CURDATE(), 2400),
(10, CURDATE(), 1900),
(11, CURDATE(), 2000),
(12, CURDATE(), 1800),
(13, CURDATE(), 2200),
(14, CURDATE(), 1600),
(15, CURDATE(), 2500),
(16, CURDATE(), 1700),
(17, CURDATE(), 2100),
(18, CURDATE(), 1800),
(19, CURDATE(), 2300),
(20, CURDATE(), 2000);


INSERT INTO sleep (user_id, sleep_date, duration, quality) VALUES
(1, CURDATE(), 5.5, 'Poor'),
(2, CURDATE(), 7.0, 'Good'),
(3, CURDATE(), 6.5, 'Average'),
(4, CURDATE(), 4.5, 'Poor'),
(5, CURDATE(), 8.0, 'Good'),
(6, CURDATE(), 5.0, 'Poor'),
(7, CURDATE(), 6.0, 'Average'),
(8, CURDATE(), 7.5, 'Good'),
(9, CURDATE(), 5.5, 'Poor'),
(10, CURDATE(), 6.5, 'Average'),
(11, CURDATE(), 7.0, 'Good'),
(12, CURDATE(), 4.0, 'Poor'),
(13, CURDATE(), 8.0, 'Good'),
(14, CURDATE(), 5.5, 'Poor'),
(15, CURDATE(), 6.5, 'Average'),
(16, CURDATE(), 7.5, 'Good'),
(17, CURDATE(), 5.0, 'Poor'),
(18, CURDATE(), 6.0, 'Average'),
(19, CURDATE(), 7.0, 'Good'),
(20, CURDATE(), 4.5, 'Poor');
