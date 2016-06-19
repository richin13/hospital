CREATE PROCEDURE apply_insurance_cover
  @bill_id INT
AS
DECLARE
@patient_id INT,
@cover_percentage INT,
@insurance_category VARCHAR(45)

BEGIN TRY
IF ((SELECT covered_by_insurance FROM patient_bill WHERE id_bill = @bill_id) != 1 )
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
          fee = fee - fee * @cover_percentage / 100,
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


CREATE PROCEDURE update_completed_dispatch_data
    @id_ambulance INT,
    @id_params_team INT,
    @distance INT
AS
  BEGIN TRY
  BEGIN TRANSACTION;

  UPDATE dispatch
  SET
    arrival_hour = GETDATE(),
    distance = @distance,
    status = 'completado',
    fee = @distance * 500
  WHERE dispatch.id_ambulance = @id_ambulance AND dispatch.id_params_team = @id_params_team

  COMMIT TRANSACTION;

  -- TODO: Call service fee calc procedure
  -- TODO: Call update available status procedure

  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT ERROR_MESSAGE() + ERROR_NUMBER()
  END CATCH


  CREATE PROCEDURE update_available_status
      @object VARCHAR(7),
      @object_id INT,
      @available BIT
  AS
    BEGIN TRY
    BEGIN TRANSACTION;

    IF (@object = 'PARAM')
      BEGIN
        UPDATE employee
        SET available = @available
        WHERE employee.dni = @object_id AND employee.available != @available
      END

    ELSE IF (@object = 'PARAM_T')
      BEGIN
        UPDATE paramedics_team
        SET available = @available
        WHERE paramedics_team.id_params_team = @object_id AND available != @available
      END

    ELSE IF (@object = 'AMB')
      BEGIN
        UPDATE ambulance
        SET available = @available
        WHERE ambulance.id_ambulance = @object_id AND available != @available
      END

    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
      ROLLBACK TRANSACTION;
      PRINT ERROR_MESSAGE() + ERROR_NUMBER()
    END CATCH