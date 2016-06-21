-- All this sql code was required by our awesome professor,
-- they are almost useless and have poor code quality, but for
-- this professor crappy code means 'complex', so yeah just ignore them
ALTER TRIGGER update_params_team_operation_fee
ON paramedic
AFTER INSERT
AS
  DECLARE
  @team_id INT,
  @param_id INT,
  @paramedic_salary FLOAT,
  @team_members_count INT

BEGIN TRY
SELECT
    @param_id = inserted.dni,
    @team_id = inserted.id_params_team,
    @paramedic_salary = employee.salary
FROM inserted
  INNER JOIN employee
    ON inserted.dni = employee.dni

EXEC calc_employee_salary_pluses @employee_id = @param_id

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
AFTER INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON
DECLARE
@ambulance_id INT,
@dispatch_distance INT,
@id_params INT

BEGIN TRY

IF EXISTS(SELECT *
          FROM inserted)
  BEGIN
    IF EXISTS(SELECT *
              FROM deleted)
      BEGIN
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
            COMMIT TRANSACTION;

            EXEC update_completed_dispatch_data @id_ambulance = @ambulance_id, @id_params_team = @id_params
          END
      END
  END

ELSE IF EXISTS(SELECT *
               FROM inserted)
  BEGIN
    SELECT
        @ambulance_id = id_ambulance,
        @id_params = id_params_team
    FROM inserted

    EXEC update_available_status @object = 'AMB', @object_id = @ambulance_id, @available = 0;
    EXEC update_available_status @object = 'PARAM_T', @object_id = @id_params, @available = 0;

  END

ELSE IF EXISTS(SELECT *
               FROM deleted)
  BEGIN
    IF ((SELECT status
         FROM deleted) != 4)
      BEGIN
        SELECT
            @ambulance_id = id_ambulance,
            @id_params = id_params_team
        FROM inserted

        EXEC update_available_status @object = 'AMB', @object_id = @ambulance_id, @available = 1;
        EXEC update_available_status @object = 'PARAM_T', @object_id = @id_params, @available = 1;
      END
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