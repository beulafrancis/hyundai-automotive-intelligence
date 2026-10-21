--1.Suppliers:

CREATE TABLE suppliers (
    supplier_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_code VARCHAR(20) UNIQUE NOT NULL,
    supplier_name VARCHAR(120) NOT NULL,
    supplier_type VARCHAR(40),

    continent VARCHAR(40),
    country VARCHAR(60),
    region VARCHAR(60),
    state VARCHAR(60),
    city VARCHAR(60),

    contact_email VARCHAR(120),
    supplier_start_date DATE,
    lead_time_days INTEGER,
    quality_rating NUMERIC(3,2),
    supplier_status VARCHAR(20) DEFAULT 'Active',

    CHECK (
        lead_time_days IS NULL
        OR lead_time_days >= 0
    ),
    CHECK (
        quality_rating IS NULL
        OR quality_rating BETWEEN 0 AND 5
    ),
    CHECK (
        supplier_status IN ('Active', 'Inactive')
    ),
    CHECK (
        supplier_start_date IS NULL
        OR supplier_start_date <= DATE '2025-12-31'
    )
);



--2. Materials:

CREATE TABLE materials (
    material_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_code VARCHAR(30) UNIQUE NOT NULL,
    material_name VARCHAR(120) NOT NULL,
    material_category VARCHAR(50) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    standard_unit_cost_inr NUMERIC(14,2),
    material_status VARCHAR(20) NOT NULL DEFAULT 'Active',

    CHECK (
        standard_unit_cost_inr IS NULL
        OR standard_unit_cost_inr >= 0
    ),

    CHECK (
        material_status IN ('Active', 'Inactive')
    )
);



--3. material_purchases

CREATE TABLE material_purchases (
    purchase_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    material_code VARCHAR(30) NOT NULL
        REFERENCES materials(material_code),
    material_name VARCHAR(150) NOT NULL,
    material_category VARCHAR(60) NOT NULL,
    specification VARCHAR(100),
    unit_of_measure VARCHAR(20) NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(supplier_id),
    purchase_order_no VARCHAR(40),
    purchase_date DATE NOT NULL,
    quantity NUMERIC(14,2) NOT NULL,
    total_quantity NUMERIC(16,2),
    unit_price_inr NUMERIC(14,2) NOT NULL,
    discount_inr NUMERIC(14,2) DEFAULT 0,
    tax_inr NUMERIC(14,2) DEFAULT 0,
    total_amount_inr NUMERIC(18,2) NOT NULL,
    delivery_status VARCHAR(20) DEFAULT 'Pending',

    CHECK (purchase_date BETWEEN DATE '2021-01-01'
                             AND DATE '2025-12-31'),
    CHECK (quantity > 0),
    CHECK (total_quantity IS NULL OR total_quantity >= 0),
    CHECK (unit_price_inr >= 0),
    CHECK (discount_inr >= 0),
    CHECK (tax_inr >= 0),
    CHECK (total_amount_inr >= 0),
    CHECK (delivery_status IN
          ('Pending', 'Delivered', 'Partial', 'Cancelled'))
);


--4.production_quality

CREATE TABLE production_quality (
    production_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    batch_no VARCHAR(40) UNIQUE NOT NULL,
    vehicle_id INTEGER NOT NULL
        REFERENCES vehicle_master(vehicle_id),

    plant_name VARCHAR(100) NOT NULL,
    production_shift VARCHAR(20),

    production_date DATE NOT NULL,
    planned_start_date DATE,
    actual_start_date DATE,
    planned_completion_date DATE,
    actual_completion_date DATE,

    planned_quantity INTEGER NOT NULL,
    produced_quantity INTEGER NOT NULL DEFAULT 0,

    inspected_quantity INTEGER NOT NULL DEFAULT 0,
    quality_pass_quantity INTEGER NOT NULL DEFAULT 0,
    quality_fail_quantity INTEGER NOT NULL DEFAULT 0,

    defect_category VARCHAR(100),
    production_status VARCHAR(25) NOT NULL DEFAULT 'Planned',

    CHECK (
        production_date BETWEEN DATE '2021-01-01'
        AND DATE '2025-12-31'
    ),

    CHECK (planned_quantity > 0),
    CHECK (produced_quantity >= 0),
    CHECK (inspected_quantity >= 0),
    CHECK (quality_pass_quantity >= 0),
    CHECK (quality_fail_quantity >= 0),

    CHECK (inspected_quantity <= produced_quantity),

    CHECK (
        quality_pass_quantity + quality_fail_quantity
        = inspected_quantity
    ),

    CHECK (
        planned_start_date IS NULL
        OR planned_completion_date IS NULL
        OR planned_start_date <= planned_completion_date
    ),

    CHECK (
        actual_start_date IS NULL
        OR actual_completion_date IS NULL
        OR actual_start_date <= actual_completion_date
    ),

    CHECK (
        production_status IN (
            'Planned',
            'In Progress',
            'Completed',
            'Delayed',
            'Cancelled'
        )
    )
);




--5.vehicle_master 

CREATE TABLE vehicle_master (
    vehicle_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    vehicle_code VARCHAR(30) UNIQUE NOT NULL,
    vehicle_model VARCHAR(100) NOT NULL,
    vehicle_variant VARCHAR(100) NOT NULL,
    vehicle_category VARCHAR(50) NOT NULL,
    powertrain VARCHAR(50) NOT NULL,
    engine_capacity_cc INTEGER,
    transmission_type VARCHAR(30),
    fuel_type VARCHAR(30),
    launch_date DATE,
    model_year INTEGER NOT NULL,
    manufacturing_country VARCHAR(60) NOT NULL DEFAULT 'India',
    vehicle_status VARCHAR(20) NOT NULL DEFAULT 'Active',

    CHECK (model_year BETWEEN 2021 AND 2025),
    CHECK (
        engine_capacity_cc IS NULL
        OR engine_capacity_cc > 0
    ),
    CHECK (
        launch_date IS NULL
        OR launch_date <= DATE '2025-12-31'
    ),
    CHECK (
        vehicle_status IN ('Active', 'Discontinued')
    )
);


--6.distributors

CREATE TABLE distributors (
    dealer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dealer_code VARCHAR(30) UNIQUE NOT NULL,
    dealer_name VARCHAR(150) NOT NULL,
    dealer_type VARCHAR(40),
    city VARCHAR(100),
    state VARCHAR(100),
    dealer_region VARCHAR(100),
    dealer_status VARCHAR(20) DEFAULT 'Active',
    email_id VARCHAR(150),
    contact_number VARCHAR(30),
    country_name VARCHAR(100) NOT NULL,
    continent VARCHAR(50),
    region VARCHAR(100),
    brand_name VARCHAR(50) NOT NULL DEFAULT 'Hyundai',
    source_url TEXT,
    verification_status VARCHAR(40),
    last_verified_date DATE,
    address TEXT,
    fax_number VARCHAR(30),

    CHECK (dealer_status IN ('Active', 'Inactive'))
);


--7.exports 

CREATE TABLE exports (
    export_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    export_reference VARCHAR(50) UNIQUE,
    vehicle_id INTEGER REFERENCES vehicle_master(vehicle_id),
    dealer_id INTEGER REFERENCES distributors(dealer_id),
    export_date DATE NOT NULL,
    export_year INTEGER,
    export_month INTEGER,
    destination_country VARCHAR(100) NOT NULL,
    continent VARCHAR(50),
    region VARCHAR(100),
    destination_port VARCHAR(100),
    port_of_loading VARCHAR(100),
    export_quantity INTEGER NOT NULL,
    unit_price NUMERIC(16,2),
    total_price NUMERIC(18,2),
    export_value NUMERIC(18,2),
    currency VARCHAR(10),
    shipment_status VARCHAR(30),
    destination_verification_status VARCHAR(40),

    CHECK (export_date BETWEEN DATE '2021-01-01'
                           AND DATE '2025-12-31'),
    CHECK (export_quantity > 0),
    CHECK (unit_price IS NULL OR unit_price >= 0),
    CHECK (total_price IS NULL OR total_price >= 0),
    CHECK (export_value IS NULL OR export_value >= 0)
);


--8.customs_clearance 

CREATE TABLE customs_clearance (
    clearance_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    export_id BIGINT NOT NULL REFERENCES exports(export_id),
    clearance_reference VARCHAR(50) UNIQUE,
    destination_country VARCHAR(100) NOT NULL,
    customs_port VARCHAR(100),
    declaration_date DATE,
    inspection_date DATE,
    clearance_date DATE,
    clearance_status VARCHAR(30) NOT NULL DEFAULT 'Pending',
    duty_amount NUMERIC(16,2) DEFAULT 0,
    tax_amount NUMERIC(16,2) DEFAULT 0,
    currency VARCHAR(10),
    delay_reason VARCHAR(200),
    remarks TEXT,

    CHECK (duty_amount IS NULL OR duty_amount >= 0),
    CHECK (tax_amount IS NULL OR tax_amount >= 0),
    CHECK (clearance_status IN (
        'Pending',
        'Under Inspection',
        'Cleared',
        'Held',
        'Rejected'
    ))
);


--9. logistics_delivery

CREATE TABLE logistics_delivery (
    delivery_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    export_id BIGINT REFERENCES exports(export_id),

    shipment_reference VARCHAR(50),
    bill_of_lading_number VARCHAR(50),
    container_number VARCHAR(30),
    vessel_name VARCHAR(100),
    shipping_line VARCHAR(100),
    transport_mode VARCHAR(30),

    port_of_loading VARCHAR(100),
    destination_port VARCHAR(100),
    destination_country VARCHAR(100),

    booking_date DATE,
    dispatch_date DATE,
    departure_date DATE,
    expected_arrival_date DATE,
    actual_arrival_date DATE,
    customs_release_date DATE,
    warehouse_arrival_date DATE,

    dealer_id INTEGER REFERENCES distributors(dealer_id),
    dealer_delivery_date DATE,

    delivery_status VARCHAR(30),
    transit_days INTEGER,
    delay_days INTEGER,

    freight_cost NUMERIC(16,2),
    currency VARCHAR(10),

    tracking_number VARCHAR(100),
    delay_reason VARCHAR(200),
    remarks TEXT,

    record_source VARCHAR(100),
    verification_status VARCHAR(40),

    CHECK (transit_days IS NULL OR transit_days >= 0),
    CHECK (delay_days IS NULL OR delay_days >= 0),
    CHECK (freight_cost IS NULL OR freight_cost >= 0)
);



--10.warehouse_inventory

