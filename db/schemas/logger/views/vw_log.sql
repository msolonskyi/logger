create or replace view vw_log as
select dtm, batch_id, text, clob_text, type, qty, id, start_dtm, finish_dtm, module, parameters, status, server
from batches b, log l
where b.id = l.batch_id
/
