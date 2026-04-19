CREATE TABLE crafting_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    player_src VARCHAR(50),
    item_name VARCHAR(100),
    quantity INT,
    total_price INT,
    timestamp DATETIME
);