CREATE TABLE warehouse_inventory (
    inventory_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    vehicle_id INTEGER NOT NULL
        REFERENCES vehicle_master(vehicle_id),

    warehouse_name VARCHAR(100) NOT NULL,
    warehouse_location VARCHAR(150),
    country VARCHAR(100),

    inventory_date DATE NOT NULL,
    opening_stock INTEGER DEFAULT 0,
    received_quantity INTEGER DEFAULT 0,
    dispatched_quantity INTEGER DEFAULT 0,
    closing_stock INTEGER DEFAULT 0,

    reserved_quantity INTEGER DEFAULT 0,
    damaged_quantity INTEGER DEFAULT 0,

    inventory_status VARCHAR(30) DEFAULT 'Available',

    CHECK (opening_stock >= 0),
    CHECK (received_quantity >= 0),
    CHECK (dispatched_quantity >= 0),
    CHECK (closing_stock >= 0),
    CHECK (reserved_quantity >= 0),
    CHECK (damaged_quantity >= 0),

    CHECK (
        inventory_status IN (
            'Available',
            'Reserved',
            'Dispatched',
            'Damaged'
        )
    ),

    CHECK (
        inventory_date BETWEEN DATE '2021-01-01'
        AND DATE '2025-12-31'
    )
);


--1.suppliers.insert.sql

WITH locations AS (
    SELECT *
    FROM (VALUES
        (1,  'Asia', 'India', 'South India', 'Tamil Nadu', 'Chennai'),
        (2,  'Asia', 'India', 'South India', 'Tamil Nadu', 'Coimbatore'),
        (3,  'Asia', 'India', 'South India', 'Tamil Nadu', 'Madurai'),
        (4,  'Asia', 'India', 'South India', 'Karnataka', 'Bengaluru'),
        (5,  'Asia', 'India', 'South India', 'Kerala', 'Kochi'),
        (6,  'Asia', 'India', 'South India', 'Telangana', 'Hyderabad'),
        (7,  'Asia', 'India', 'West India', 'Maharashtra', 'Pune'),
        (8,  'Asia', 'India', 'West India', 'Maharashtra', 'Mumbai'),
        (9,  'Asia', 'India', 'West India', 'Gujarat', 'Ahmedabad'),
        (10, 'Asia', 'India', 'North India', 'Haryana', 'Gurugram'),
        (11, 'Asia', 'India', 'North India', 'Uttar Pradesh', 'Noida'),
        (12, 'Asia', 'India', 'East India', 'West Bengal', 'Kolkata'),
        (13, 'Asia', 'Japan', 'East Asia', 'Aichi Prefecture', 'Nagoya'),
        (14, 'Asia', 'South Korea', 'East Asia', 'Gyeonggi Province', 'Suwon'),
        (15, 'Asia', 'China', 'East Asia', 'Shanghai Municipality', 'Shanghai'),
        (16, 'Europe', 'Germany', 'Central Europe', 'Bavaria', 'Munich'),
        (17, 'Europe', 'United Kingdom', 'Western Europe', 'England', 'Birmingham'),
        (18, 'North America', 'United States', 'North America', 'Michigan', 'Detroit'),
        (19, 'North America', 'Mexico', 'North America', 'Puebla', 'Puebla City'),
        (20, 'Asia', 'Thailand', 'Southeast Asia', 'Chonburi', 'Chonburi'),
        (21, 'Asia', 'Vietnam', 'Southeast Asia', 'Dong Nai', 'Bien Hoa'),
        (22, 'Europe', 'France', 'Western Europe', 'Auvergne-Rhone-Alpes', 'Lyon')
    ) AS l(location_id, continent, country, region, state, city)
),
generated AS (
    SELECT
        n,
        CASE
            WHEN n <= 1200 THEN ((n - 1) % 12) + 1
            ELSE 13 + ((n - 1201) % 10)
        END AS location_id
    FROM generate_series(1, 2000) AS gs(n)
),
supplier_data AS (
    SELECT
        g.n,
        l.continent,
        l.country,
        l.region,
        l.state,
        l.city,
        CASE g.n % 6
            WHEN 0 THEN 'Raw Material'
            WHEN 1 THEN 'Component Manufacturer'
            WHEN 2 THEN 'Electronics'
            WHEN 3 THEN 'Spare Parts'
            WHEN 4 THEN 'Packaging'
            ELSE 'Logistics'
        END AS supplier_type
    FROM generated g
    JOIN locations l ON l.location_id = g.location_id
)
INSERT INTO suppliers (
    supplier_code,
    supplier_name,
    supplier_type,
    continent,
    country,
    region,
    state,
    city,
    contact_email,
    lead_time_days,
    quality_rating,
    supplier_status
)
SELECT
    'SUP-' || LPAD(n::TEXT, 4, '0'),
    'Simulated Supplier ' || LPAD(n::TEXT, 4, '0'),
    supplier_type,
    continent,
    country,
    region,
    state,
    city,
    'supplier' || LPAD(n::TEXT, 4, '0') || '@example.com',
    2 + (n % 39),
    (2.50 + ((n % 26) * 0.10))::NUMERIC(3,2),
    CASE
        WHEN n % 20 = 0 THEN 'Inactive'
        ELSE 'Active'
    END
FROM supplier_data
ON CONFLICT (supplier_code) DO NOTHING;



--2.vehicle_master_insert.sql

INSERT INTO vehicle_master (
    vehicle_code,
    vehicle_model,
    vehicle_variant,
    vehicle_category,
    powertrain,
    engine_capacity_cc,
    transmission_type,
    fuel_type,
    launch_date,
    model_year,
    manufacturing_country,
    vehicle_status
)
VALUES
-- EXTER
('HYU031', 'Exter', 'EX', 'SUV', 'Petrol', 1197, 'Manual', 'Petrol', '2023-07-10', 2023, 'India', 'Active'),
('HYU032', 'Exter', 'S', 'SUV', 'Petrol', 1197, 'Manual', 'Petrol', '2023-07-10', 2023, 'India', 'Active'),
('HYU033', 'Exter', 'SX', 'SUV', 'Petrol', 1197, 'Manual', 'Petrol', '2023-07-10', 2023, 'India', 'Active'),
('HYU034', 'Exter', 'SX AMT', 'SUV', 'Petrol', 1197, 'Automatic', 'Petrol', '2023-07-10', 2023, 'India', 'Active'),

-- i20 N Line
('HYU035', 'i20 N Line', 'N6', 'Hatchback', 'Petrol', 998, 'Manual', 'Petrol', '2021-09-02', 2021, 'India', 'Active'),
('HYU036', 'i20 N Line', 'N8', 'Hatchback', 'Petrol', 998, 'Automatic', 'Petrol', '2021-09-02', 2021, 'India', 'Active'),

-- Venue N Line
('HYU037', 'Venue N Line', 'N6', 'SUV', 'Petrol', 998, 'Manual', 'Petrol', '2022-09-06', 2022, 'India', 'Active'),
('HYU038', 'Venue N Line', 'N8', 'SUV', 'Petrol', 998, 'Automatic', 'Petrol', '2022-09-06', 2022, 'India', 'Active'),

-- Creta N Line
('HYU039', 'Creta N Line', 'N8', 'SUV', 'Petrol', 1482, 'Manual', 'Petrol', '2024-03-11', 2024, 'India', 'Active'),
('HYU040', 'Creta N Line', 'N10', 'SUV', 'Petrol', 1482, 'Automatic', 'Petrol', '2024-03-11', 2024, 'India', 'Active'),

-- Creta Electric
('HYU041', 'Creta Electric', 'Executive', 'SUV', 'Electric', NULL, 'Automatic', 'Electric', '2025-01-17', 2025, 'India', 'Active'),
('HYU042', 'Creta Electric', 'Smart', 'SUV', 'Electric', NULL, 'Automatic', 'Electric', '2025-01-17', 2025, 'India', 'Active'),

-- Tucson
('HYU043', 'Tucson', 'Platinum', 'SUV', 'Petrol', 1999, 'Automatic', 'Petrol', '2022-08-10', 2022, 'India', 'Active'),
('HYU044', 'Tucson', 'Signature', 'SUV', 'Diesel', 1997, 'Automatic', 'Diesel', '2022-08-10', 2022, 'India', 'Active'),

-- IONIQ 5
('HYU045', 'IONIQ 5', 'Long Range', 'SUV', 'Electric', NULL, 'Automatic', 'Electric', '2023-01-11', 2023, 'India', 'Active');

-- Verify
SELECT vehicle_model, COUNT(*) AS variant_count
FROM vehicle_master
GROUP BY vehicle_model
ORDER BY vehicle_model;




--3.production quality.sql
INSERT INTO production_quality (
    vehicle_id,
    production_date,
    model_year,
    plant_name,
    production_shift,
    planned_quantity,
    produced_quantity,
    defect_quantity,
    rejected_quantity,
    quality_status
)
SELECT
    vm.vehicle_id,
    d.production_date,
    EXTRACT(YEAR FROM d.production_date)::INTEGER,
    CASE
        WHEN vm.vehicle_model IN ('Creta', 'Venue', 'Alcazar', 'Tucson')
            THEN 'Chennai SUV Plant'
        ELSE 'Chennai Passenger Vehicle Plant'
    END,
    CASE
        WHEN s.n % 3 = 0 THEN 'Morning'
        WHEN s.n % 3 = 1 THEN 'Evening'
        ELSE 'Night'
    END,
    100 + (s.n % 51),
    95 + (s.n % 46),
    s.n % 6,
    s.n % 4,
    CASE
        WHEN s.n % 20 = 0 THEN 'Under Review'
        ELSE 'Completed'
    END
FROM generate_series(100001, 200000) AS s(n)
JOIN vehicle_master vm
    ON vm.vehicle_id = (
        SELECT vehicle_id
        FROM vehicle_master
        ORDER BY vehicle_id
        OFFSET ((s.n - 1) % (SELECT COUNT(*) FROM vehicle_master))
        LIMIT 1
    )
CROSS JOIN LATERAL (
    SELECT (
        DATE '2021-01-01'
        + ((s.n * 7) % 1826)::INTEGER
    )::DATE AS production_date
) d;



--production_quality_foreign_keys.sql:

SELECT
    tc.constraint_name,
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu
    ON tc.constraint_name = ccu.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_name = 'production_quality';



--suppliers_country_correction.sql:

