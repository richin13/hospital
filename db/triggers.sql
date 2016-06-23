-- All this sql code was required by our awesome professor,
-- they are almost useless and have poor code quality, but for
-- this professor crappy code means 'complex', so yeah just ignore them

-- Basic Triggers
CREATE TRIGGER update_params_team_operation_fee
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
    @team_id = inserted.id_params_team
FROM inserted
  INNER JOIN employee
    ON inserted.dni = employee.dni

SELECT @team_members_count = (SELECT COUNT(*)
                              FROM paramedic
                              WHERE id_params_team = @team_id)

SELECT @paramedic_salary = (SELECT salary FROM employee WHERE employee.dni = @param_id)

BEGIN TRANSACTION;

UPDATE paramedics_team
SET operation_fee = ((operation_fee + @paramedic_salary) / @team_members_count)
WHERE id_params_team = @team_id

COMMIT TRANSACTION;
END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION;
  RAISERROR('An error occurred', 16, 1)
END CATCH


CREATE TRIGGER update_params_team_fee_on_param_specialization_change
ON paramedic
AFTER UPDATE
AS
  DECLARE
    @team_id INT,
    @param_id INT,
    @previuos_specialization CHAR(3),
    @specialization CHAR(3),
    @old_salary_plus INT,
    @new_salary_plus INT,
    @team_salary_total FLOAT,
    @team_members_count INT

  BEGIN TRY
    SELECT @previuos_specialization = (SELECT specialization FROM deleted)
    SELECT @specialization = (SELECT specialization FROM inserted)

    IF (@previuos_specialization != @specialization)
        BEGIN
          SELECT
            @param_id = inserted.dni,
            @team_id = inserted.id_params_team
          FROM inserted

          -- Get new salary plus
          IF (@specialization = 'PAB')
            BEGIN
              SET @new_salary_plus = 300000
            END

          ELSE IF (@specialization = 'APA')
            BEGIN
              SET @new_salary_plus = 280000
            END

          ELSE IF (@specialization = 'AEM')
            BEGIN
              SET @new_salary_plus = 420000
            END

          ELSE IF (@specialization = 'TEM')
            BEGIN
              SET @new_salary_plus = 490000
            END

          -- Get old salary plus
          IF (@previuos_specialization = 'PAB')
            BEGIN
              SET @old_salary_plus = 300000
            END

          ELSE IF (@previuos_specialization = 'APA')
            BEGIN
              SET @old_salary_plus = 280000
            END

          ELSE IF (@previuos_specialization = 'AEM')
            BEGIN
              SET @old_salary_plus = 420000
            END

          ELSE IF (@previuos_specialization = 'TEM')
            BEGIN
              SET @old_salary_plus = 490000
            END

          -- Subtract old plus from salary and add new salary plus
          BEGIN TRANSACTION;

          UPDATE employee
          SET salary = salary - @old_salary_plus
          WHERE employee.dni = @param_id

          UPDATE employee
          SET salary = salary + @new_salary_plus
          WHERE employee.dni = @param_id

          SELECT @team_members_count = (SELECT COUNT(*)
                                        FROM paramedic
                                        WHERE id_params_team = @team_id)

          SELECT @team_salary_total = (SELECT SUM(salary)
                                       FROM employee
                                         INNER JOIN paramedic ON employee.dni = paramedic.dni
                                       GROUP BY id_params_team
                                       HAVING paramedic.id_params_team = @team_id)

          UPDATE paramedics_team
            SET operation_fee = (@team_salary_total / @team_members_count)
          WHERE id_params_team = @team_id

          COMMIT TRANSACTION;
      END
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    RAISERROR('An error occurred', 16, 1)
  END CATCH


CREATE TRIGGER change_available_driver_status
ON ambulance
AFTER INSERT, DELETE
AS
  Declare @id_driver int
    BEGIN TRY
      IF EXISTS (SELECT * FROM inserted)
          BEGIN
            BEGIN TRANSACTION;

            SET @id_driver = (SELECT driver_id FROM deleted)
            UPDATE employee
            SET available = 0
            WHERE (@id_driver = dni)

                COMMIT TRANSACTION;
          END

      ELSE IF EXISTS (SELECT * FROM deleted)
          BEGIN
            BEGIN TRANSACTION;

            SET @id_driver = (SELECT driver_id FROM deleted)
            UPDATE employee
            SET available = 1
            WHERE (@id_driver = dni)

                COMMIT TRANSACTION;
          END

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('An error occurred', 16, 1)
    END CATCH


-- Advanced Triggers
CREATE TRIGGER update_completed_dispatch_data_and_ambulance_mileage
ON dispatch
AFTER INSERT, UPDATE, DELETE
AS
  SET NOCOUNT ON
DECLARE
@ambulance_id INT,
@dispatch_distance INT,
@emergency_id INT,
@id_params INT

BEGIN TRY

IF EXISTS(SELECT *
          FROM deleted)
  BEGIN
    IF EXISTS(SELECT *
              FROM inserted)
      BEGIN
        IF ((SELECT status
             FROM inserted) = 4)
          BEGIN
            SELECT
                @ambulance_id = id_ambulance,
                @emergency_id = id_emergency,
                @dispatch_distance = distance,
                @id_params = id_params_team
            FROM inserted

            BEGIN TRANSACTION;
            UPDATE ambulance
            SET mileage = mileage + @dispatch_distance
            WHERE ambulance.id_ambulance = @ambulance_id
            COMMIT TRANSACTION;

            EXEC update_completed_dispatch_data @id_ambulance = @ambulance_id, @id_params_team = @id_params,
                                                @id_emergency = @emergency_id
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
  RAISERROR('An error occurred', 16, 1)
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
  RAISERROR('An error occurred', 16, 1)
END CATCH


CREATE TRIGGER move_insurance_plan_to_historic_on_delete
ON insurance_plan
INSTEAD OF DELETE
AS
  DECLARE
    @id_insurance_plan INT,
      @description VARCHAR(100)

  BEGIN TRY
    SELECT @id_insurance_plan = (SELECT id_insurance_plan FROM deleted)
​

    SELECT @description = (SELECT description FROM deleted)
​
    BEGIN TRANSACTION;
​
    INSERT INTO historic_insurance_plan (id_insurance_plan, date, description)
    VALUES (@id_insurance_plan, GETDATE(), @description )
​
    COMMIT TRANSACTION;
​
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
  END CATCH


CREATE TRIGGER execute_driver_salary_pluses_calc_procedure
ON driver
AFTER INSERT
AS
  DECLARE
    @id_emp INT

  BEGIN TRY

    SELECT @id_emp = (SELECT dni FROM inserted)

    EXEC calc_employee_salary_pluses @employee_id = @id_emp
  END TRY
  BEGIN CATCH
  END CATCH

CREATE TRIGGER execute_paramedic_salary_pluses_calc_procedure
ON paramedic
AFTER INSERT
AS
  DECLARE
    @id_emp INT

  BEGIN TRY

    SELECT @id_emp = (SELECT dni FROM inserted)

    EXEC calc_employee_salary_pluses @employee_id = @id_emp
  END TRY
  BEGIN CATCH
  END CATCH