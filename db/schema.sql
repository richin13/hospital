CREATE TABLE province (
  id_province INT         NOT NULL PRIMARY KEY,
  name        VARCHAR(30) NOT NULL
);

CREATE TABLE canton (
  id_canton   INT PRIMARY KEY IDENTITY,
  name        VARCHAR(30) NOT NULL,
  id_province INT         NOT NULL,
  CONSTRAINT fk_province_canton FOREIGN KEY (id_province)
  REFERENCES province (id_province)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE users (
  id        INT PRIMARY KEY,
  name      VARCHAR(32)  NOT NULL,
  last_name VARCHAR(32)  NOT NULL,
  genre     CHAR(1)      NOT NULL CHECK (genre = 'M' OR genre = 'F'),
  username  VARCHAR(80)  NOT NULL UNIQUE,
  email     VARCHAR(120) NOT NULL UNIQUE,
  password  VARCHAR(128) NOT NULL
);

/*
category = 1 --> Complementario
category = 2 --> Acumulativo
category = 3 --> Contra todo riesgo
category = 4 --> Colectivo
*/
CREATE TABLE insurance_plan (
  id_insurance_plan   INT PRIMARY KEY IDENTITY,
  category            INT         NOT NULL,
  coverage_percentage INT         NOT NULL,
  description         VARCHAR(60) NOT NULL,
  CONSTRAINT ck_insurance_plan_category CHECK (
    category >= 1 AND category <= 4
  )
);

CREATE TABLE patient (
  id_patient        INT PRIMARY KEY,
  name              VARCHAR(45)  NOT NULL,
  last_name         VARCHAR(45)  NOT NULL,
  address           VARCHAR(128) NOT NULL DEFAULT ('Desconocida'),
  phone_number      VARCHAR(10)  NOT NULL DEFAULT ('N/A'),
  id_insurance_plan INT,
  CONSTRAINT fk_patient_insurance_company FOREIGN KEY (id_insurance_plan)
  REFERENCES insurance_plan (id_insurance_plan)
    ON UPDATE CASCADE
);

CREATE TABLE employee (
  dni          INT PRIMARY KEY,
  name         VARCHAR(45)  NOT NULL,
  last_name    VARCHAR(45)  NOT NULL,
  address      VARCHAR(128) NOT NULL DEFAULT ('Desconocida'),
  phone_number VARCHAR(10)  NOT NULL DEFAULT ('N/A'),
  salary       FLOAT        NOT NULL,
  available    BIT          NOT NULL,
  CONSTRAINT ck_salary CHECK (salary > 0)
);

CREATE TABLE driver (
  dni          INT PRIMARY KEY,
  start_hour   TIME NOT NULL,
  end_hour     TIME NOT NULL,
  licence_type CHAR(2),
  CONSTRAINT fk_employee_driver FOREIGN KEY (dni) REFERENCES employee (dni)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT ck_licence_type CHECK (
    licence_type LIKE 'A[1-3]' OR
    licence_type LIKE 'B[1-3]' OR
    licence_type LIKE 'C[2]' OR
    licence_type LIKE 'D[1-3]' OR
    licence_type LIKE 'E[1]'
  )
);

CREATE TABLE paramedics_team (
  id_params_team INT PRIMARY KEY IDENTITY,
  type           CHAR(2) NOT NULL,
  available      BIT     NOT NULL,
  operation_fee  FLOAT   NOT NULL,
  CONSTRAINT ck_type CHECK (
    type = 'SB' OR
    type = 'SA' OR
    type = 'SV'
  )
);

CREATE TABLE paramedic (
  dni            INT PRIMARY KEY,
  specialization CHAR(3) NOT NULL,
  id_params_team INT,
  CONSTRAINT fk_params_team_paramedic FOREIGN KEY (id_params_team)
  REFERENCES paramedics_team (id_params_team)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT fk_employee_paramedic FOREIGN KEY (dni)
  REFERENCES employee (dni)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT ck_specialization CHECK (
    specialization = 'PAB' OR
    specialization = 'APA' OR
    specialization = 'AEM' OR
    specialization = 'TEM'
  )
);

CREATE TABLE ambulance (
  id_ambulance INT         NOT NULL PRIMARY KEY,
  plate_number INT         NOT NULL UNIQUE,
  brand        VARCHAR(45) NOT NULL,
  model        VARCHAR(45) NOT NULL,
  mileage      INT         NOT NULL,
  available    BIT         NOT NULL,
  driver_id    INT,
  CONSTRAINT fk_driver_ambulance FOREIGN KEY (driver_id)
  REFERENCES driver (dni)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

CREATE TABLE emergency (
  id_emergency INT PRIMARY KEY IDENTITY,
  description  VARCHAR(60) NOT NULL,
  type         VARCHAR(60) NOT NULL,
  address      VARCHAR(60) NOT NULL,
  id_canton    INT         NOT NULL,
  CONSTRAINT fk_canton_emergency FOREIGN KEY (id_canton)
  REFERENCES canton (id_canton)
);

/*
status = 1 --> En ruta
status = 2 --> En sitio
status = 3 --> Volviendo
status = 4 --> Completado
status = 5 --> Cancelado
*/
CREATE TABLE dispatch (
  id_ambulance   INT      NOT NULL,
  id_params_team INT      NOT NULL,
  id_emergency   INT      NOT NULL,
  dispatch_hour  DATETIME NOT NULL,
  arrival_hour   DATETIME,
  distance       INT,
  status         INT      NOT NULL,
  fee            FLOAT,
  PRIMARY KEY (id_ambulance, id_params_team, id_emergency),
  CONSTRAINT dispatch_ambulance_FK FOREIGN KEY (id_ambulance)
  REFERENCES ambulance (id_ambulance)
    ON UPDATE CASCADE,
  CONSTRAINT dispatch_params_FK FOREIGN KEY (id_params_team)
  REFERENCES paramedics_team (id_params_team)
    ON UPDATE CASCADE,
  CONSTRAINT dispatch_emergency_FK FOREIGN KEY (id_emergency)
  REFERENCES emergency (id_emergency)
    ON UPDATE CASCADE,
  CONSTRAINT ck_dispatch_type CHECK (
    status >= 1 AND status <= 5
  )
);

CREATE TABLE patient_bill (
  id_bill              INT PRIMARY KEY IDENTITY,
  id_patient           INT,
  id_emergency         INT,
  fee                  FLOAT NOT NULL,
  covered_by_insurance BIT   NOT NULL,
  CONSTRAINT fk_patient_bill_patient FOREIGN KEY (id_patient)
  REFERENCES patient (id_patient)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_patient_bill_emergency FOREIGN KEY (id_emergency)
  REFERENCES emergency (id_emergency)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE patient_admission (
  id_admission INT PRIMARY KEY IDENTITY,
  id_patient   INT,
  date         DATETIME NOT NULL,
  CONSTRAINT fk_patient_admission_patient FOREIGN KEY (id_patient) REFERENCES patient (id_patient)
);

INSERT INTO province
VALUES
  (1, 'san jose'),
  (3, 'cartago');

INSERT INTO canton (id_province, name)
VALUES
  (1, 'san jose'),
  (1, 'moravia'),
  (1, 'tibas'),
  (1, 'escazu'),
  (1, 'desamparados'),
  (1, 'goicoechea'),
  (1, 'curridabat'),
  (3, 'cartago'),
  (3, 'paraiso'),
  (3, 'la union'),
  (3, 'jimenez'),
  (3, 'turrialba'),
  (3, 'oreamuno'),
  (3, 'el guarco');

