from .constants import CONNECTION_STRING, RECONNECT_IN_MIN
import datetime
import oracledb
import logzero
import socket


class Logger(object):
    def __init__(self, logfile_name: str, module_name: str):
        self.LOGFILE_NAME = logfile_name
        self.MODULE_NAME = module_name
        self._init()

    def _init(self):
        logzero.logfile(self.LOGFILE_NAME, loglevel=logzero.logging.INFO)
        logzero.logger.info('')
        logzero.logger.info('==========')
        logzero.logger.info('start')
        self._last_connected_time = datetime.datetime.now() - datetime.timedelta(minutes=2*RECONNECT_IN_MIN)
        self._re_connect_to_db()
        self.BATCH_ID = self.start_batch(self.MODULE_NAME)

    def _log_db_message(self, msg: str, type: str, qty: int = None):
        text = msg
        clob_text = ''
        if len(msg) > 4000:
            text = ''
            clob_text = msg
        try:
            self._re_connect_to_db()
            cur = self.con.cursor()
            cur.callproc('logger.pkg_log.sp_log_message', [text, clob_text, type, qty, self.BATCH_ID])
        finally:
            cur.close()
    
    def info(self, msg: str, qty: int = None):
        logzero.logger.info(msg)
        self._log_db_message(msg, 'I', qty)

    def warning(self, msg: str, qty: int = None):
        logzero.logger.warning(msg)
        self._log_db_message(msg, 'W', qty)

    def error(self, msg: str, qty: int = None):
        logzero.logger.error(msg)
        self._log_db_message(msg, 'E', qty)
            
    def _re_connect_to_db(self):
        if self._last_connected_time < datetime.datetime.now() - datetime.timedelta(minutes=RECONNECT_IN_MIN):
            self.con = oracledb.connect(CONNECTION_STRING)
            logzero.logger.info('(re)connected to DB.')
            self._last_connected_time = datetime.datetime.now()

    def start_batch(self, module: str, parameters: str = None) -> int:
        batch_id = None
        try:
            self._re_connect_to_db()
            cur = self.con.cursor()
            out_value = cur.var(oracledb.NUMBER)
            cur.callproc('logger.pkg_log.sp_start_batch', [module, socket.gethostname(), parameters, out_value])
            batch_id = int(out_value.getvalue())
        finally:
            cur.close()
        return batch_id

    def finish_batch_successfully(self):
        logzero.logger.info('')
        logzero.logger.info('completed successfully')
        logzero.logger.info('==========')
        logzero.logger.info('')
        try:
            self._re_connect_to_db()
            cur = self.con.cursor()
            cur.callproc('logger.pkg_log.sp_finish_batch_successfully', [self.BATCH_ID,])
        except Exception as e:
            logzero.logger.error(f'finish_batch_successfully: {str(e)}')
        finally:
            cur.close()


    def finish_batch_with_errors(self):
        logzero.logger.info('completed with errors')
        logzero.logger.info('==========')
        logzero.logger.info('')
        try:
            self._re_connect_to_db()
            cur = self.con.cursor()
            cur.callproc('logger.pkg_log.sp_finish_batch_with_errors', [self.BATCH_ID,])
        finally:
            cur.close()

    def finish_batch_with_warnings(self):
        logzero.logger.info('completed with warnings')
        logzero.logger.info('==========')
        logzero.logger.info('')
        try:
            self._re_connect_to_db()
            cur = self.con.cursor()
            cur.callproc('logger.pkg_log.sp_finish_batch_with_warnings', [self.BATCH_ID,])
        finally:
            cur.close()
