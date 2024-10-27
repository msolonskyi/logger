-- Create table
create table BATCHES
(
  id         NUMBER(12) not null,
  start_dtm  TIMESTAMP(6) default SYSTIMESTAMP not null,
  finish_dtm TIMESTAMP(6),
  module     VARCHAR2(256) not null,
  parameters VARCHAR2(4000),
  status     VARCHAR2(32) default 'IN_PROGRESS' not null,
  server     VARCHAR2(4000) not null
);
-- Create/Recreate primary, unique and foreign key constraints 
alter table BATCHES
  add constraint PK_BATCHES primary key (ID);
-- Create/Recreate check constraints 
alter table BATCHES
  add constraint CHK_BATCHES
  check (STATUS IN ('IN_PROGRESS', 'COMPLETED_WITH_WARNINGS', 'COMPLETED_WITH_ERRORS', 'COMPLETED_SUCCESSFULLY'));
