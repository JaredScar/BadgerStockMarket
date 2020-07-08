CREATE TABLE IF NOT EXISTS user_stock_data (
	id INTEGER(11) AUTO_INCREMENT PRIMARY KEY, 
	identifier VARCHAR(50), 
	stockAbbrev VARCHAR(16),
	ownCount INTEGER(16)
);

CREATE TABLE IF NOT EXISTS stock_purchase_data (
	id INTEGER(11) AUTO_INCREMENT PRIMARY KEY,
	identifier VARCHAR(50),
	purchasedPrice DOUBLE,
	stockAbbrev VARCHAR(16),
	isOwned BIT(1)
);