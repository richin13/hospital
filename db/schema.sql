CREATE TABLE province (
  id   INT         NOT NULL PRIMARY KEY,
  name VARCHAR(30) NOT NULL
);

CREATE TABLE canton (
  id          INT PRIMARY KEY IDENTITY,
  name        VARCHAR(30) NOT NULL,
  province_id INT         NOT NULL,
  CONSTRAINT fk_province_canton FOREIGN KEY (province_id)
  REFERENCES province (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

/*
category = 1 --> Complementario
category = 2 --> Acumulativo
category = 3 --> Contra todo riesgo
category = 4 --> Colectivo
*/
CREATE TABLE insurance_plan (
  id                  INT PRIMARY KEY IDENTITY,
  category            INT         NOT NULL,
  coverage_percentage INT         NOT NULL,
  description         VARCHAR(60) NOT NULL,
  CONSTRAINT ck_insurance_plan_category CHECK (
    category >= 1 AND category <= 4
  )
);

CREATE TABLE patient (
  dni          INT PRIMARY KEY,
  name         VARCHAR(45)  NOT NULL,
  last_name    VARCHAR(45)  NOT NULL,
  address      VARCHAR(128) NOT NULL DEFAULT ('Desconocida'),
  phone_number VARCHAR(10)  NOT NULL DEFAULT ('N/A'),
  insurance_id INT,
  CONSTRAINT fk_patient_insurance_company FOREIGN KEY (insurance_id)
  REFERENCES insurance_plan (id)
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
  type         CHAR(3)      NOT NULL,
  CONSTRAINT ck_salary CHECK (salary > 0)
);

CREATE TABLE driver (
  dni        INT PRIMARY KEY,
  start_hour TIME NOT NULL,
  end_hour   TIME NOT NULL,
  CONSTRAINT fk_employee_driver FOREIGN KEY (dni) REFERENCES employee (dni)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
);

CREATE TABLE paramedic (
  dni            INT PRIMARY KEY,
  specialization CHAR(3) NOT NULL,
  id_params_team INT,
  CONSTRAINT fk_params_team_paramedic FOREIGN KEY (id_params_team)
  REFERENCES paramedics_team (id)
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

CREATE TABLE paramedics_team (
  id            INT PRIMARY KEY IDENTITY,
  type          CHAR(2) NOT NULL,
  available     BIT     NOT NULL,
  operation_fee FLOAT   NOT NULL,
  CONSTRAINT ck_type CHECK (
    type = 'SB' OR
    type = 'SA' OR
    type = 'SV'
  )
);

CREATE TABLE ambulance (
  id           INT         NOT NULL PRIMARY KEY,
  plate_number INT         NOT NULL UNIQUE,
  brand        VARCHAR(45) NOT NULL,
  model        VARCHAR(45) NOT NULL,
  mileage      INT         NOT NULL,
  available    BIT         NOT NULL,
  driver_id    INT         NOT NULL,
  CONSTRAINT fk_driver_ambulance FOREIGN KEY (driver_id)
  REFERENCES driver (dni)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

CREATE TABLE emergency (
  id          INT PRIMARY KEY,
  description VARCHAR(60) NOT NULL,
  type        VARCHAR(60) NOT NULL,
  address     VARCHAR(60) NOT NULL,
  canton_id   INT         NOT NULL,
  CONSTRAINT fk_county_emergency FOREIGN KEY (canton_id)
  REFERENCES canton (id)
);

/*
status = 1 --> En ruta
status = 2 --> En sitio
status = 3 --> Volviendo
status = 4 --> Completado
status = 5 --> Cancelado

*/
CREATE TABLE dispatch (
  ambulance_id       INT      NOT NULL,
  paramedics_team_id INT      NOT NULL,
  emergency_id       INT      NOT NULL,
  dispatch_hour      DATETIME NOT NULL,
  arrival_hour       DATETIME,
  distance           INT,
  status             INT      NOT NULL,
  fee                FLOAT,
  PRIMARY KEY (ambulance_id, paramedics_team_id, emergency_id),
  CONSTRAINT dispatch_ambulance_FK FOREIGN KEY (ambulance_id)
  REFERENCES ambulance (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT dispatch_params_FK FOREIGN KEY (paramedics_team_id)
  REFERENCES paramedics_team (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT dispatch_emergency_FK FOREIGN KEY (emergency_id)
  REFERENCES emergency (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT ck_dispatch_type CHECK (
    status >= 1 AND status <= 5
  )
);

CREATE TABLE patient_bill (
  id                   INT PRIMARY KEY IDENTITY,
  patient_id           INT,
  emergency_id         INT,
  fee                  FLOAT NOT NULL,
  covered_by_insurance BIT   NOT NULL,
  CONSTRAINT fk_patient_bill_patient FOREIGN KEY (patient_id)
  REFERENCES patient (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_patient_bill_emergency FOREIGN KEY (emergency_id)
  REFERENCES emergency (id)
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
)