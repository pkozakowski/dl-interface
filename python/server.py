import contextlib
import io
import sys
import traceback

import msgpackrpc


class Server:

    def __init__(self):
        self._globals = {}
        self._locals = {}

    def execute(self, code):
        stdout = io.StringIO()
        stderr = io.StringIO()
        with contextlib.redirect_stdout(stdout):
            with contextlib.redirect_stderr(stderr):
                try:
                    exec(code, self._globals, self._locals)
                except Exception:
                    traceback.print_exc()
        return (stdout.getvalue(), stderr.getvalue())

if __name__ == '__main__':
    port = int(sys.argv[1])
    server = msgpackrpc.Server(Server())
    server.listen(msgpackrpc.Address('localhost', port))
    server.start()