--4.material_purchases_insert.sql
WITH base_materials AS (
    SELECT *
    FROM (VALUES
        ('Steel Sheet', 'Raw Material', 'kg'),
        ('Aluminium Alloy', 'Raw Material', 'kg'),
        ('Copper Wire', 'Electrical', 'meter'),
        ('Polypropylene Resin', 'Plastic', 'kg'),
        ('ABS Polymer', 'Plastic', 'kg'),
        ('EPDM Rubber', 'Rubber', 'kg'),
        ('Automotive Glass', 'Glass', 'piece'),
        ('Brake Pad', 'Brake System', 'piece'),
        ('Brake Disc', 'Brake System', 'piece'),
        ('Oil Filter', 'Engine Component', 'piece'),
        ('Air Filter', 'Engine Component', 'piece'),
        ('Fuel Injector', 'Engine Component', 'piece'),
        ('Piston', 'Engine Component', 'piece'),
        ('Crankshaft', 'Engine Component', 'piece'),
        ('Camshaft', 'Engine Component', 'piece'),
        ('Spark Plug', 'Engine Component', 'piece'),
        ('Radiator', 'Cooling System', 'piece'),
        ('Water Pump', 'Cooling System', 'piece'),
        ('Alternator', 'Electrical', 'piece'),
        ('Starter Motor', 'Electrical', 'piece'),
        ('Wiring Harness', 'Electrical', 'piece'),
        ('Fuse Box', 'Electrical', 'piece'),
        ('Oxygen Sensor', 'Sensor', 'piece'),
        ('Parking Sensor', 'Sensor', 'piece'),
        ('Control Module', 'Electronics', 'piece'),
        ('Seat Frame', 'Interior', 'piece'),
        ('Seat Belt Assembly', 'Safety', 'piece'),
        ('Airbag Module', 'Safety', 'piece'),
        ('Door Handle', 'Body Component', 'piece'),
        ('Side Mirror', 'Body Component', 'piece'),
        ('Windshield', 'Glass', 'piece'),
        ('Headlamp Assembly', 'Lighting', 'piece'),
        ('Tail Lamp Assembly', 'Lighting', 'piece'),
        ('Suspension Spring', 'Suspension', 'piece'),
        ('Shock Absorber', 'Suspension', 'piece'),
        ('Steering Rack', 'Steering', 'piece'),
        ('Clutch Plate', 'Transmission', 'piece'),
        ('Gear Set', 'Transmission', 'set'),
        ('Drive Shaft', 'Transmission', 'piece'),
        ('Battery Cell', 'Electrical', 'piece'),
        ('Tyre', 'Tyre and Wheel', 'piece'),
        ('Alloy Wheel', 'Tyre and Wheel', 'piece'),
        ('Chassis Bracket', 'Body Component', 'piece'),
        ('Bumper Reinforcement', 'Body Component', 'piece'),
        ('Fastener Bolt', 'Fasteners', 'piece'),
        ('Mounting Nut', 'Fasteners', 'piece'),
        ('Gasket', 'Sealing', 'piece'),
        ('O Ring', 'Sealing', 'piece'),
        ('Coolant Hose', 'Cooling System', 'meter'),
        ('Fuel Hose', 'Fuel System', 'meter')
    ) AS t(material_name, material_category, unit_of_measure)
),
specifications AS (
    SELECT *
    FROM (VALUES
        ('Grade A', 'Grade A'),
        ('Grade B', 'Grade B'),
        ('Grade C', 'Grade C'),
        ('Type 1', 'Type 1'),
        ('Type 2', 'Type 2'),
        ('Type 3', 'Type 3'),
        ('Standard Duty', 'Standard Duty'),
        ('Heavy Duty', 'Heavy Duty'),
        ('Premium Grade', 'Premium Grade'),
        ('Export Grade', 'Export Grade')
    ) AS s(specification, suffix)
),
generated AS (
    SELECT
        b.material_name || ' - ' || s.suffix AS material_name,
        b.material_category,
        s.specification,
        b.unit_of_measure,
        ROW_NUMBER() OVER (
            ORDER BY b.material_name, s.specification
        ) AS rn
    FROM base_materials b
    CROSS JOIN specifications s
)
INSERT INTO material_purchases (
    material_code,
    material_name,
    material_category,
    specification,
    unit_of_measure,
    purchase_date,
    quantity,
    total_quantity,
    unit_price_inr,
    discount_inr,
    tax_inr,
    total_amount_inr,
    delivery_status
)
SELECT
    'MAT-' || LPAD(rn::TEXT, 4, '0'),
    material_name,
    material_category,
    specification,
    unit_of_measure,
    DATE '2021-01-01' + ((rn * 17) % 1826)::INTEGER,
    100 + ((rn * 13) % 900),
    NULL,
    50 + ((rn * 29) % 4950),
    0,
    0,
    (100 + ((rn * 13) % 900))
        * (50 + ((rn * 29) % 4950)),
    'Delivered'
FROM generated;




--material_purchases_update.sql:

UPDATE material_purchases m
SET supplier_id = s.supplier_id
FROM suppliers s
WHERE m.supplier_id IS NULL
  AND s.supplier_id = (
      SELECT s2.supplier_id
      FROM suppliers s2
      ORDER BY s2.supplier_id
      OFFSET ((m.purchase_id - 1) % 
          (SELECT COUNT(*) FROM suppliers))
      LIMIT 1
  );

-- Purchase Order Number
UPDATE material_purchases
SET purchase_order_no =
    'PO-' || TO_CHAR(purchase_date, 'YYYY') || '-' ||
    LPAD(purchase_id::TEXT, 6, '0')
WHERE purchase_order_no IS NULL;

-- Total Quantity: initial value = quantity
UPDATE material_purchases
SET total_quantity = quantity
WHERE total_quantity IS NULL;

-- Discount: purchase value-
UPDATE material_purchases
SET discount_inr = ROUND(
    quantity * unit_price_inr *
    (((purchase_id % 6)::NUMERIC) / 100), 2
)
WHERE discount_inr IS NULL OR discount_inr = 0;

-- Tax: purchase value-ல் 5% முதல் 18% வரை
UPDATE material_purchases
SET tax_inr = ROUND(
    (quantity * unit_price_inr - discount_inr) *
    (CASE
        WHEN purchase_id % 3 = 0 THEN 0.05
        WHEN purchase_id % 3 = 1 THEN 0.12
        ELSE 0.18
    END), 2
)
WHERE tax_inr IS NULL OR tax_inr = 0;




-- Total Amount = Gross amount - Discount + Tax
UPDATE material_purchases
SET total_amount_inr =
    ROUND(quantity * unit_price_inr - discount_inr + tax_inr, 2);

-- Step 1: Check current country counts
SELECT country, COUNT(*) AS supplier_count
FROM suppliers
GROUP BY country
ORDER BY supplier_count DESC;


-- Step 2: Force SUP-1201 to SUP-2000 to international countries
WITH international_locations AS (
    SELECT *
    FROM (VALUES
        (1, 'Asia', 'Japan', 'East Asia', 'Aichi', 'Nagoya'),
        (2, 'Asia', 'South Korea', 'East Asia', 'Gyeonggi', 'Suwon'),
        (3, 'Asia', 'China', 'East Asia', 'Shanghai', 'Shanghai'),
        (4, 'Asia', 'Thailand', 'Southeast Asia', 'Chonburi', 'Chonburi'),
        (5, 'Asia', 'Vietnam', 'Southeast Asia', 'Dong Nai', 'Bien Hoa'),
        (6, 'Europe', 'Germany', 'Central Europe', 'Bavaria', 'Munich'),
        (7, 'Europe', 'United Kingdom', 'Western Europe', 'England', 'Birmingham'),
        (8, 'Europe', 'France', 'Western Europe', 'Lyon', 'Lyon'),
        (9, 'North America', 'United States', 'North America', 'Michigan', 'Detroit'),
        (10, 'North America', 'Mexico', 'North America', 'Puebla', 'Puebla City')
    ) AS x(location_id, continent, country, region, state, city)
)
UPDATE suppliers s
SET
    continent = l.continent,
    country = l.country,
    region = l.region,
    state = l.state,
    city = l.city
FROM international_locations l
WHERE s.supplier_code ~ '^SUP-[0-9]+$'
  AND SUBSTRING(s.supplier_code FROM 5)::INTEGER
      BETWEEN 1201 AND 2000
  AND l.location_id =
      1 + ((SUBSTRING(s.supplier_code FROM 5)::INTEGER - 1201) % 10);



-- Step 3: Verify the result
SELECT country, COUNT(*) AS supplier_count
FROM suppliers
GROUP BY country
ORDER BY supplier_count DESC;



--5.warehouse_inventory_insert.sql

INSERT INTO warehouse_inventory (
    production_id,
    vehicle_id,
    warehouse_name,
    warehouse_location,
    inventory_date,
    stock_in,
    stock_out,
    closing_stock,
    inventory_status
)
SELECT
    pq.production_id,
    pq.vehicle_id,

    CASE
        WHEN s.n % 4 = 0 THEN 'Chennai Central Warehouse'
        WHEN s.n % 4 = 1 THEN 'Sriperumbudur Warehouse'
        WHEN s.n % 4 = 2 THEN 'Hosur Warehouse'
        ELSE 'Bengaluru Distribution Warehouse'
    END,

    CASE
        WHEN s.n % 4 = 0 THEN 'Chennai'
        WHEN s.n % 4 = 1 THEN 'Sriperumbudur'
        WHEN s.n % 4 = 2 THEN 'Hosur'
        ELSE 'Bengaluru'
    END,

    pq.production_date + (s.n % 15),

    pq.produced_quantity,

    (pq.produced_quantity * (s.n % 30)) / 100,

    pq.produced_quantity
        - ((pq.produced_quantity * (s.n % 30)) / 100),

    CASE
        WHEN s.n % 20 = 0 THEN 'Low Stock'
        ELSE 'Available'
    END

FROM generate_series(1, 100000) AS s(n)
JOIN production_quality pq
    ON pq.production_id = s.n;






-- 6: exports_insert.sql

