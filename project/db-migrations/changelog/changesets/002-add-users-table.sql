--liquibase formatted sql
--changeset yourname:002-add-users-table

-- Este changeset originalmente se usó para documentar la creación de usuarios
-- Los usuarios se crean manualmente por el administrador antes de ejecutar Liquibase
-- No hay cambios de esquema adicionales en este changeset
SELECT 'Changeset 002 executed successfully' FROM DUAL;
