create or replace package pkg_log is

gc_in_progress             logger.batches.status%type := 'IN_PROGRESS';
gc_completed_successfully  logger.batches.status%type := 'COMPLETED_SUCCESSFULLY';
gc_completed_with_warnings logger.batches.status%type := 'COMPLETED_WITH_WARNINGS';
gc_completed_with_errors   logger.batches.status%type := 'COMPLETED_WITH_ERRORS';

---------------------------------------
-- returns newly created batches.id
procedure sp_start_batch(pv_module     in logger.batches.module%type,
                         pv_server     in logger.batches.server%type,
                         pv_parameters in logger.batches.parameters%type default null,
                         pn_batch_id   out logger.batches.id%type);

---------------------------------------
procedure sp_finish_batch_successfully(pn_batch_id logger.batches.id%type);

---------------------------------------
procedure sp_finish_batch_with_errors(pn_batch_id logger.batches.id%type);

---------------------------------------
procedure sp_finish_batch_with_warnings(pn_batch_id logger.batches.id%type);

---------------------------------------
procedure sp_log_message(pv_text      in logger.log.text%type default null,
                         pv_clob_text in logger.log.clob_text%type default null,
                         pv_type      in logger.log.type%type default 'I',
                         pn_qty       in logger.log.qty%type default null,
                         pn_batch_id  in logger.batches.id%type);

---------------------------------------
function sf_get_server_name
  return logger.batches.server%type;

end pkg_log;
/

create or replace package body pkg_log is

---------------------------------------
procedure sp_start_batch(pv_module     in logger.batches.module%type,
                         pv_server     in logger.batches.server%type,
                         pv_parameters in logger.batches.parameters%type default null,
                         pn_batch_id   out logger.batches.id%type)
as
  pragma autonomous_transaction;
begin
  select seq_logger.nextval
  into pn_batch_id
  from dual;
  --
  insert into batches(id, module, parameters, server)
  values (pn_batch_id, pv_module, pv_parameters, pv_server);
  --
  commit;
  --
  pkg_log.sp_log_message(pv_text => 'start', pn_batch_id => pn_batch_id);
exception
  when others then rollback;
end sp_start_batch;

---------------------------------------
procedure sp_finish_batch_successfully(pn_batch_id logger.batches.id%type)
as
  pragma autonomous_transaction;
begin
  if (pn_batch_id is null) then
    raise_application_error(-20101, 'PN_BATCH_ID is null. Can not finish empty batch');
  end if;
  --
  update batches
    set finish_dtm = systimestamp,
        status     = pkg_log.gc_completed_successfully
  where id = pn_batch_id;
  --
  commit;
  --
  pkg_log.sp_log_message(pv_text => 'completed successfully', pn_batch_id => pn_batch_id);
exception
  when others then rollback;
end sp_finish_batch_successfully;

---------------------------------------
procedure sp_finish_batch_with_errors(pn_batch_id logger.batches.id%type)
as
  pragma autonomous_transaction;
begin
  if (pn_batch_id is null) then
    raise_application_error(-20101, 'PN_BATCH_ID is null. Can not finish empty batch');
  end if;
  --
  update batches
    set finish_dtm = systimestamp,
        status     = pkg_log.gc_completed_with_errors
  where id = pn_batch_id;
  --
  commit;
  --
    pkg_log.sp_log_message(pv_text => 'completed with errors', pv_type => 'E', pn_batch_id => pn_batch_id);
exception
  when others then rollback;
end sp_finish_batch_with_errors;

---------------------------------------
procedure sp_finish_batch_with_warnings(pn_batch_id logger.batches.id%type)
as
  pragma autonomous_transaction;
begin
  if (pn_batch_id is null) then
    raise_application_error(-20101, 'PN_BATCH_ID is null. Can not finish empty batch');
  end if;
  --
  update batches
    set finish_dtm = systimestamp,
        status     = pkg_log.gc_completed_with_warnings
  where id = pn_batch_id;
  --
  commit;
exception
  when others then rollback;
end sp_finish_batch_with_warnings;

---------------------------------------
procedure sp_log_message(pv_text      in logger.log.text%type default null,
                         pv_clob_text in logger.log.clob_text%type default null,
                         pv_type      in logger.log.type%type default 'I',
                         pn_qty       in logger.log.qty%type default null,
                         pn_batch_id  in logger.batches.id%type)
as
  pragma autonomous_transaction;
begin
  insert into log(batch_id, text, clob_text, type, qty)
  values (pn_batch_id, pv_text, pv_clob_text, upper(pv_type), pn_qty);
  commit;
exception
  when others then rollback;
end sp_log_message;

---------------------------------------
function sf_get_server_name
  return logger.batches.server%type
as
  vv_server_name logger.batches.server%type;
begin
  select sys_context('USERENV','SERVER_HOST')
  into vv_server_name
  from dual;

  return vv_server_name;
end sf_get_server_name;

end pkg_log;
/