WITH dealer_pool AS (
    SELECT
        dealer_id,
        ROW_NUMBER() OVER (ORDER BY dealer_id) AS rn
    FROM distributors
    WHERE brand_name = 'Hyundai'
),
models AS (
    SELECT
        vehicle_id,
        vehicle_model,
        powertrain,
        vehicle_category,
        transmission_type,
        fuel_type,
        engine_capacity_cc,
        ROW_NUMBER() OVER (ORDER BY vehicle_id) AS rn
    FROM vehicle_master
),
destinations AS (
    SELECT *
    FROM (VALUES
        (1, 'Mexico'),
        (2, 'Saudi Arabia'),
        (3, 'South Africa'),
        (4, 'Nepal'),
        (5, 'Chile'),
        (6, 'Australia'),
        (7, 'New Zealand'),
        (8, 'Oman'),
        (9, 'United Arab Emirates'),
        (10, 'Kuwait'),
        (11, 'Qatar'),
        (12, 'Bahrain'),
        (13, 'Peru'),
        (14, 'Colombia'),
        (15, 'Ecuador'),
        (16, 'Egypt'),
        (17, 'Morocco'),
        (18, 'Philippines'),
        (19, 'Thailand'),
        (20, 'Vietnam')
    ) AS d(rn, country)
),
generated AS (
    SELECT
        n,
        (
            DATE '2021-01-01'
            + FLOOR(RANDOM() * 1826)::INTEGER
        )::DATE AS export_date,
        1 + (n % 20) AS export_quantity,
        8000 + ((n * 97) % 25000) AS unit_price,
        CASE
            WHEN n % 3 = 0 THEN 'Completed'
            WHEN n % 3 = 1 THEN 'In Transit'
            ELSE 'Pending'
        END AS export_status,
        1 + ((n - 1) % 20) AS destination_rn
    FROM generate_series(1, 100000) AS gs(n)
)
INSERT INTO exports (
    dealer_id,
    export_date,
    destination_country,
    vehicle_model,
    export_quantity,
    export_value,
    export_status,
    brand_name,
    model_name,
    unit_price,
    total_price,
    currency,
    port_of_loading,
    shipment_status,
    destination_verification_status,
    powertrain,
    vehicle_category,
    transmission_type,
    fuel_type,
    engine_capacity_cc,
    vehicle_id,
    data_quality_flag,
    calculated_unit_price
)
SELECT
    dp.dealer_id,
    g.export_date,
    dest.country,
    m.vehicle_model,
    g.export_quantity,
    g.export_quantity * g.unit_price,
    g.export_status,
    'Hyundai',
    m.vehicle_model,
    g.unit_price,
    g.export_quantity * g.unit_price,
    'USD',
    'Chennai Port',
    'Simulated',
    'Unverified',
    m.powertrain,
    m.vehicle_category,
    m.transmission_type,
    m.fuel_type,
    m.engine_capacity_cc,
    m.vehicle_id,
    'Simulated',
    g.unit_price
FROM generated g
JOIN dealer_pool dp
    ON dp.rn = 1 + ((g.n - 1) % (
        SELECT COUNT(*) FROM dealer_pool
    ))
JOIN models m
    ON m.rn = 1 + ((g.n - 1) % (
        SELECT COUNT(*) FROM models
    ))
JOIN destinations dest
    ON dest.rn = g.destination_rn;


--7: distributors_insert.sql:


INSERT INTO distributors (
    dealer_code,
    dealer_name,
    dealer_type,
    city,
    state,
    dealer_region,
    dealer_status,
    email_id,
    contact_number,
    country_name,
    continent,
    region,
    brand_name,
    source_url,
    verification_status,
    last_verified_date
)
SELECT
    v.dealer_code,
    v.dealer_name,
    'Distributor',
    v.city,
    v.state,
    v.continent,
    'Active',
    NULL,
    v.contact_number,
    v.country_name,
    v.continent,
    'Asia-Pacific',
    'Hyundai',
    v.source_url,
    'User-provided source',
    CURRENT_DATE
FROM (
    VALUES
    ('HY-AS-PAGO', 'Pago Motors', NULL, NULL,
     '+684-699-9347', 'American Samoa', 'Oceania',
     'https://www.hyundai.com/pacific/en?country=AS'),

    ('HY-BT-BHM', 'Bhutan Hyundai Motors', 'Thimphu', NULL,
     '+975-77770000', 'Bhutan', 'Asia', NULL),

    ('HY-CN-BHMC', 'Beijing Hyundai Motor Company', 'Beijing', NULL,
     '+86-10-8949-0777', 'China', 'Asia',
     'https://www.beijing-hyundai.com.cn/'),

    ('HY-CN-HMG', 'Hyundai Motor Group (China) LTD.', 'Beijing', NULL,
     '+86-10-8453-9666', 'China', 'Asia',
     'https://www.hyundai.com.cn/'),

    ('HY-CN-THB', 'Hyundai Truck & Bus (China)', 'Ziyang',
     'Sichuan Province', '+86-400-100-8555',
     'China', 'Asia', 'https://hyundai-trucknbus.com.cn'),

    ('HY-AU-HMCA', 'Hyundai Motor Company Australia Pty Ltd.',
     'Macquarie Park', 'NSW',
     '+61-2-8873-6000', 'Australia', 'Oceania',
     'https://www.hyundai.com/au/en'),

    ('HY-AU-KUMAR', 'Kumar Motors (Bankstown) Pty Ltd',
     'Bankstown', 'NSW', '+61-2-9738-3456',
     'Australia', 'Oceania', 'https://hyundaitrucks.com.au/'),

    ('HY-BN-SETIA', 'Setia Motors Sdn. Bhd.', 'Beribi', NULL,
     '+673-245-3506', 'Brunei', 'Asia',
     'https://hyundaibrunei.com/'),

    ('HY-TL-ENTREPOSTO', 'Entreposto Auto, S.A.', 'Dili', NULL,
     '+670-723-1481', 'East Timor', 'Asia', NULL),

    ('HY-BD-HNS', 'HNS Automobiles', 'Dhaka', NULL,
     '+988-8403', 'Bangladesh', 'Asia',
     'https://hnsautomobiles.com/hyundai-commercial-vehicle/'),

    ('HY-BD-FAIR', 'Fair Technology Ltd.', 'Dhaka', NULL,
     '+88 09609 505050', 'Bangladesh', 'Asia',
     'https://hyundai-bd.com'),

    ('HY-KH-CAMKO', 'Hyundai Camko Motor Company',
     'Phnom Penh', NULL, '+855-97-755-8133',
     'Cambodia', 'Asia', 'https://www.camko-motor.com'),

    ('HY-FM-BEST', 'Best & Best Motors Inc.',
     'Kolonia', 'Pohnpei', '+691-320-2311',
     'Federated States of Micronesia', 'Oceania', NULL)
) AS v(
    dealer_code,
    dealer_name,
    city,
    state,
    contact_number,
    country_name,
    continent,
    source_url
)
WHERE NOT EXISTS (
    SELECT 1
    FROM distributors d
    WHERE d.dealer_code = v.dealer_code
);



-- 8.customs_clearance_insert.sql

INSERT INTO customs_clearance (
    export_id,
    invoice_number,
    invoice_date,
    invoice_value,
    currency,
    customs_port,
    declaration_date,
    inspection_date,
    clearance_date,
    documentation_status,
    inspection_status,
    clearance_status,
    customs_duty,
    delay_days,
    remarks
)
SELECT
    e.export_id,
    'INV-HY-' || e.export_id,
    e.export_date,
    e.total_price,
    COALESCE(e.currency, 'USD'),
    COALESCE(e.port_of_loading, 'Chennai Port'),
    e.export_date + 1,
    e.export_date + 2,
    e.export_date + 4,
    'Complete',
    'Completed',
    'Cleared',
    ROUND(e.total_price * 0.05, 2),
    0,
    'Simulated record'
FROM exports e
WHERE e.brand_name = 'Hyundai'
  AND e.shipment_status = 'Simulated'
  AND NOT EXISTS (
      SELECT 1
      FROM customs_clearance cc
      WHERE cc.export_id = e.export_id
  );







--9.  logistics_delivery_insert.sql

INSERT INTO logistics_delivery (
    export_id,
    shipment_reference,
    bill_of_lading_number,
    container_number,
    vessel_name,
    shipping_line,
    transport_mode,
    port_of_loading,
    destination_port,
    destination_country,
    booking_date,
    dispatch_date,
    departure_date,
    expected_arrival_date,
    actual_arrival_date,
    customs_release_date,
    warehouse_arrival_date,
    dealer_id,
    dealer_delivery_date,
    delivery_status,
    transit_days,
    delay_days,
    freight_cost,
    currency,
    tracking_number,
    delay_reason,
    remarks,
    record_source,
    verification_status
)
SELECT
    e.export_id,
    'SHP-HY-' || e.export_id,
    'BL-HY-' || e.export_id,
    'CONT-' || LPAD(e.export_id::text, 7, '0'),
    'Ocean Vessel ' || (1 + e.export_id % 20),
    'Global Shipping Line',
    'Sea',
    COALESCE(e.port_of_loading, 'Chennai Port'),
    e.destination_country || ' Port',
    e.destination_country,
    e.export_date,
    e.export_date + 1,
    e.export_date + 2,
    e.export_date + 17,
    e.export_date + 19,
    e.export_date + 20,
    e.export_date + 21,
    e.dealer_id,
    e.export_date + 23,
    'Delivered',
    19,
    2,
    ROUND(e.total_price * 0.02, 2),
    COALESCE(e.currency, 'USD'),
    'TRK-HY-' || e.export_id,
    'Simulated delay',
    'Simulated logistics record',
    'Simulated',
    'Not yet verified'
FROM exports e
WHERE e.brand_name = 'Hyundai'
  AND e.shipment_status = 'Simulated'
  AND NOT EXISTS (
      SELECT 1
      FROM logistics_delivery ld
      WHERE ld.export_id = e.export_id
  );





-- 10 materials_insert.sql


INSERT INTO materials (
    material_code,
    material_name,
    material_category,
    material_specification,
    unit_of_measure,
    material_status
)
SELECT
    'MAT-' || LPAD(n::text, 4, '0'),
    material_name,
    material_category,
    material_specification,
    unit_of_measure,
    'Active'
FROM (
    SELECT
        ROW_NUMBER() OVER () AS n,
        m.*
    FROM (VALUES
        ('Steel', 'Raw Material', 'High-strength automotive steel', 'KG'),
        ('Aluminium', 'Raw Material', 'Automotive-grade aluminium', 'KG'),
        ('Copper', 'Electrical', 'Electrical-grade copper', 'KG'),
        ('Rubber', 'Component Material', 'Automotive-grade synthetic rubber', 'KG'),
        ('Glass', 'Component Material', 'Automotive safety glass', 'PCS'),
        ('Plastic Resin', 'Polymer', 'Automotive-grade polymer resin', 'KG'),
        ('Paint', 'Chemical', 'Automotive body coating paint', 'LITRE'),
        ('Lithium-ion Cell', 'Battery', 'Lithium-ion battery cell', 'PCS'),
        ('Wiring Harness', 'Electrical', 'Automotive wiring harness', 'PCS'),
        ('Seat Fabric', 'Interior', 'Automotive seat upholstery fabric', 'METRE')
    ) AS m(
        material_name,
        material_category,
        material_specification,
        unit_of_measure
    )
) AS material_data
WHERE NOT EXISTS (
    SELECT 1
    FROM materials existing
    WHERE existing.material_code =
          'MAT-' || LPAD(material_data.n::text, 4, '0')
);


