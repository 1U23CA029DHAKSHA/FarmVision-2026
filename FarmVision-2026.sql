CREATE DATABASE farmvision_2026;
USE farmvision_2026;
CREATE TABLE cultivation (
    cultivation_id VARCHAR(10) PRIMARY KEY,
    crop VARCHAR(50) NOT NULL,
    area_acres DECIMAL(5,2) NOT NULL,
    planting_month VARCHAR(20) NOT NULL,
    year INT NOT NULL,
    cultivation_status VARCHAR(20) NOT NULL
);
CREATE TABLE expenses (
    expense_id VARCHAR(10) PRIMARY KEY,
    cultivation_id VARCHAR(10) NOT NULL,
    category VARCHAR(50) NOT NULL,
    type VARCHAR(50),
    amount_per_acre DECIMAL(10,2),
    area DECIMAL(5,2),
    total DECIMAL(12,2) NOT NULL,
    status VARCHAR(20),
    FOREIGN KEY (cultivation_id) REFERENCES cultivation(cultivation_id)
);
CREATE TABLE harvest (
    harvest_id VARCHAR(10) PRIMARY KEY,
    cultivation_id VARCHAR(10) NOT NULL,
    crop VARCHAR(50) NOT NULL,
    harvest_no INT NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL,
    data_status VARCHAR(20),
    planting_month VARCHAR(20),
    cultivation_status VARCHAR(20),
    FOREIGN KEY (cultivation_id) REFERENCES cultivation(cultivation_id)
);
CREATE TABLE sales (
    sale_id VARCHAR(10) PRIMARY KEY,
    cultivation_id VARCHAR(10) NOT NULL,
    crop VARCHAR(50) NOT NULL,
    quantity_kg DECIMAL(10,2) NOT NULL,
    selling_price_per_kg DECIMAL(10,2) NOT NULL,
    total_revenue DECIMAL(12,2) NOT NULL,
    data_status VARCHAR(20),
    FOREIGN KEY (cultivation_id) REFERENCES cultivation(cultivation_id)
);
INSERT INTO cultivation
(cultivation_id, crop, area_acres, planting_month, year, cultivation_status)
VALUES
('C001', 'Lady’s Finger', 1.00, 'January', 2026, 'Actual'),
('C002', 'Maize', 2.00, 'January', 2026, 'Actual'),
('C003', 'Cotton', 1.00, 'February', 2026, 'Actual'),
('C004', 'Lady’s Finger', 1.00, 'September', 2026, 'Planned'),
('C005', 'Cotton', 1.00, 'September', 2026, 'Planned'),
('C006', 'Maize', 2.00, 'September', 2026, 'Planned');
SELECT * FROM cultivation;

INSERT INTO expenses
(expense_id, cultivation_id, category, type, amount_per_acre, area, total, status)
VALUES
('E001', 'C002', 'Fertilizer', 'Input', 4500.00, 2.00, 9000.00, 'Actual'),
('E002', 'C002', 'Pesticide', 'Input', 1000.00, 2.00, 2000.00, 'Actual'),
('E003', 'C002', 'Labour', 'Labour', 14000.00, 2.00, 28000.00, 'Actual'),
('E004', 'C002', 'Irrigation', 'Water', 5000.00, 2.00, 10000.00, 'Actual'),
('E005', 'C002', 'Seed', 'Input', 2100.00, 2.00, 4200.00, 'Actual'),

('E006', 'C003', 'Fertilizer', 'Input', 8000.00, 1.00, 8000.00, 'Actual'),
('E007', 'C003', 'Pesticide', 'Input', 4000.00, 1.00, 4000.00, 'Actual'),
('E008', 'C003', 'Labour', 'Labour', 19000.00, 1.00, 19000.00, 'Actual'),
('E009', 'C003', 'Irrigation', 'Water', 7000.00, 1.00, 7000.00, 'Actual'),
('E010', 'C003', 'Seed', 'Input', 2000.00, 1.00, 2000.00, 'Actual'),

