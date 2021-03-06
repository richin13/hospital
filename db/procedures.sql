
-- Basic Procedures
CREATE PROCEDURE calc_ambulance_distance
    @beginDate               DATETIME,
    @lastDate                DATETIME,
    @id_ambulance            INT,
    @total_traveled_distance INT OUTPUT
AS
  DECLARE
    @aux INT,
    @date DATETIME,
    @current_distance INT

  BEGIN TRY
    BEGIN TRANSACTION;
    IF (Exists(SELECT id_ambulance
               FROM dispatch
               WHERE (@id_ambulance = id_ambulance)))
      BEGIN

        SELECT @total_traveled_distance = 0

        DECLARE CDistance SCROLL CURSOR FOR
          SELECT distance
          FROM dispatch
          WHERE (id_ambulance = @id_ambulance AND DATEPART(MM, dispatch_hour) >= DATEPART(MM, @beginDate) AND
                 DATEPART(MM, dispatch_hour) <= DATEPART(MM, @lastDate) AND
                 DATEPART(YYYY, dispatch_hour) >= DATEPART(YYYY, @beginDate) AND
                 DATEPART(YYYY, dispatch_hour) <= DATEPART(YYYY, @lastDate))

        OPEN CDistance
        FETCH NEXT FROM CDistance
        INTO @current_distance
        WHILE (@@FETCH_STATUS = 0)
          BEGIN
            SELECT @current_distance

            SET @total_traveled_distance = @total_traveled_distance + @current_distance
            print @total_traveled_distance
            FETCH NEXT FROM CDistance
            INTO @current_distance
          END
        CLOSE CDistance
        DEALLOCATE CDistance
      END

    COMMIT TRANSACTION;
    RETURN
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE() + ERROR_NUMBER()
  END CATCH

CREATE PROCEDURE update_dispatch_status
    @object         VARCHAR(7),
    @id_ambulance   INT,
    @id_params_team INT,
    @id_emergency   INT
AS
    BEGIN TRY
      BEGIN TRANSACTION;
      ​
      IF (@object = 'en_ruta')
        BEGIN
          UPDATE dispatch
          SET status = 1
          WHERE id_ambulance = @id_ambulance AND
                id_params_team = @id_params_team AND
                id_emergency = @id_emergency
        END
          ​
      ELSE IF (@object = 'en_sitio')
        BEGIN
          UPDATE dispatch
          SET status = 2
          WHERE id_ambulance = @id_ambulance AND
                id_params_team = @id_params_team AND
                id_emergency = @id_emergency
        END
          ​
      ELSE IF (@object = 'de_vuelta')
        BEGIN
          UPDATE dispatch
          SET status = 3
          WHERE id_ambulance = @id_ambulance AND
                id_params_team = @id_params_team AND
                id_emergency = @id_emergency
        END
          ​
      ELSE IF (@object = 'completado')
        BEGIN
          UPDATE dispatch
          SET status = 4
          WHERE id_ambulance = @id_ambulance AND
                id_params_team = @id_params_team AND
                id_emergency = @id_emergency
        END
          ​
      ELSE IF (@object = 'cancelado')
        BEGIN
          UPDATE dispatch
          SET status = 5
          WHERE id_ambulance = @id_ambulance AND
                id_params_team = @id_params_team AND
                id_emergency = @id_emergency
        END
          ​
      COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE() + ERROR_NUMBER()
  END CATCH

CREATE PROCEDURE update_available_status
    @object    VARCHAR(7),
    @object_id INT,
    @available BIT
AS
  BEGIN TRY
  BEGIN TRANSACTION;

  IF (@object = 'PARAM')
    BEGIN
      UPDATE employee
      SET available = @available
      WHERE employee.dni = @object_id
    END

  ELSE IF (@object = 'PARAM_T')
    BEGIN
      UPDATE paramedics_team
      SET available = @available
      WHERE paramedics_team.id_params_team = @object_id
    END

  ELSE IF (@object = 'AMB')
    BEGIN
      UPDATE ambulance
      SET available = @available
      WHERE ambulance.id_ambulance = @object_id
    END

  COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE() + ERROR_NUMBER()
  END CATCH


-- Advanced Procedure
CREATE PROCEDURE calc_employee_salary_pluses
  @employee_id INT
AS
  DECLARE
  @employee_type CHAR(3),
  @driver_licence CHAR(2),
  @param_type CHAR(3),
  @increment INT

  BEGIN TRY

    SELECT @employee_type = (SELECT type
                             FROM employee
                             WHERE dni = @employee_id)

    IF (@employee_type = 'DRV')
      BEGIN
        SELECT @driver_licence = (SELECT licence_type
                                  FROM driver
                                  WHERE dni = @employee_id);

        IF (@driver_licence LIKE 'B[1-3]')
          BEGIN
            SET @increment = 80000
          END

        ELSE IF (@driver_licence = 'C2')
          BEGIN
            SET @increment = 95000
          END

        ELSE IF (@driver_licence LIKE 'D[1-3]')
          BEGIN
            SET @increment = 105000
          END

        ELSE IF (@driver_licence = 'E1')
          BEGIN
            SET @increment = 115000
          END

        BEGIN TRANSACTION;

        UPDATE employee
        SET salary = salary + @increment
        WHERE dni = @employee_id

        COMMIT TRANSACTION;
      END

    ELSE IF (@employee_type = 'PRM')
      BEGIN
        SELECT @param_type = (SELECT specialization
                              FROM paramedic
                              WHERE dni = @employee_id)

        IF (@param_type = 'PAB')
          BEGIN
            SET @increment = 300000
          END

        ELSE IF (@param_type = 'APA')
          BEGIN
            SET @increment = 280000
          END

        ELSE IF (@param_type = 'AEM')
          BEGIN
            SET @increment = 420000
          END

        ELSE IF (@param_type = 'TEM')
          BEGIN
            SET @increment = 490000
          END

        BEGIN TRANSACTION;

        UPDATE employee
        SET salary = salary + @increment
        WHERE dni = @employee_id

        COMMIT TRANSACTION;
      END
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
  END CATCH