-- 1. Check Main Table Row Counts

SELECT 'exports' AS table_name, COUNT(*) AS row_count FROM exports
UNION ALL
SELECT 'distributors', COUNT(*) FROM distributors
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'production_quality', COUNT(*) FROM production_quality
UNION ALL
SELECT 'warehouse_inventory', COUNT(*) FROM warehouse_inventory
UNION ALL
SELECT 'customs_clearance', COUNT(*) FROM customs_clearance
UNION ALL
SELECT 'logistics_delivery', COUNT(*) FROM logistics_delivery
UNION ALL
SELECT 'vehicle_master', COUNT(*) FROM vehicle_master
ORDER BY table_name;





-- 2. Check Export Coverage

SELECT
    brand_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT destination_country) AS countries,
    COUNT(DISTINCT vehicle_model) AS models,
    MIN(export_date) AS first_export_date,
    MAX(export_date) AS last_export_date
FROM exports
GROUP BY brand_name;



--3. Check Duplicate Export Records


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT (
        export_date,
        destination_country,
        vehicle_model,
        export_quantity,
        export_value
    )) AS distinct_records
FROM exports;





-- 4. Identify Potential Duplicate Export Records
SELECT *
FROM exports
WHERE (
    export_date,
    destination_country,
    vehicle_model,
    export_quantity,
    export_value
) IN (
    SELECT
        export_date,
        destination_country,
        vehicle_model,
        export_quantity,
        export_value
    FROM exports
    GROUP BY
        export_date,
        destination_country,
        vehicle_model,
        export_quantity,
        export_value
    HAVING COUNT(*) > 1
)
ORDER BY export_date, destination_country, vehicle_model
LIMIT 10;




-- 5. Check Export Status and Verification

SELECT
    export_status,
    destination_verification_status,
    COUNT(*) AS total_rows,
    SUM(export_quantity) AS total_quantity,
    SUM(export_value) AS total_export_value
FROM exports
GROUP BY
    export_status,
    destination_verification_status
ORDER BY total_rows DESC;




-- 6. Flag Export Records Requiring Verification

ALTER TABLE exports
ADD COLUMN IF NOT EXISTS data_quality_flag VARCHAR(50);

UPDATE exports
SET data_quality_flag = 'Needs Verification'
WHERE export_value = 0
  AND export_status = 'Pending'
  AND destination_verification_status = 'Unverified';

UPDATE exports
SET data_quality_flag = 'Needs Verification'
WHERE destination_verification_status IN (
    'Not yet verified',
    'Unverified'
)
AND data_quality_flag IS NULL;




-- 7. Count Export Data Quality Flags

SELECT
    COALESCE(data_quality_flag, 'Not Flagged') AS quality_status,
    COUNT(*) AS total_rows
FROM exports
GROUP BY 1
ORDER BY 2 DESC;



-- 8. Validate Production Quality Data

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT vehicle_id) AS vehicle_count,
    COUNT(*) FILTER (
        WHERE produced_quantity IS NULL
    ) AS missing_production,
    COUNT(*) FILTER (
        WHERE defect_quantity > produced_quantity
    ) AS invalid_defect_rows,
    COUNT(*) FILTER (
        WHERE rejected_quantity > produced_quantity
    ) AS invalid_rejected_rows,
    MIN(production_date) AS first_date,
    MAX(production_date) AS last_date
FROM production_quality;



-- 9. Validate Production Quantities

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE planned_quantity IS NULL
           OR produced_quantity IS NULL
           OR defect_quantity IS NULL
           OR rejected_quantity IS NULL
    ) AS missing_values,
    COUNT(*) FILTER (
        WHERE planned_quantity < 0
           OR produced_quantity < 0
           OR defect_quantity < 0
           OR rejected_quantity < 0
    ) AS negative_values,
    COUNT(*) FILTER (
        WHERE defect_quantity + rejected_quantity > produced_quantity
    ) AS defect_rejection_exceeds_production
FROM production_quality;




-- 10. Validate Warehouse Inventory

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE stock_in IS NULL
           OR stock_out IS NULL
           OR closing_stock IS NULL
    ) AS missing_values,
    COUNT(*) FILTER (
        WHERE stock_in < 0
           OR stock_out < 0
           OR closing_stock < 0
    ) AS negative_values,
    COUNT(*) FILTER (
        WHERE closing_stock <> stock_in - stock_out
    ) AS stock_mismatch,
    MIN(inventory_date) AS first_date,
    MAX(inventory_date) AS last_date
FROM warehouse_inventory;



-- 11. Validate Customs Clearance

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE export_id IS NULL
    ) AS missing_export_id,
    COUNT(*) FILTER (
        WHERE invoice_value IS NULL
           OR customs_duty IS NULL
    ) AS missing_financial_values,
    COUNT(*) FILTER (
        WHERE invoice_value < 0
           OR customs_duty < 0
           OR delay_days < 0
    ) AS negative_values,
    COUNT(*) FILTER (
        WHERE clearance_date < declaration_date
    ) AS invalid_clearance_dates,
    MIN(declaration_date) AS first_date,
    MAX(declaration_date) AS last_date
FROM customs_clearance;



-- 12. Validate Logistics Delivery

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE export_id IS NULL
    ) AS missing_export_id,
    COUNT(*) FILTER (
        WHERE departure_date IS NOT NULL
          AND actual_arrival_date IS NOT NULL
          AND actual_arrival_date < departure_date
    ) AS invalid_travel_dates,
    COUNT(*) FILTER (
        WHERE transit_days < 0
           OR delay_days < 0
           OR freight_cost < 0
    ) AS negative_values,
    MIN(dispatch_date) AS first_dispatch_date,
    MAX(dispatch_date) AS last_dispatch_date
FROM logistics_delivery;


-- 13. Validate Suppliers

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT supplier_id) AS unique_suppliers,
    COUNT(*) FILTER (
        WHERE supplier_name IS NULL
           OR country IS NULL
    ) AS missing_name_or_country,
    COUNT(*) FILTER (
        WHERE lead_time_days < 0
           OR quality_rating < 0
           OR quality_rating > 5
    ) AS invalid_values,
    MIN(supplier_start_date) AS first_supplier_date,
    MAX(supplier_start_date) AS last_supplier_date
FROM suppliers;




-- 14. Validate Distributors

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT dealer_id) AS unique_distributors,
    COUNT(*) FILTER (
        WHERE dealer_name IS NULL
           OR country_name IS NULL
    ) AS missing_name_or_country,
    COUNT(*) FILTER (
        WHERE brand_name IS NULL
    ) AS missing_brand,
    COUNT(*) FILTER (
        WHERE verification_status IS NULL
           OR source_url IS NULL
    ) AS missing_verification_or_source
FROM distributors;



-- 15. Validate Vehicle Master

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT vehicle_id) AS unique_vehicles,
    COUNT(*) FILTER (
        WHERE vehicle_model IS NULL
    ) AS missing_model,
    COUNT(*) FILTER (
        WHERE vehicle_status IS NULL
    ) AS missing_status,
    COUNT(DISTINCT vehicle_model) AS unique_models
FROM vehicle_master;



-- 16. Check Export Vehicle ID Mapping

SELECT
    COUNT(*) AS total_exports,
    COUNT(*) FILTER (
        WHERE e.vehicle_id IS NULL
    ) AS exports_without_vehicle_id,
    COUNT(*) FILTER (
        WHERE e.vehicle_id IS NOT NULL
          AND v.vehicle_id IS NULL
    ) AS unmatched_vehicle_ids
FROM exports e
LEFT JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id;


-- 17. Check Exports Missing Vehicle ID by Model

SELECT
    vehicle_model,
    COUNT(*) AS missing_vehicle_id_count
FROM exports
WHERE vehicle_id IS NULL
GROUP BY vehicle_model
ORDER BY missing_vehicle_id_count DESC;



-- 18. Check Creta Electric in Vehicle Master

SELECT *
FROM vehicle_master
WHERE vehicle_model = 'Creta Electric';



-- 18. Check Creta Electric Exports Missing Vehicle ID

SELECT
    e.vehicle_model,
    e.vehicle_id,
    COUNT(*) AS total_records
FROM exports e
WHERE e.vehicle_model = 'Creta Electric'
  AND e.vehicle_id IS NULL
GROUP BY e.vehicle_model, e.vehicle_id;



-- 20. Map Creta Electric Exports to Vehicle Master

UPDATE exports e
SET vehicle_id = v.vehicle_id
FROM vehicle_master v
WHERE e.vehicle_model = 'Creta Electric'
  AND e.vehicle_id IS NULL
  AND v.vehicle_model = 'Creta Electric'
  AND v.vehicle_variant = 'Executive';



-- 21. Verify Creta Electric Vehicle ID Mapping

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE vehicle_id IS NULL
    ) AS missing_vehicle_id,
    COUNT(*) FILTER (
        WHERE vehicle_id IS NOT NULL
    ) AS mapped_records
FROM exports
WHERE vehicle_model = 'Creta Electric';


-- 22. Verify Creta Electric Variant Mapping

SELECT
    v.vehicle_id,
    v.vehicle_model,
    v.vehicle_variant,
    COUNT(*) AS export_records
FROM exports e
JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id
WHERE e.vehicle_model = 'Creta Electric'
GROUP BY
    v.vehicle_id,
    v.vehicle_model,
    v.vehicle_variant;


-- 23. Check All Export Vehicle ID Mappings

SELECT
    COUNT(*) AS total_exports,
    COUNT(*) FILTER (
        WHERE e.vehicle_id IS NULL
    ) AS missing_vehicle_id,
    COUNT(*) FILTER (
        WHERE e.vehicle_id IS NOT NULL
          AND v.vehicle_id IS NULL
    ) AS unmatched_vehicle_id
FROM exports e
LEFT JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id;



-- 24. Check Customs Clearance Export ID Mapping

SELECT
    COUNT(*) AS total_customs_records,
    COUNT(*) FILTER (
        WHERE c.export_id IS NULL
    ) AS missing_export_id,
    COUNT(*) FILTER (
        WHERE c.export_id IS NOT NULL
          AND e.export_id IS NULL
    ) AS unmatched_export_id
FROM customs_clearance c
LEFT JOIN exports e
    ON c.export_id = e.export_id;


-- 24. Check Customs Clearance Export ID Mapping

SELECT
    COUNT(*) AS total_customs_records,
    COUNT(*) FILTER (
        WHERE c.export_id IS NULL
    ) AS missing_export_id,
    COUNT(*) FILTER (
        WHERE c.export_id IS NOT NULL
          AND e.export_id IS NULL
    ) AS unmatched_export_id