('E011', 'C004', 'Fertilizer', 'Input', 4000.00, 1.00, 4000.00, 'Planned'),
('E012', 'C004', 'Pesticide', 'Input', 5000.00, 1.00, 5000.00, 'Planned'),
('E013', 'C004', 'Labour', 'Labour', 10500.00, 1.00, 10500.00, 'Planned'),
('E014', 'C004', 'Harvesting', 'Labour', 15000.00, 1.00, 15000.00, 'Planned'),
('E015', 'C004', 'Irrigation', 'Water', 14000.00, 1.00, 14000.00, 'Planned'),
('E016', 'C004', 'Seed', 'Input', 12000.00, 1.00, 12000.00, 'Planned');
SELECT * FROM expenses;

INSERT INTO harvest
(harvest_id, cultivation_id, crop, harvest_no, quantity_kg, data_status, planting_month, cultivation_status)
VALUES
('H001', 'C002', 'Maize', 1, 5000.00, 'Actual', 'January', 'Actual'),
('H002', 'C003', 'Cotton', 1, 1200.00, 'Actual', 'February', 'Actual'),
('H003', 'C001', 'Lady’s Finger', 1, 390.00, 'Actual', 'January', 'Actual');
SELECT * FROM harvest;

INSERT INTO sales
(sale_id, cultivation_id, crop, quantity_kg, selling_price_per_kg, total_revenue, data_status)
VALUES
('S001', 'C002', 'Maize', 5000.00, 20.00, 100000.00, 'Actual'),
('S002', 'C003', 'Cotton', 1200.00, 80.00, 96000.00, 'Actual'),
('S003', 'C001', 'Lady’s Finger', 390.00, 100.00, 39000.00, 'Actual');
SELECT * FROM sales;

SELECT
    c.crop,
    COALESCE(SUM(e.total), 0) AS total_expense,
    COALESCE(SUM(s.total_revenue), 0) AS total_revenue,
    COALESCE(SUM(s.total_revenue), 0) - COALESCE(SUM(e.total), 0) AS profit,
    ROUND(
        (
            (COALESCE(SUM(s.total_revenue), 0) - COALESCE(SUM(e.total), 0))
            / NULLIF(COALESCE(SUM(e.total), 0), 0)
        ) * 100,
        2
    ) AS roi_percentage
FROM cultivation c
LEFT JOIN expenses e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN sales s
    ON c.cultivation_id = s.cultivation_id
GROUP BY c.crop;                          
  
   -- Crop-wise Profitability Analysis
WITH expense_summary AS (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    GROUP BY cultivation_id
),
sales_summary AS (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue
    FROM sales
    GROUP BY cultivation_id
)
SELECT
    c.crop,
    COALESCE(SUM(e.total_expense), 0) AS total_expense,
    COALESCE(SUM(s.total_revenue), 0) AS total_revenue,
    COALESCE(SUM(s.total_revenue), 0)
        - COALESCE(SUM(e.total_expense), 0) AS profit,
    ROUND(
        (
            (
                COALESCE(SUM(s.total_revenue), 0)
                - COALESCE(SUM(e.total_expense), 0)
            )
            / NULLIF(COALESCE(SUM(e.total_expense), 0), 0)
        ) * 100,
        2
    ) AS roi_percentage
FROM cultivation c
LEFT JOIN expense_summary e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN sales_summary s
    ON c.cultivation_id = s.cultivation_id
GROUP BY c.crop;                       
 
      -- Overall Farm KPIs
WITH expense_summary AS (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    GROUP BY cultivation_id
),
sales_summary AS (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue,
        SUM(quantity_kg) AS total_quantity
    FROM sales
    GROUP BY cultivation_id
)
SELECT
    SUM(c.area_acres) AS total_area_acres,
    SUM(COALESCE(e.total_expense, 0)) AS total_expense,
    SUM(COALESCE(s.total_quantity, 0)) AS total_production_kg,
    SUM(COALESCE(s.total_revenue, 0)) AS total_revenue,
    SUM(COALESCE(s.total_revenue, 0))
        - SUM(COALESCE(e.total_expense, 0)) AS total_profit,
    ROUND(
        (
            (
                SUM(COALESCE(s.total_revenue, 0))
                - SUM(COALESCE(e.total_expense, 0))
            )
            / NULLIF(SUM(COALESCE(e.total_expense, 0)), 0)
        ) * 100,
        2
    ) AS overall_roi_percentage
