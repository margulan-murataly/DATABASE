CREATE TABLE Airline_info (
    airline_id INT PRIMARY KEY,
    airline_code VARCHAR(30) NOT NULL,
    airline_name VARCHAR(50) NOT NULL,
    airline_country VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    info VARCHAR(50)
);

CREATE TABLE Airport (
    airport_id INT PRIMARY KEY,
    airport_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    state VARCHAR(50),
    city VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
);

CREATE TABLE Baggage_check (
    baggage_check_id INT PRIMARY KEY,
    check_result VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    booking_id INT NOT NULL,
    passenger_id INT NOT NULL
);

CREATE TABLE Boarding_pass (
    boarding_pass_id INT PRIMARY KEY,
    booking_id INT NOT NULL,
    seat VARCHAR(50) NOT NULL,
    boarding_time TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
);

CREATE TABLE Booking_flight (
    booking_flight_id INT PRIMARY KEY,
    booking_id INT NOT NULL,
    flight_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
);

CREATE TABLE Booking (
    booking_id INT PRIMARY KEY,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    booking_platform VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    price DECIMAL(7,2) NOT NULL
);

CREATE TABLE Flights (
    flight_id INT PRIMARY KEY,
    sch_departure_time TIMESTAMP NOT NULL,
    sch_arrival_time TIMESTAMP NOT NULL,
    departing_airport_id INT NOT NULL,
    arriving_airport_id INT NOT NULL,
    departing_gate VARCHAR(50),
    arriving_gate VARCHAR(50),
    airline_id INT NOT NULL,
    act_departure_time TIMESTAMP,
    act_arrival_time TIMESTAMP,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
);

CREATE TABLE Passengers (
    passenger_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(50),
    country_of_citizenship VARCHAR(50) NOT NULL,
    country_of_residence VARCHAR(50),
    passport_number VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP
);

CREATE TABLE Security_check (
    security_check_id INT PRIMARY KEY,
    check_result VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP,
    passenger_id INT NOT NULL
);

ALTER TABLE airline_info
RENAME TO airline;

ALTER TABLE booking
RENAME COLUMN price TO ticket_price;

ALTER TABLE flights
ALTER COLUMN departing_gate TYPE text;

ALTER TABLE airline
DROP COLUMN info;

ALTER TABLE Security_check
ADD CONSTRAINT fkk_security_passenger
FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id);

ALTER TABLE Booking
ADD CONSTRAINT fkk_booking_passenger
FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id);

ALTER TABLE Baggage_check
ADD CONSTRAINT fkk_baggage_passenger
FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id);




ALTER TABLE Baggage_check
ADD CONSTRAINT fkk_baggagecheck_booking
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);

ALTER TABLE Boarding_pass
ADD CONSTRAINT fkk_boardingpass_booking
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);

ALTER TABLE Booking_flight
ADD CONSTRAINT fk_bookingflight_booking
FOREIGN KEY (booking_id) REFERENCES Booking(booking_id);





ALTER TABLE booking_flight
ADD CONSTRAINT fk_bookingflight_flight
FOREIGN KEY (flight_id) REFERENCES flights(flight_id);

ALTER TABLE flights
ADD CONSTRAINT fk_flights_departing_airport
FOREIGN KEY (departing_airport_id) REFERENCES airport(airport_id);

ALTER TABLE flights
ADD CONSTRAINT fk_flights_arriving_airport
FOREIGN KEY (arriving_airport_id) REFERENCES airport(airport_id);

ALTER TABLE flights
ADD CONSTRAINT fk_flights_airline
FOREIGN KEY (airline_id) REFERENCES airline(airline_id);










INSERT INTO passengers (
    passenger_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    country_of_citizenship,
    country_of_residence,
    passport_number,
    created_at,
    updated_at
)
SELECT
    g,
    'Name_' || g,
    'Surname_' || g,
    DATE '1980-01-01' + (g % 1000),
    CASE WHEN g % 2 = 0 THEN 'Male' ELSE 'Female' END,
    'Country_' || (g % 50),
    'Country_' || (g % 50),
    'P' || lpad(g::text, 8, '0'),
    NOW(),
    NOW()
FROM generate_series(1, 200) g;




INSERT INTO airline
VALUES (1, 'KZ001', 'KazAir', 'Kazakhstan', NOW(), NOW());

UPDATE airline
SET airline_country = 'Turkey',
    updated_at = NOW()
WHERE airline_name = 'KazAir';

INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES
    (2, 'AE001', 'AirEasy', 'France', NOW(), NOW()),
    (3, 'FH001', 'FlyHigh', 'Brazil', NOW(), NOW()),
    (4, 'FF001', 'FlyFly', 'Poland', NOW(), NOW());






DELETE FROM flights
WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024;







INSERT INTO booking (
    booking_id, flight_id, passenger_id, booking_platform,
    created_at, updated_at, status, ticket_price
)
SELECT
    g,
    (g % 50) + 1,
    (g % 50) + 1,
    CASE WHEN g % 3 = 0 THEN 'Website'
         WHEN g % 3 = 1 THEN 'Mobile App'
         ELSE 'Travel Agency' END,
    NOW(),
    NOW(),
    CASE WHEN g % 2 = 0 THEN 'Confirmed' ELSE 'Cancelled' END,
    ROUND((100 + RANDOM() * 900)::numeric, 2)
FROM generate_series(1, 200) g;



UPDATE booking
SET ticket_price = ticket_price * 2,
    updated_at = NOW();






DELETE FROM booking
WHERE ticket_price < 10000;







-- Here we go, starting lab-3...







SELECT *
FROM passengers
WHERE first_name = last_name;



SELECT DISTINCT last_name
FROM passengers;




SELECT *
FROM passengers
WHERE gender = 'Male'
  AND date_of_birth BETWEEN '1990-01-01' AND '2000-12-31';

SELECT
    DATE_TRUNC('month', created_at) AS month,
    SUM(ticket_price) AS total_price
FROM booking
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month;

SELECT airline_name, airline_country, created_at
FROM airline
WHERE airline_country IN ('France', 'Portugal', 'Poland')
  AND created_at BETWEEN '2023-11-01' AND '2024-03-31';

SELECT airline_name
FROM airline
WHERE airline_country = 'Kazakhstan';


UPDATE booking
SET ticket_price = ticket_price * 0.9
WHERE created_at < '2023-01-11';


-- In the presented database scheme,
-- the weight of the baggage is not stored,
-- so the request cannot be executed.


SELECT first_name, last_name
FROM passengers
WHERE date_of_birth = (
    SELECT MAX(date_of_birth)
    FROM passengers
);




SELECT booking_platform, MIN(ticket_price) AS cheapest_price
FROM booking
GROUP BY booking_platform;



SELECT airline_name, airline_code
FROM airline
WHERE airline_code ~ '[0-9]';



SELECT airline_name, created_at
FROM airline
ORDER BY created_at DESC
LIMIT 5;




SELECT *
FROM Baggage_check
WHERE booking_id BETWEEN 200 AND 300
  AND check_result <> 'Checked';




SELECT *
FROM Baggage_check
WHERE DATE_TRUNC('month', created_at) = DATE_TRUNC('month', updated_at)
  AND updated_at < created_at;

































