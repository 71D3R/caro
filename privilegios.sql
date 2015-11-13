-- se crea la bd de prueba
CREATE DATABASE pruebaPermisos;
GO

-- se indica cual bd vas a usar
USE pruebaPermisos;
GO

-- se revocan o eliminan los permisos CONNECT 
-- a los usuarios que no tienen el permiso CONNECT
-- de manera explicita, no lo heredaron del servidor
-- o no tienen los roles en la bd
-- * esto es opcional pero se utiliza mucho en produccion
-- para la seguridad de la bd
REVOKE CONNECT FROM GUEST;
GO

-- se crea una tabla de prueba
CREATE TABLE miTabla (
    miColumna int
);
GO

-- insertamos valores
INSERT INTO miTabla VALUES (1);
GO

-- creamos el inicio de sesion en el servidor
-- es la manera en que ya lo hemos hecho  
-- y se crea sin permisos
CREATE LOGIN miLogin WITH PASSWORD='miPassword', CHECK_POLICY = OFF
GO

-- Cuando tratemos de darle permisos al inicio
-- de sesion va a dar un error de que no se encontro ese inicio de sesion
-- Cannot find the user 'miLogin', because it does not exist or you do not have permission.
GRANT SELECT TO miLogin;
GO 

-- ahora crearemos un usario de la bd
-- que pueda usar ese login para iniciar sesion
-- este metodo tambien ya lo viste
CREATE USER miUsuario FOR LOGIN miLogin;
GO

-- ahora si ya le damos permisos
-- al usuario ya no nos dara problemas
-- en este caso solo le damos permiso de usar 
-- la funcion select
GRANT SELECT TO miUsuario;
GO

-- aqui podras ver que la bd principal
-- ya le concedio algunos permisos al usuario
-- miUsuario
-- you can now see that the database principal
-- has been granted some permissions
SELECT pe.class_desc
    ,OBJECT_NAME(pe.major_id) AS target_object_name
    ,pe.permission_name
    ,pr.name AS grantee
    ,pr.type_desc
FROM sys.database_permissions AS pe
LEFT JOIN sys.database_principals AS pr
    ON pe.grantee_principal_id = pr.principal_id
WHERE pr.name = 'miUsuario';
GO


-- class_desc  target_object_name  permission_name  grantee   type_desc
-- ----------- ------------------- ---------------- --------- ----------
-- DATABASE    NULL                SELECT           miUsuario  SQL_USER


-- miUsuario ya tiene permisos para hacer consultas SELECT
-- pero si te intentas conectar como miUsuario a la bd principal
-- te dira que no tienes el privilegio CONNECT para realizarlo
-- te dara un error similar a 
-- The server principal "miLogin" is not able to access the database "pruebaPermisos" under the current security context.
EXECUTE AS USER = 'miUsuario';
GO

-- Igual que con el privilegio SELECT
-- le concedemos el permiso CONNECT a miUsuario
GRANT CONNECT TO miUsuario;
GO

-- Y si tratas de conectarte nuevamente
-- ya podras hacerlo de manera exitosa
-- Las siguientes consultas ya las va a
-- realizar con el usuario miUsuario
EXECUTE AS USER = 'miUsuario';
GO

USE pruebaPermisos
GO

SELECT *
FROM miTabla;

REVERT;
GO
