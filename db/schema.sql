CREATE TABLE province (
	id_province INT PRIMARY KEY,
	name VARCHAR(60)
);

CREATE TABLE county (
	id_county INT PRIMARY KEY IDENTITY,
	id_province INT,
	name VARCHAR(60),
	CONSTRAINT fk_province_county FOREIGN KEY(id_province) REFERENCES province(id_province)
);

CREATE TABLE employee (
	dni INT PRIMARY KEY IDENTITY,
	name VARCHAR(45) NOT NULL,
	last_name VARCHAR(45) NOT NULL,
	address VARCHAR(45) NULL,
	phone_number VARCHAR(10) NULL,
	salary FLOAT NOT NULL,
	disponible BIT
);

CREATE TABLE driver (
	dni INT PRIMARY KEY,
	licence_type CHAR(2),
	start_hour TIME,
	end_hour TIME,
	CONSTRAINT ck_licence_type CHECK (
		licence_type LIKE 'A[1-3]' OR
		licence_type LIKE 'B[1-3]' OR
		licence_type LIKE 'C[2]'   OR
		licence_type LIKE 'D[1-3]' OR
		licence_type LIKE 'E[1]'
	)
);

CREATE TABLE paramedic (
	dni INT PRIMARY KEY IDENTITY,
	specialization CHAR(3) NOT NULL,
	id_params_team INT,
	CONSTRAINT fk_params_team_paramedic FOREIGN KEY (id_params_team) REFERENCES paramedic_team(id_params_team) ON DELETE SET NULL ON UPDATE CASCADE,
	CONSTRAINT ck_specialization CHECK (
		specialization = 'PAB' OR
		specialization = 'APA' OR
		specialization = 'AEM' OR
		specialization = 'TEM'
	)
);

CREATE TABLE paramedic_team (
	id_params_team INT PRIMARY KEY IDENTITY,
	type CHAR(2) NOT NULL,
	available BIT,
	operation_fee FLOAT NOT NULL,
	CONSTRAINT ck_type CHECK (
		type = 'SB' OR
		type = 'SA' OR
		type = 'SV'
	)
);

CREATE TABLE ambulance (
	id_ambulance INT PRIMARY KEY NOT NULL,
	id_driver INT,
	plate_number INT NOT NULL,
	brand VARCHAR(45) NULL,
	model VARCHAR(45) NULL,
	milage INT,
	available BIT,
	CONSTRAINT fk_driver_ambulance FOREIGN KEY (id_driver) REFERENCES driver(dni) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE emergency (
	id_emergency INT PRIMARY KEY,
	description VARCHAR(60) NOT NULL,
	type VARCHAR(60) NOT NULL,
	county INT NOT NULL,
	address VARCHAR(60) NOT NULL,
	CONSTRAINT fk_county_emergency FOREIGN KEY (county) REFERENCES county(id_county)
);

CREATE TABLE deployment (
	id_ambulance INT,
	id_params_team INT,
	id_emergency INT,
	deployment_hour DATETIME NOT NULL,
	arrival_hour DATETIME,
	distance INT,
	status CHAR(10),
	fee FLOAT,
	PRIMARY KEY(id_ambulance, id_params_team),

	CONSTRAINT fk_ambulance_deployement FOREIGN KEY (id_ambulance) REFERENCES ambulance(id_ambulance) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_params_team_deployement FOREIGN KEY (id_params_team) REFERENCES paramedic_team(id_params_team) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT fk_emergency_deployement FOREIGN KEY (id_emergency) REFERENCES emergency(id_emergency) ON DELETE CASCADE ON UPDATE CASCADE,

	CONSTRAINT ck_deployement_status CHECK (
		status = 'en_ruta' OR
		status = 'en_sitio' OR
		status = 'de_vuelta' OR
		status = 'completado' OR
		status = 'cancelado'
	)
);

CREATE TABLE patient_bill (
	id_bill INT PRIMARY KEY IDENTITY,
	id_patient INT,
	id_emergency INT,
	fee FLOAT NOT NULL,
	covered_by_insurance BIT,
	-- TODO FOREIGN KEY patient 
	CONSTRAINT fk_patient_bill_emergency FOREIGN KEY(id_emergency) REFERENCES emergency(id_emergency) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO province
VALUES
(1, 'san jose'),
(3, 'cartago');

INSERT INTO county (id_province, name)
VALUES
(1,'san jose'),
(1,'moravia'),
(1,'tibas'),
(1,'escazu'),
(1,'desamparados'),
(1,'goicoechea'),
(1,'curridabat'),
(3,'cartago'),
(3,'paraiso'),
(3,'la union'),
(3,'jimenez'),
(3,'turrialba'),
(3,'oreamuno'),
(3,'el guarco');