FROM customs_clearance c
LEFT JOIN exports e
    ON c.export_id = e.export_id;


-- 25. Check Logistics Delivery Export ID Mapping

SELECT
    COUNT(*) AS total_delivery_records,
    COUNT(*) FILTER (
        WHERE l.export_id IS NULL
    ) AS missing_export_id,
    COUNT(*) FILTER (
        WHERE l.export_id IS NOT NULL
          AND e.export_id IS NULL
    ) AS unmatched_export_id
FROM logistics_delivery l
LEFT JOIN exports e
    ON l.export_id = e.export_id;



-- 26. Check Warehouse Inventory Vehicle ID Mapping

SELECT
    COUNT(*) AS total_inventory_records,
    COUNT(*) FILTER (
        WHERE w.vehicle_id IS NULL
    ) AS missing_vehicle_id,
    COUNT(*) FILTER (
        WHERE w.vehicle_id IS NOT NULL
          AND v.vehicle_id IS NULL
    ) AS unmatched_vehicle_id
FROM warehouse_inventory w
LEFT JOIN vehicle_master v
    ON w.vehicle_id = v.vehicle_id;




-- 27. Check Production Quality Vehicle ID Mapping

SELECT
    COUNT(*) AS total_production_records,
    COUNT(*) FILTER (
        WHERE p.vehicle_id IS NULL
    ) AS missing_vehicle_id,
    COUNT(*) FILTER (
        WHERE p.vehicle_id IS NOT NULL
          AND v.vehicle_id IS NULL
    ) AS unmatched_vehicle_id
FROM production_quality p
LEFT JOIN vehicle_master v
    ON p.vehicle_id = v.vehicle_id;



-- 28. Check Warehouse Production ID Mapping

SELECT
    COUNT(*) AS total_inventory_records,
    COUNT(*) FILTER (
        WHERE w.production_id IS NULL
    ) AS missing_production_id,
    COUNT(*) FILTER (
        WHERE w.production_id IS NOT NULL
          AND p.production_id IS NULL
    ) AS unmatched_production_id
FROM warehouse_inventory w
LEFT JOIN production_quality p
    ON w.production_id = p.production_id;



-- 29. Check Logistics Delivery Distributor ID Mapping

SELECT
    COUNT(*) AS total_delivery_records,
    COUNT(*) FILTER (
        WHERE l.dealer_id IS NULL
    ) AS missing_dealer_id,
    COUNT(*) FILTER (
        WHERE l.dealer_id IS NOT NULL
          AND d.dealer_id IS NULL
    ) AS unmatched_dealer_id
FROM logistics_delivery l
LEFT JOIN distributors d
    ON l.dealer_id = d.dealer_id;




-- 30. Check Exports Distributor ID Mapping

SELECT
    COUNT(*) AS total_export_records,
    COUNT(*) FILTER (
        WHERE e.dealer_id IS NULL
    ) AS missing_dealer_id,
    COUNT(*) FILTER (
        WHERE e.dealer_id IS NOT NULL
          AND d.dealer_id IS NULL
    ) AS unmatched_dealer_id
FROM exports e
LEFT JOIN distributors d
    ON e.dealer_id = d.dealer_id;


-- 31. Check Export Model Consistency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE e.vehicle_model IS DISTINCT FROM v.vehicle_model
    ) AS model_mismatch
FROM exports e
JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id;



-- 32. Investigate Export Model Mismatches

SELECT
    e.export_id,
    e.vehicle_model AS export_model,
    e.vehicle_id,
    v.vehicle_model AS master_model,
    v.vehicle_variant
FROM exports e
JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id
WHERE e.vehicle_model IS DISTINCT FROM v.vehicle_model
LIMIT 20;



-- 33. Check Export Model and Variant Mismatches

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE e.vehicle_model = v.vehicle_variant
    ) AS model_column_contains_variant,
    COUNT(*) FILTER (
        WHERE e.vehicle_model <> v.vehicle_model
          AND e.vehicle_model <> v.vehicle_variant
    ) AS other_mismatches
FROM exports e
JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id;






-- 34. Fix Export Vehicle Model Names

UPDATE exports e
SET vehicle_model = v.vehicle_model
FROM vehicle_master v
WHERE e.vehicle_id = v.vehicle_id
  AND e.vehicle_model = v.vehicle_variant
  AND e.vehicle_model <> v.vehicle_model;

SELECT COUNT(*) AS model_mismatch
FROM exports e
JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id
WHERE e.vehicle_model IS DISTINCT FROM v.vehicle_model;




-- 35. Check Export Model Name Consistency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE model_name IS NULL
    ) AS missing_model_name,
    COUNT(*) FILTER (
        WHERE model_name IS DISTINCT FROM vehicle_model
    ) AS model_name_mismatch
FROM exports;


-- 36. Check Export Value and Total Price

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE export_value IS NULL
    ) AS missing_export_value,
    COUNT(*) FILTER (
        WHERE total_price IS NULL
    ) AS missing_total_price,
    COUNT(*) FILTER (
        WHERE export_value IS DISTINCT FROM total_price
    ) AS value_mismatch
FROM exports;




-- 37. Check Export Quantity and Unit Price Calculation

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE export_quantity IS NULL
           OR unit_price IS NULL
    ) AS missing_values,
    COUNT(*) FILTER (
        WHERE ROUND(export_quantity * unit_price, 2)
              IS DISTINCT FROM ROUND(total_price, 2)
    ) AS calculation_mismatch
FROM exports;



-- 38. Investigate Export Price Mismatches

SELECT
    export_id,
    export_quantity,
    unit_price,
    total_price,
    export_value,
    ROUND(export_quantity * unit_price, 2) AS calculated_price
FROM exports
WHERE ROUND(export_quantity * unit_price, 2)
      IS DISTINCT FROM ROUND(total_price, 2)
LIMIT 20;


- 39. Check Price Multiplier Pattern

SELECT
    export_quantity,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE unit_price > 0
          AND total_price / unit_price = 20
    ) AS records_with_20x_price
FROM exports
WHERE unit_price > 0
GROUP BY export_quantity
ORDER BY export_quantity;



-- 40. Check Export Price Calculation Patterns

SELECT
    export_quantity,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE ROUND(export_quantity * unit_price, 2)
              = ROUND(total_price, 2)
    ) AS quantity_price_matches,
    COUNT(*) FILTER (
        WHERE ROUND(20 * unit_price, 2)
              = ROUND(total_price, 2)
    ) AS twenty_times_price_matches
FROM exports
GROUP BY export_quantity
ORDER BY export_quantity;




-- 41. Compare Export Price Fields by Quantity

SELECT
    export_quantity,
    COUNT(*) AS total_records,
    MIN(unit_price) AS min_unit_price,
    MIN(total_price) AS min_total_price,
    MIN(export_value) AS min_export_value,
    MAX(total_price) AS max_total_price,
    MAX(export_value) AS max_export_value
FROM exports
GROUP BY export_quantity
ORDER BY export_quantity;




-- 42. Check Unit Price Consistency

SELECT
    export_quantity,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE export_quantity > 0
          AND ROUND(total_price / export_quantity, 2)
              = ROUND(unit_price, 2)
    ) AS correct_unit_price,
    COUNT(*) FILTER (
        WHERE export_quantity > 0
          AND ROUND(total_price / export_quantity, 2)
              <> ROUND(unit_price, 2)
    ) AS unit_price_mismatch
FROM exports
GROUP BY export_quantity
ORDER BY export_quantity;-



-- 43. Inspect Export Price Record

SELECT
    export_id,
    export_date,
    destination_country,
    vehicle_model,
    export_quantity,
    unit_price,
    total_price,
    export_value,
    currency,
    export_status,
    destination_verification_status
FROM exports
WHERE export_id = 46013;



-- 44. Check Price Mismatches by Verification Status

SELECT
    destination_verification_status,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE ROUND(export_quantity * unit_price, 2)
              <> ROUND(total_price, 2)
    ) AS price_mismatches
FROM exports
GROUP BY destination_verification_status
ORDER BY destination_verification_status;





-- 45. Calculate Unit Price from Total Price

SELECT
    export_id,
    export_quantity,
    total_price,
    ROUND(total_price / NULLIF(export_quantity, 0), 2)
        AS calculated_unit_price,
    unit_price AS original_unit_price
FROM exports
WHERE export_quantity > 0
  AND ROUND(total_price / export_quantity, 2)
      IS DISTINCT FROM ROUND(unit_price, 2)
ORDER BY export_id
LIMIT 20;


-- 46. Add Calculated Unit Price Column

ALTER TABLE exports
ADD COLUMN IF NOT EXISTS calculated_unit_price NUMERIC(12,2);

UPDATE exports
SET calculated_unit_price =
    ROUND(total_price / NULLIF(export_quantity, 0), 2)
WHERE export_quantity > 0;



- 47. Verify Calculated Unit Price

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE calculated_unit_price IS NULL
    ) AS missing_calculated_price,
    COUNT(*) FILTER (
        WHERE calculated_unit_price <>
              ROUND(total_price / NULLIF(export_quantity, 0), 2)
    ) AS calculation_mismatch
FROM exports;



-- 49. Check Export Quantity and Price Validity

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE total_price IS NULL OR total_price < 0
    ) AS invalid_total_price,
    COUNT(*) FILTER (
        WHERE unit_price IS NULL OR unit_price <= 0
    ) AS invalid_unit_price,
    COUNT(*) FILTER (
        WHERE calculated_unit_price <= 0
    ) AS invalid_calculated_price
FROM exports;





-- 50. Identify Invalid Unit Price Records

SELECT
    export_id,
    vehicle_model,
    export_quantity,
    unit_price,
    total_price,
    calculated_unit_price,
    destination_verification_status
FROM exports
WHERE unit_price IS NULL
   OR unit_price <= 0
   OR calculated_unit_price <= 0
ORDER BY export_id
LIMIT 20;



-- 51. Check Unverified Creta Electric Records

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE export_quantity = 1
    ) AS quantity_one_records,
    SUM(export_quantity) AS total_quantity,
    SUM(total_price) AS total_export_value
FROM exports
WHERE vehicle_model = 'Creta Electric'
  AND destination_verification_status = 'Unverified';




-- 52. Flag Unverified Creta Electric Records

UPDATE exports
SET data_quality_flag = 'Needs Verification'
WHERE vehicle_model = 'Creta Electric'
  AND destination_verification_status = 'Unverified'
  AND export_quantity = 1
  AND total_price = 0;



-- 53. Verify Creta Electric Price Flags