CREATE PROCEDURE update_completed_dispatch_data
  @id_ambulance   INT,
  @id_params_team INT,
  @id_emergency   INT
AS
DECLARE @distance INT

BEGIN TRY

SELECT @distance = (SELECT distance
                    FROM dispatch
                    WHERE dispatch.id_ambulance = @id_ambulance AND dispatch.id_params_team = @id_params_team AND
                          dispatch.id_emergency = @id_emergency)

BEGIN TRANSACTION;

UPDATE dispatch
SET
  arrival_hour = GETDATE(),
  distance     = @distance,
  status       = 4,
  fee          = @distance * 500
WHERE dispatch.id_ambulance = @id_ambulance AND dispatch.id_params_team = @id_params_team AND
      dispatch.id_emergency = @id_emergency

COMMIT TRANSACTION;

EXEC update_available_status @object = 'AMB', @object_id = @id_ambulance, @available = 1;
EXEC update_available_status @object = 'PARAM_T', @object_id = @id_params_team, @available = 1;

END TRY
BEGIN CATCH
  ROLLBACK TRANSACTION;
  PRINT ERROR_MESSAGE() + ERROR_NUMBER()
END CATCH


CREATE PROCEDURE apply_insurance_cover
    @bill_id INT
AS
  DECLARE
  @patient_id INT,
  @cover_percentage INT,
  @insurance_category VARCHAR(45)

  BEGIN TRY
  IF ((SELECT covered_by_insurance
       FROM patient_bill
       WHERE id_bill = @bill_id) != 1)
    BEGIN
      SELECT @patient_id = (
        SELECT id_patient
        FROM patient_bill
        WHERE id_bill = @bill_id
      );

      SELECT @insurance_category = (
        SELECT insurance_plan.category
        FROM patient
          INNER JOIN insurance_plan
            ON patient.id_insurance_plan = insurance_plan.id_insurance_plan
        GROUP BY insurance_plan.category, patient.id_patient
        HAVING patient.id_patient = @patient_id
      );

      IF (@insurance_category IS NOT NULL)
        BEGIN

          SELECT @cover_percentage = (
            SELECT insurance_plan.coverage_percentage
            FROM insurance_plan
              INNER JOIN patient
                ON insurance_plan.id_insurance_plan = patient.id_insurance_plan
            GROUP BY insurance_plan.coverage_percentage, patient.id_patient
            HAVING patient.id_patient = @patient_id
          );

          BEGIN TRANSACTION;

          UPDATE patient_bill
          SET
            fee                  = fee - fee * @cover_percentage / 100,
            covered_by_insurance = 1
          WHERE patient_bill.id_bill = @bill_id

          COMMIT TRANSACTION;

        END
    END
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE() + ERROR_NUMBER()
  END CATCH

-- Reports
CREATE PROCEDURE report_most_dispatched_profitable_ambulance
  @id_ambulance INT OUTPUT,
  @total_distance INT OUTPUT,
  @total_fee INT OUTPUT
AS
    SET NOCOUNT ON;
    SELECT @id_ambulance = (SELECT TOP 1 id_ambulance FROM dispatch GROUP BY id_ambulance ORDER BY COUNT(*) DESC)

    SELECT @total_distance =  SUM(distance)
    FROM dispatch
    WHERE id_ambulance = @id_ambulance

    SELECT @total_fee =  SUM(fee)
    FROM dispatch
    WHERE id_ambulance = @id_ambulance
    RETURN


CREATE PROCEDURE report_most_dispatched_profitable_paramedic_team
  @id_team INT OUTPUT,
  @total_distance INT OUTPUT,
  @total_fee INT OUTPUT
AS
    SET NOCOUNT ON;
    SELECT @id_team = (SELECT TOP 1 id_params_team FROM dispatch GROUP BY id_params_team ORDER BY count(*) DESC)

    SELECT @total_distance =  SUM(distance)
    FROM dispatch
    WHERE id_params_team = @id_team

    SELECT @total_fee =  SUM(fee)
    FROM dispatch
    WHERE id_params_team = @id_team
    RETURN


CREATE PROCEDURE report_top_5_ambulances
AS
  SELECT TOP 5 plate_number, driver_id, COUNT(*) AS dispatchs, SUM(fee) AS profits
  FROM dispatch
  INNER JOIN ambulance
  ON dispatch.id_ambulance=ambulance.id_ambulance
  GROUP BY plate_number, status, driver_id
  HAVING status = 4
  ORDER BY SUM(fee) DESC


CREATE PROCEDURE report_top_5_teams
AS
  SELECT TOP 5 dispatch.id_params_team, type, SUM(fee) AS profits
  FROM dispatch
  INNER JOIN paramedics_team
  ON dispatch.id_params_team=paramedics_team.id_params_team
  GROUP BY dispatch.id_params_team, type
  ORDER BY SUM(fee) DESC