FROM cultivation c
LEFT JOIN expense_summary e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN sales_summary s
    ON c.cultivation_id = s.cultivation_id
WHERE c.cultivation_status = 'Actual';           

-- Crop Profitability Ranking
WITH expense_summary AS (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    GROUP BY cultivation_id
),
sales_summary AS (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue
    FROM sales
    GROUP BY cultivation_id
),
crop_summary AS (
    SELECT
        c.crop,
        SUM(COALESCE(e.total_expense, 0)) AS total_expense,
        SUM(COALESCE(s.total_revenue, 0)) AS total_revenue
    FROM cultivation c
    LEFT JOIN expense_summary e
        ON c.cultivation_id = e.cultivation_id
    LEFT JOIN sales_summary s
        ON c.cultivation_id = s.cultivation_id
    WHERE c.cultivation_status = 'Actual'
    GROUP BY c.crop
)
SELECT
    crop,
    total_expense,
    total_revenue,
    total_revenue - total_expense AS profit,
    ROUND(
        ((total_revenue - total_expense) / NULLIF(total_expense, 0)) * 100,
        2
    ) AS roi_percentage,
    RANK() OVER (ORDER BY total_revenue - total_expense DESC) AS profit_rank
FROM crop_summary
ORDER BY profit_rank;                      

                                      -- Expense Category Analysis
SELECT
    category,
    SUM(total) AS total_expense,
    ROUND(
        (SUM(total) / (SELECT SUM(total) FROM expenses)) * 100,
        2
    ) AS expense_percentage
FROM expenses
WHERE status = 'Actual'
GROUP BY category
ORDER BY total_expense DESC;   
       
                            -- Actual vs Planned Cultivation 
SELECT
    c.crop,
    SUM(c.area_acres) AS total_area_acres,
    SUM(h.quantity_kg) AS total_production_kg,
    ROUND(
        SUM(h.quantity_kg) / NULLIF(SUM(c.area_acres), 0),
        2
    ) AS yield_per_acre_kg,
    SUM(s.total_revenue) AS total_revenue,
    ROUND(
        SUM(s.total_revenue) / NULLIF(SUM(s.quantity_kg), 0),
        2
    ) AS average_selling_price_per_kg
FROM cultivation c
JOIN harvest h
    ON c.cultivation_id = h.cultivation_id
JOIN sales s
    ON c.cultivation_id = s.cultivation_id
WHERE c.cultivation_status = 'Actual'
GROUP BY c.crop
ORDER BY yield_per_acre_kg DESC;                     -- Crop Yield and Revenue Analysis

SELECT
    cultivation_status,
    COUNT(*) AS cultivation_cycles,
    SUM(area_acres) AS total_area_acres
FROM cultivation
GROUP BY cultivation_status
ORDER BY cultivation_status;     
                 
-- Monthly Farm Performance
SELECT
    c.planting_month,
    SUM(c.area_acres) AS total_area_acres,
    COALESCE(SUM(e.total_expense), 0) AS total_expense,
    COALESCE(SUM(s.total_revenue), 0) AS total_revenue,
    COALESCE(SUM(s.total_revenue), 0)
        - COALESCE(SUM(e.total_expense), 0) AS profit
FROM cultivation c
LEFT JOIN (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    WHERE status = 'Actual'
    GROUP BY cultivation_id
) e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue
    FROM sales
    WHERE data_status = 'Actual'
    GROUP BY cultivation_id
) s
    ON c.cultivation_id = s.cultivation_id
