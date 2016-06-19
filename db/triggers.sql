CREATE TRIGGER update_params_team_operation_fee
ON paramedic
AFTER INSERT
AS
  DECLARE
  @team_id INT,
  @paramedic_salary FLOAT,
  @team_members_count INT

BEGIN TRY
SELECT
    @team_id = inserted.id_params_team,
    @paramedic_salary = employee.salary
FROM inserted
  INNER JOIN employee
    ON inserted.dni = employee.dni

SELECT @team_members_count = (SELECT COUNT(*)
                              FROM paramedics_team
                              WHERE id_params_team = @team_id)

BEGIN TRANSACTION;

UPDATE paramedics_team
SET operation_fee = (operation_fee + @paramedic_salary) / @team_members_count
WHERE id_params_team = @team_id

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION;
END CATCH

CREATE TRIGGER update_completed_dispatch_data_and_ambulance_mileage
ON dispatch
AFTER UPDATE
AS
  SET NOCOUNT ON
DECLARE
@ambulance_id INT,
@dispatch_distance INT,
@id_params INT

BEGIN TRY
IF ((SELECT status
     FROM inserted) = 4)
  BEGIN
    SELECT
        @ambulance_id = id_ambulance,
        @dispatch_distance = distance,
        @id_params = id_params_team
    FROM inserted

    BEGIN TRANSACTION;
    UPDATE ambulance
    SET mileage = mileage + @dispatch_distance
    WHERE ambulance.id_ambulance = @ambulance_id

    EXEC update_completed_dispatch_data @id_ambulance = @ambulance_id, @id_params_team = @id_params

    COMMIT TRANSACTION;
  END
END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION;
END CATCH

CREATE TRIGGER register_patient_admission
ON patient_bill
AFTER INSERT
AS
  DECLARE
  @id_patient INT,
  @description VARCHAR(100)

BEGIN TRY
SELECT @id_patient = (SELECT id_patient
                      FROM inserted)

SELECT @description = (SELECT description
                       FROM emergency
                         INNER JOIN inserted
                           ON emergency.id_emergency = inserted.id_emergency)

BEGIN TRANSACTION;

INSERT INTO patient_admission (id_patient, date, description)
VALUES (@id_patient, GETDATE(), @description)

COMMIT TRANSACTION;

END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION;
END CATCH


CREATE TRIGGER update_status_after_dispatch
ON dispatch
AFTER INSERT
AS
  DECLARE
  @id_ambulance INT,
  @id_params_team INT
BEGIN TRY
-- Only if status is 'en ruta'
IF ((SELECT status
     FROM inserted) = 1)
  BEGIN
    SELECT
        @id_ambulance = id_ambulance,
        @id_params_team = id_params_team
    FROM inserted

    BEGIN TRANSACTION;

    UPDATE ambulance
    SET available = 0
    WHERE id_ambulance = @id_ambulance

    UPDATE paramedics_team
    SET available = 0
    WHERE id_params_team = @id_params_team

    COMMIT TRANSACTION;
  END
END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION;
END CATCH