SELECT
    data_quality_flag,
    destination_verification_status,
    COUNT(*) AS total_records,
    SUM(total_price) AS total_export_value
FROM exports
WHERE vehicle_model = 'Creta Electric'
  AND destination_verification_status = 'Unverified'
GROUP BY
    data_quality_flag,
    destination_verification_status;



-- 54. Check Duplicate Export Records

SELECT
    COUNT(*) AS duplicate_groups,
    COALESCE(SUM(record_count - 1), 0) AS extra_duplicate_records
FROM (
    SELECT COUNT(*) AS record_count
    FROM exports
    GROUP BY
        export_date,
        destination_country,
        vehicle_model,
        export_quantity,
        total_price
    HAVING COUNT(*) > 1
) duplicates;





-- 55. Identify Duplicate Export Records

SELECT
    export_date,
    destination_country,
    vehicle_model,
    export_quantity,
    total_price,
    COUNT(*) AS record_count,
    ARRAY_AGG(export_id ORDER BY export_id) AS export_ids
FROM exports
GROUP BY
    export_date,
    destination_country,
    vehicle_model,
    export_quantity,
    total_price
HAVING COUNT(*) > 1
ORDER BY record_count DESC;


- 56. Review Potential Duplicate Exports

SELECT *
FROM exports
WHERE export_id IN (100006, 100007, 100008)
ORDER BY export_id;




-- 57. Compare Potential Duplicate Export Records

SELECT
    e1.export_id AS first_id,
    e2.export_id AS second_id,
    (to_jsonb(e1) - 'export_id')
        = (to_jsonb(e2) - 'export_id') AS all_other_columns_identical
FROM exports e1
JOIN exports e2
    ON e1.export_id = 100007
   AND e2.export_id = 100008;




-- 58. Check References to Potential Duplicate Exports

SELECT
    'customs_clearance' AS table_name,
    COUNT(*) AS reference_count
FROM customs_clearance
WHERE export_id IN (100007, 100008)

UNION ALL

SELECT
    'logistics_delivery',
    COUNT(*)
FROM logistics_delivery
WHERE export_id IN (100007, 100008);




-- 59. Summarize Potential Duplicate Export Groups

SELECT
    destination_country,
    vehicle_model,
    COUNT(*) AS duplicate_groups,
    SUM(record_count - 1) AS extra_records
FROM (
    SELECT
        destination_country,
        vehicle_model,
        export_date,
        export_quantity,
        total_price,
        COUNT(*) AS record_count
    FROM exports
    GROUP BY
        destination_country,
        vehicle_model,
        export_date,
        export_quantity,
        total_price
    HAVING COUNT(*) > 1
) d
GROUP BY destination_country, vehicle_model
ORDER BY extra_records DESC;



-- 60. Check Duplicate Export IDs

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT export_id) AS unique_export_ids,
    COUNT(*) - COUNT(DISTINCT export_id) AS duplicate_ids
FROM exports;



-- 61. Check Missing Export Date and Destination

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE export_date IS NULL
    ) AS missing_export_date,
    COUNT(*) FILTER (
        WHERE destination_country IS NULL
           OR TRIM(destination_country) = ''
    ) AS missing_destination
FROM exports;



-- 62. Check Export Status Values

SELECT
    export_status,
    COUNT(*) AS total_records
FROM exports
GROUP BY export_status
ORDER BY total_records DESC;



-- 63. Check Shipment Status Values

SELECT
    shipment_status,
    COUNT(*) AS total_records
FROM exports
GROUP BY shipment_status
ORDER BY total_records DESC NULLS FIRST;






-- 64. Identify Missing Shipment Status

SELECT
    export_id,
    export_date,
    destination_country,
    vehicle_model,
    export_status,
    shipment_status,
    destination_verification_status,
    data_quality_flag
FROM exports
WHERE shipment_status IS NULL;



-- 65. Flag Missing Shipment Status

UPDATE exports
SET data_quality_flag = 'Needs Verification'
WHERE shipment_status IS NULL
  AND data_quality_flag IS NULL;



-- 66. Check Export and Shipment Status Consistency

SELECT
    export_status,
    shipment_status,
    COUNT(*) AS total_records
FROM exports
GROUP BY export_status, shipment_status
ORDER BY export_status, shipment_status NULLS FIRST;




-- 67. Export Status vs Verification Status

SELECT
    export_status,
    destination_verification_status,
    COUNT(*) AS total_records
FROM exports
GROUP BY
    export_status,
    destination_verification_status
ORDER BY export_status, destination_verification_status;


-- 68. Check Invalid Export Quantity and Values

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE export_quantity IS NULL OR export_quantity <= 0
    ) AS invalid_quantity,
    COUNT(*) FILTER (
        WHERE export_value IS NULL OR export_value < 0
    ) AS invalid_export_value,
    COUNT(*) FILTER (
        WHERE unit_price < 0
    ) AS negative_unit_price
FROM exports;



-- 69. Check Export Currency

SELECT
    currency,
    COUNT(*) AS total_records
FROM exports
GROUP BY currency
ORDER BY total_records DESC NULLS FIRST;




-- 70. Check Missing Price Fields

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (WHERE unit_price IS NULL) AS missing_unit_price,
    COUNT(*) FILTER (WHERE total_price IS NULL) AS missing_total_price,
    COUNT(*) FILTER (WHERE calculated_unit_price IS NULL) AS missing_calculated_price
FROM exports;




-- 71. Export Records by Year

SELECT
    EXTRACT(YEAR FROM export_date) AS export_year,
    COUNT(*) AS total_records,
    SUM(export_quantity) AS total_quantity,
    SUM(export_value) AS total_export_value
FROM exports
GROUP BY EXTRACT(YEAR FROM export_date)
ORDER BY export_year;



-- 72. Destination Country-wise Export Summary

SELECT
    destination_country,
    COUNT(*) AS total_records,
    SUM(export_quantity) AS total_quantity,
    SUM(export_value) AS total_export_value
FROM exports
GROUP BY destination_country
ORDER BY total_export_value DESC
LIMIT 20;





-- 73. Vehicle Model-wise Export Summary

SELECT
    vehicle_model,
    COUNT(*) AS total_records,
    SUM(export_quantity) AS total_quantity,
    SUM(export_value) AS total_export_value
FROM exports
GROUP BY vehicle_model
ORDER BY total_quantity DESC;



- 74. Vehicle Model and Powertrain Consistency

SELECT
    e.vehicle_model,
    e.powertrain,
    COUNT(*) AS total_records
FROM exports e
GROUP BY e.vehicle_model, e.powertrain
ORDER BY e.vehicle_model, e.powertrain;




-- 75. Check Model and Transmission Type

SELECT
    vehicle_model,
    transmission_type,
    COUNT(*) AS total_records
FROM exports
GROUP BY vehicle_model, transmission_type
ORDER BY vehicle_model, transmission_type;



-- 76. Check Vehicle Category Distribution

SELECT
    vehicle_model,
    vehicle_category,
    COUNT(*) AS total_records
FROM exports
GROUP BY vehicle_model, vehicle_category
ORDER BY vehicle_model, vehicle_category;



-- 77. Check Port of Loading Distribution

SELECT
    port_of_loading,
    COUNT(*) AS total_records,
    SUM(export_quantity) AS total_quantity
FROM exports
GROUP BY port_of_loading
ORDER BY total_records DESC NULLS FIRST;




-- 78. Identify Missing Port of Loading

SELECT
    export_id,
    export_date,
    destination_country,
    vehicle_model,
    export_status,
    shipment_status,
    data_quality_flag
FROM exports
WHERE port_of_loading IS NULL
   OR TRIM(port_of_loading) = '';



-- 79. Check Destination Country Coverage

SELECT
    COUNT(DISTINCT destination_country) AS unique_countries,
    COUNT(*) FILTER (
        WHERE destination_country IS NULL
           OR TRIM(destination_country) = ''
    ) AS missing_country_records
FROM exports;


-- 80. Check Export Date Range and Future Dates

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE export_date IS NULL
    ) AS missing_export_date,
    COUNT(*) FILTER (
        WHERE export_date > CURRENT_DATE
    ) AS future_export_dates,
    MIN(export_date) AS first_export_date,
    MAX(export_date) AS last_export_date
FROM exports;




-- 81. Check Exports Foreign Key Mapping

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE e.vehicle_id IS NULL
    ) AS missing_vehicle_id,
    COUNT(*) FILTER (
        WHERE e.vehicle_id IS NOT NULL
          AND v.vehicle_id IS NULL
    ) AS unmatched_vehicle_id,
    COUNT(*) FILTER (
        WHERE e.dealer_id IS NOT NULL
          AND d.dealer_id IS NULL
    ) AS unmatched_dealer_id
FROM exports e
LEFT JOIN vehicle_master v
    ON e.vehicle_id = v.vehicle_id
LEFT JOIN distributors d
    ON e.dealer_id = d.dealer_id;



-- 82. Check Customs Clearance Date Consistency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE invoice_date > declaration_date
    ) AS invoice_after_declaration,
    COUNT(*) FILTER (
        WHERE declaration_date > inspection_date
    ) AS declaration_after_inspection,
    COUNT(*) FILTER (
        WHERE inspection_date > clearance_date
    ) AS inspection_after_clearance
FROM customs_clearance;


-- 83. Check Logistics Delivery Date Consistency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE dispatch_date > departure_date
    ) AS dispatch_after_departure,
    COUNT(*) FILTER (
        WHERE departure_date > expected_arrival_date
    ) AS departure_after_expected_arrival,
    COUNT(*) FILTER (
        WHERE actual_arrival_date > dealer_delivery_date
    ) AS arrival_after_dealer_delivery
FROM logistics_delivery;



-- 84. Inspect Arrival and Dealer Delivery Date Issues

SELECT
    export_id,
    dispatch_date,
    departure_date,
    expected_arrival_date,
    actual_arrival_date,
    warehouse_arrival_date,
    dealer_delivery_date
FROM logistics_delivery
WHERE actual_arrival_date > dealer_delivery_date
LIMIT 10;



-- 85. Check Logistics Date Order Issues

SELECT
    COUNT(*) FILTER (
        WHERE expected_arrival_date < departure_date
    ) AS expected_before_departure,
    COUNT(*) FILTER (
        WHERE actual_arrival_date < departure_date
    ) AS actual_before_departure,
    COUNT(*) FILTER (
        WHERE warehouse_arrival_date < departure_date
    ) AS warehouse_before_departure,
    COUNT(*) FILTER (
        WHERE dealer_delivery_date < warehouse_arrival_date
    ) AS dealer_delivery_before_warehouse
FROM logistics_delivery;