WHERE c.cultivation_status = 'Actual'
GROUP BY c.planting_month
ORDER BY
    CASE c.planting_month
        WHEN 'January' THEN 1
        WHEN 'February' THEN 2
        WHEN 'March' THEN 3
        WHEN 'April' THEN 4
        WHEN 'May' THEN 5
        WHEN 'June' THEN 6
        WHEN 'July' THEN 7
        WHEN 'August' THEN 8
        WHEN 'September' THEN 9
        WHEN 'October' THEN 10
        WHEN 'November' THEN 11
        WHEN 'December' THEN 12
    END;                                            -- Most Profitable Crop
    
    WITH expense_summary AS (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    GROUP BY cultivation_id
),
sales_summary AS (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue
    FROM sales
    GROUP BY cultivation_id
)
SELECT
    c.crop,
    SUM(COALESCE(e.total_expense, 0)) AS total_expense,
    SUM(COALESCE(s.total_revenue, 0)) AS total_revenue,
    SUM(COALESCE(s.total_revenue, 0))
        - SUM(COALESCE(e.total_expense, 0)) AS profit
FROM cultivation c
LEFT JOIN expense_summary e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN sales_summary s
    ON c.cultivation_id = s.cultivation_id
WHERE c.cultivation_status = 'Actual'
GROUP BY c.crop
ORDER BY profit DESC
LIMIT 1;                                                      -- Loss-Making Crop

WITH expense_summary AS (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    GROUP BY cultivation_id
),
sales_summary AS (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue
    FROM sales
    GROUP BY cultivation_id
)
SELECT
    c.crop,
    SUM(COALESCE(e.total_expense, 0)) AS total_expense,
    SUM(COALESCE(s.total_revenue, 0)) AS total_revenue,
    SUM(COALESCE(s.total_revenue, 0))
        - SUM(COALESCE(e.total_expense, 0)) AS profit
FROM cultivation c
LEFT JOIN expense_summary e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN sales_summary s
    ON c.cultivation_id = s.cultivation_id
WHERE c.cultivation_status = 'Actual'
GROUP BY c.crop
ORDER BY profit ASC
LIMIT 1;           
                     
    -- Cultivation Cycle ROI
WITH expense_summary AS (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    GROUP BY cultivation_id
),
sales_summary AS (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue
    FROM sales
    GROUP BY cultivation_id
)
SELECT
    c.cultivation_id,
    c.crop,
    c.planting_month,
    c.area_acres,
    COALESCE(e.total_expense, 0) AS total_expense,
    COALESCE(s.total_revenue, 0) AS total_revenue,
    COALESCE(s.total_revenue, 0)
        - COALESCE(e.total_expense, 0) AS profit,
    ROUND(
        (
            (
                COALESCE(s.total_revenue, 0)
                - COALESCE(e.total_expense, 0)
            )
            / NULLIF(COALESCE(e.total_expense, 0), 0)
        ) * 100,
        2
    ) AS roi_percentage
FROM cultivation c
LEFT JOIN expense_summary e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN sales_summary s
    ON c.cultivation_id = s.cultivation_id
WHERE c.cultivation_status = 'Actual'
ORDER BY roi_percentage DESC;      
                     
-- Crop Profitability View
CREATE VIEW crop_profitability AS
WITH expense_summary AS (
    SELECT
        cultivation_id,
        SUM(total) AS total_expense
    FROM expenses
    GROUP BY cultivation_id
),
sales_summary AS (
    SELECT
        cultivation_id,
        SUM(total_revenue) AS total_revenue
    FROM sales
    GROUP BY cultivation_id
)
SELECT
    c.crop,
    SUM(COALESCE(e.total_expense, 0)) AS total_expense,
    SUM(COALESCE(s.total_revenue, 0)) AS total_revenue,
    SUM(COALESCE(s.total_revenue, 0))
        - SUM(COALESCE(e.total_expense, 0)) AS profit,
    ROUND(
        (
            (
                SUM(COALESCE(s.total_revenue, 0))
                - SUM(COALESCE(e.total_expense, 0))
            )
            / NULLIF(SUM(COALESCE(e.total_expense, 0)), 0)
        ) * 100,
        2
    ) AS roi_percentage
FROM cultivation c
LEFT JOIN expense_summary e
    ON c.cultivation_id = e.cultivation_id
LEFT JOIN sales_summary s
    ON c.cultivation_id = s.cultivation_id
WHERE c.cultivation_status = 'Actual'
GROUP BY c.crop;
SELECT * FROM crop_profitability;

