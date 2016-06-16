----------------------------------------------------------------------------------------------------------------------
--CREACION DE LA BASE DE DATOS
----------------------------------------------------------------------------------------------------------------------
CREATE DATABASE AdministracionAmbulancias 
----------------------------------------------------------------------------------------------------------------------
--CREAMOS LAS TABLAS DE LA BASE DE DATOS
----------------------------------------------------------------------------------------------------------------------
USE AdministracionAmbulancias
----------------------------------------------------------------------------------------------------------------------
-------------------Personal(dni,nombre,apellido,direccion,telefono,salario,disponible)----------------------------------------------------------
CREATE TABLE Personal(
	dni INTEGER IDENTITY(100,1) NOT NULL,
	nombre VARCHAR(45) NOT NULL,
	apellido VARCHAR(45) NOT NULL,
	direccion VARCHAR(45) NULL,
	telefono VARCHAR(10) NULL,
	salario FLOAT NOT NULL,
	disponible BIT,
	PRIMARY KEY(dni))


----------------------------------------------------------------------------------------------------------------------
-------------------Chofer(dni,tipo_licencia,hora_ingreso, hora_salida)----------------------------------------------------------
CREATE TABLE Chofer(
	dni INTEGER IDENTITY(1000,1) NOT NULL,
	tipo_licencia CHAR(2),
	hora_ingreso time,
	hora_salida time,
	PRIMARY KEY(dni),
	CONSTRAINT Ck_licencia CHECK(tipo_licencia like 'A[1-3]' OR
	tipo_licencia like 'B[1-3]' OR
	tipo_licencia like 'C[2]' OR
	tipo_licencia like 'D[1-3]' OR
	tipo_licencia like 'E[1]'))

INSERT INTO Chofer VALUES ('C2','10:00:00','11:00:00')

Drop TABLE Chofer


----------------------------------------------------------------------------------------------------------------------
-------------------Paramedico(dni,especializacion, id_equipo_params)----------------------------------------------------------
CREATE TABLE Paramedico(
	dni INTEGER IDENTITY(2000,1) NOT NULL,
	especializacion CHAR(3) NOT NULL,
	id_equipo_params INT,
	PRIMARY KEY(dni),
	FOREIGN KEY (id_equipo_params)REFERENCES Equipo_paramedico(id_equipo_params),
	CONSTRAINT Ck_especializacion CHECK(especializacion like 'PAB' OR
	especializacion like 'APA' OR
	especializacion like 'AEM' OR
	especializacion like 'TEM'))

----------------------------------------------------------------------------------------------------------------------
-------------------Equipo_paramedico(id_equipo_params, tipo, disponible, costo)----------------------------------------------------------
CREATE TABLE Equipo_paramedico(
	id_equipo_params INT NOT NULL,
	tipo CHAR(2) NOT NULL,
	disponible bit,
	costo FLOAT NOT NULL,
	PRIMARY KEY(id_equipo_params),
	CONSTRAINT Ck_tipo CHECK(tipo like 'SB' OR
	tipo like 'SA' OR
	tipo like 'SV'))


----------------------------------------------------------------------------------------------------------------------
-------------------Ambulancia(id_ambulancia, id_chofer, numero_unidad, placa, marca, modelo, kilometraje, disponible)----------------------------------------------------------
CREATE TABLE Ambulancia(
	id_ambulancia INT NOT NULL,
	id_chofer INT,
	numero_unidad INT NOT NULL,
	placa INT NOT NULL,
	marca VARCHAR(45) NULL,
	modelo VARCHAR(45) NULL,
	kilometraje INT,
	disponible bit,
	PRIMARY KEY(id_ambulancia),
	FOREIGN KEY (id_chofer) REFERENCES Chofer(dni))


----------------------------------------------------------------------------------------------------------------------
-------------------Emergencia(id_emergencia, descripcion, tipo, direccion, canton)----------------------------------------------------------
CREATE TABLE Emergencia(
	id_emergencia INT NOT NULL,
	descripcion VARCHAR(60) NOT NULL,
	tipo VARCHAR(60) NOT NULL,
	direccion VARCHAR(60) NOT NULL,
	canton INT,
	PRIMARY KEY(id_emergencia))
	--FOREIGN KEY(canton) REFERENCES A CUAL TABLA

----------------------------------------------------------------------------------------------------------------------
-------------------Despacho(id_ambulancia, id_equipo_params, id_emergencia, hora_salida, hora_llegada, distancia, estado, monto)---------------------------
CREATE TABLE Despacho(
	id_ambulancia INT,
	id_equipo_params INT,
	id_emergencia INT,
	hora_salida DATETIME NOT NULL,
	hora_llegada DATETIME,
	distancia INT,
	estado CHAR(10),
	monto float,
	PRIMARY KEY(id_ambulancia, id_equipo_params),
	CONSTRAINT Fk_ambulancia FOREIGN KEY  (id_ambulancia) REFERENCES Ambulancia(id_ambulancia),
	CONSTRAINT Fk_equipo FOREIGN KEY (id_equipo_params) REFERENCES Equipo_paramedico(id_equipo_params),
	CONSTRAINT Fk_emergencia FOREIGN KEY (id_emergencia) REFERENCES Emergencia(id_emergencia),
	CONSTRAINT Ck_estado CHECK(estado like 'en_ruta' OR
	estado like 'en_sitio' OR
	estado like 'de_vuelta' OR
	estado like 'completado' OR
	estado like 'cancelado'))

----------------------------------------------------------------------------------------------------------------------
-------------------Cobro(id_cobro, id_paciente, id_emergencia, monto, cubierto_por_seguro)---------------------------
CREATE TABLE Cobro(
	id_cobro INT IDENTITY(1,1),
	id_paciente INT,
	id_emergencia INT,
	monto FLOAT NOT NULL,
	cubierto_por_seguro BIT,
	PRIMARY KEY (id_cobro),
	--CONSTRAINT Fk_paciente FOREIGN KEY(id_paciente) REFERENCES 
	CONSTRAINT Fk_cobro_emergencia FOREIGN KEY(id_emergencia) REFERENCES Emergencia (id_emergencia))

