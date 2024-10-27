-- Create the user 
create user LOGGER
  default tablespace DATA
  temporary tablespace TEMP
  profile DEFAULT;
-- Grant/Revoke role privileges 
grant select_catalog_role to LOGGER;
-- Grant/Revoke system privileges 
grant alter any table to LOGGER;
grant alter session to LOGGER;
grant comment any table to LOGGER;
grant create any index to LOGGER;
grant create any table to LOGGER;
grant create any view to LOGGER;
grant create procedure to LOGGER;
grant create public synonym to LOGGER;
grant create sequence to LOGGER;
grant create session to LOGGER;
grant create table to LOGGER;
grant create trigger to LOGGER;
grant create type to LOGGER;
grant create view to LOGGER;
grant debug connect session to LOGGER;
grant restricted session to LOGGER;
grant select any dictionary to LOGGER;
grant select any table to LOGGER;
grant unlimited tablespace to LOGGER;
grant drop public synonym to LOGGER;
