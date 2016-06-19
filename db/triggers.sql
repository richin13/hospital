CREATE TRIGGER update_params_team_operation_fee
ON paramedic
AFTER INSERT
AS
	DECLARE
		@team_id INT,
		@paramedic_salary FLOAT,
		@team_members_count INT,
		@tran_name VARCHAR(20)

	BEGIN TRY
		SELECT @team_id = inserted.id_params_team, @paramedic_salary = employee.salary
		FROM inserted
		INNER JOIN employee
		ON inserted.dni = employee.dni

		SELECT @team_members_count = (SELECT COUNT(*) FROM paramedics_team WHERE id_params_team = @team_id)

		BEGIN TRANSACTION @tran_name;

		UPDATE paramedics_team
		SET operation_fee = (operation_fee + @paramedic_salary) / @team_members_count
		WHERE id_params_team = @team_id

		COMMIT TRANSACTION @tran_name;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION @tran_name;
	END CATCH

CREATE TRIGGER update_ambulance_milage
ON dispatch
AFTER UPDATE
AS
SET NOCOUNT ON	
	DECLARE
		@ambulance_id INT,
		@deployment_distance INT

	BEGIN TRY
		IF ((SELECT status FROM inserted) = 'completado')
		BEGIN
			SELECT @ambulance_id = id_ambulance, @deployment_distance = distance FROM inserted
			
			BEGIN TRANSACTION;
			UPDATE ambulance
			SET mileage = mileage + @deployment_distance
			WHERE ambulance.id_ambulance = @ambulance_id
			COMMIT TRANSACTION;
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH

			