-- 86. Check Production Quality Date Consistency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE inspection_date < production_date
    ) AS inspection_before_production,
    COUNT(*) FILTER (
        WHERE model_year < EXTRACT(YEAR FROM production_date)
    ) AS model_year_before_production
FROM production_quality;





-- 87. Check Production Quantity Consistency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE produced_quantity > planned_quantity
    ) AS produced_above_planned,
    COUNT(*) FILTER (
        WHERE defect_quantity + rejected_quantity > produced_quantity
    ) AS defect_rejected_above_produced,
    COUNT(*) FILTER (
        WHERE inspected_quantity > produced_quantity
    ) AS inspected_above_produced
FROM production_quality;




-- 88. Check Warehouse Inventory Consistency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE stock_in < 0
    ) AS negative_stock_in,
    COUNT(*) FILTER (
        WHERE stock_out < 0
    ) AS negative_stock_out,
    COUNT(*) FILTER (
        WHERE closing_stock <> stock_in - stock_out
    ) AS closing_stock_mismatch,
    COUNT(*) FILTER (
        WHERE closing_stock < 0
    ) AS negative_closing_stock
FROM warehouse_inventory;




-- 89. Check Supplier Data Quality

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE supplier_name IS NULL
           OR TRIM(supplier_name) = ''
    ) AS missing_supplier_name,
    COUNT(*) FILTER (
        WHERE country IS NULL
           OR TRIM(country) = ''
    ) AS missing_country,
    COUNT(*) FILTER (
        WHERE lead_time_days < 0
    ) AS invalid_lead_time,
    COUNT(*) FILTER (
        WHERE quality_rating < 0
           OR quality_rating > 5
    ) AS invalid_quality_rating
FROM suppliers;




-- 90. Check Distributor Data Quality

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE dealer_name IS NULL
           OR TRIM(dealer_name) = ''
    ) AS missing_name,
    COUNT(*) FILTER (
        WHERE country_name IS NULL
           OR TRIM(country_name) = ''
    ) AS missing_country,
    COUNT(*) FILTER (
        WHERE brand_name IS NULL
           OR TRIM(brand_name) = ''
    ) AS missing_brand,
    COUNT(*) FILTER (
        WHERE source_url IS NULL
           OR TRIM(source_url) = ''
    ) AS missing_source_url
FROM distributors;




-- 91. Check Vehicle Master Data Quality

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE vehicle_model IS NULL
           OR TRIM(vehicle_model) = ''
    ) AS missing_model,
    COUNT(*) FILTER (
        WHERE vehicle_category IS NULL
           OR TRIM(vehicle_category) = ''
    ) AS missing_category,
    COUNT(*) FILTER (
        WHERE vehicle_status IS NULL
           OR TRIM(vehicle_status) = ''
    ) AS missing_status,
    COUNT(*) FILTER (
        WHERE engine_capacity_cc < 0
    ) AS invalid_engine_capacity
FROM vehicle_master;



-- 92. Final Table Record Count Summary

SELECT 'exports' AS table_name, COUNT(*) AS total_records FROM exports
UNION ALL
SELECT 'production_quality', COUNT(*) FROM production_quality
UNION ALL
SELECT 'warehouse_inventory', COUNT(*) FROM warehouse_inventory
UNION ALL
SELECT 'customs_clearance', COUNT(*) FROM customs_clearance
UNION ALL
SELECT 'logistics_delivery', COUNT(*) FROM logistics_delivery
UNION ALL
SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL
SELECT 'distributors', COUNT(*) FROM distributors
UNION ALL
SELECT 'vehicle_master', COUNT(*) FROM vehicle_master
ORDER BY table_name;




-- 93. Inspect Dealer Delivery Before Warehouse Arrival

SELECT
    COUNT(*) AS affected_records,
    COUNT(*) FILTER (
        WHERE dealer_delivery_date IS NULL
    ) AS missing_dealer_delivery,
    COUNT(*) FILTER (
        WHERE warehouse_arrival_date IS NULL
    ) AS missing_warehouse_arrival,
    MIN(warehouse_arrival_date - dealer_delivery_date)
        AS minimum_date_difference,
    MAX(warehouse_arrival_date - dealer_delivery_date)
        AS maximum_date_difference
FROM logistics_delivery
WHERE dealer_delivery_date < warehouse_arrival_date;




-- 94. Inspect Actual Arrival and Dealer Delivery Dates

SELECT
    COUNT(*) AS affected_records,
    MIN(actual_arrival_date - dealer_delivery_date)
        AS minimum_date_difference,
    MAX(actual_arrival_date - dealer_delivery_date)
        AS maximum_date_difference,
    COUNT(*) FILTER (
        WHERE actual_arrival_date = dealer_delivery_date + 1
    ) AS exactly_one_day_later
FROM logistics_delivery
WHERE actual_arrival_date > dealer_delivery_date;




-- 95. Check Missing Dates in Logistics Delivery

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (WHERE dispatch_date IS NULL) AS missing_dispatch_date,
    COUNT(*) FILTER (WHERE departure_date IS NULL) AS missing_departure_date,
    COUNT(*) FILTER (WHERE expected_arrival_date IS NULL) AS missing_expected_arrival,
    COUNT(*) FILTER (WHERE actual_arrival_date IS NULL) AS missing_actual_arrival,
    COUNT(*) FILTER (WHERE warehouse_arrival_date IS NULL) AS missing_warehouse_arrival,
    COUNT(*) FILTER (WHERE dealer_delivery_date IS NULL) AS missing_dealer_delivery
FROM logistics_delivery;




96. actual column



SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'logistics_delivery'
ORDER BY ordinal_position;



-- 96. Check Missing Arrival Dates by Delivery Status

SELECT
    delivery_status,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NULL
    ) AS missing_actual_arrival,
    COUNT(*) FILTER (
        WHERE warehouse_arrival_date IS NULL
    ) AS missing_warehouse_arrival,
    COUNT(*) FILTER (
        WHERE dealer_delivery_date IS NULL
    ) AS missing_dealer_delivery
FROM logistics_delivery
GROUP BY delivery_status
ORDER BY delivery_status;




-- 97. Check Delivery Status Against Delivery Dates

SELECT
    delivery_status,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE dealer_delivery_date IS NOT NULL
    ) AS has_dealer_delivery_date,
    COUNT(*) FILTER (
        WHERE dealer_delivery_date IS NULL
    ) AS missing_dealer_delivery_date,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NOT NULL
    ) AS has_actual_arrival_date
FROM logistics_delivery
GROUP BY delivery_status
ORDER BY delivery_status;



-- 98. Check Invalid Transit and Delay Days

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE transit_days < 0
    ) AS negative_transit_days,
    COUNT(*) FILTER (
        WHERE delay_days < 0
    ) AS negative_delay_days,
    COUNT(*) FILTER (
        WHERE transit_days IS NULL
    ) AS missing_transit_days,
    COUNT(*) FILTER (
        WHERE delay_days IS NULL
    ) AS missing_delay_days
FROM logistics_delivery;



-- 99. Check Transit Days Against Dispatch and Arrival Dates

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NOT NULL
          AND transit_days <> actual_arrival_date - dispatch_date
    ) AS transit_days_mismatch,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NULL
          AND transit_days IS NOT NULL
    ) AS transit_days_without_arrival
FROM logistics_delivery;



-- 100. Check Delay Days Against Arrival Dates

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NOT NULL
          AND delay_days <>
              GREATEST(actual_arrival_date - expected_arrival_date, 0)
    ) AS delay_days_mismatch,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NULL
          AND delay_days IS NOT NULL
    ) AS delay_days_without_arrival
FROM logistics_delivery;




-- 101. Check Customs Release vs Actual Arrival

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE customs_release_date < actual_arrival_date
    ) AS customs_released_before_arrival,
    COUNT(*) FILTER (
        WHERE customs_release_date > actual_arrival_date
    ) AS customs_released_after_arrival,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NOT NULL
          AND customs_release_date IS NULL
    ) AS missing_customs_release
FROM logistics_delivery;



-- 101. Check Customs Release vs Actual Arrival

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE customs_release_date < actual_arrival_date
    ) AS customs_released_before_arrival,
    COUNT(*) FILTER (
        WHERE customs_release_date > actual_arrival_date
    ) AS customs_released_after_arrival,
    COUNT(*) FILTER (
        WHERE actual_arrival_date IS NOT NULL
          AND customs_release_date IS NULL
    ) AS missing_customs_release
FROM logistics_delivery;


-- 102. Check Booking Date vs Dispatch Date

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE booking_date > dispatch_date
    ) AS booking_after_dispatch,
    COUNT(*) FILTER (
        WHERE booking_date IS NULL
    ) AS missing_booking_date,
    COUNT(*) FILTER (
        WHERE dispatch_date IS NULL
    ) AS missing_dispatch_date
FROM logistics_delivery;



-- 103. Check Freight Cost and Currency

SELECT
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE freight_cost IS NULL OR freight_cost <= 0
    ) AS invalid_freight_cost,
    COUNT(*) FILTER (
        WHERE currency IS NULL OR TRIM(currency) = ''
    ) AS missing_currency,
    COUNT(DISTINCT currency) AS currency_types
FROM logistics_delivery;




-- 104. Check Duplicate Shipment References

SELECT
    COUNT(*) AS duplicate_reference_groups,
    COALESCE(SUM(record_count - 1), 0) AS extra_duplicate_records
FROM (
    SELECT shipment_reference, COUNT(*) AS record_count
    FROM logistics_delivery
    WHERE shipment_reference IS NOT NULL
    GROUP BY shipment_reference
    HAVING COUNT(*) > 1
) AS duplicates;



-- 105. Check Duplicate Bill of Lading Numbers

SELECT
    COUNT(*) AS duplicate_groups,
    COALESCE(SUM(record_count - 1), 0) AS extra_duplicate_records
FROM (
    SELECT bill_of_lading_number, COUNT(*) AS record_count
    FROM logistics_delivery
    WHERE bill_of_lading_number IS NOT NULL
      AND TRIM(bill_of_lading_number) <> ''
    GROUP BY bill_of_lading_number
    HAVING COUNT(*) > 1
) AS duplicates;

-- 106. Correct Transit Days for Arrived Shipments

UPDATE logistics_delivery
SET transit_days = actual_arrival_date - departure_date
WHERE actual_arrival_date IS NOT NULL
  AND departure_date IS NOT NULL
  AND transit_days IS DISTINCT FROM
      (actual_arrival_date - departure_date);

-- Transit Days Correction
-- Updated 68,071 records.
-- Calculation: actual_arrival_date - departure_date
-- Other date issues are pending review