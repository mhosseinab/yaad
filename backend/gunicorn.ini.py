"""gunicorn WSGI server configuration."""
from multiprocessing import cpu_count
from os import path, environ


bind = environ.get("GUNICORN_BIND", default="127.0.0.1:8800")
worker_class = 'gevent'
worker_connections = 100
max_requests  = 100
keep_alive = 3
#worker_class = 'eventlet'
workers = 2*cpu_count()
threads = 2*cpu_count()+1
reload = True
chdir = path.dirname(path.abspath(__file__))
#daemon = True
pidfile = "/var/run/gunicorn.pid "
user = "daemon"
group = "daemon"
forwarded_allow_ips = "127.0.0.1"
errorlog = "/var/log/gunicorn-error.log"
loglevel = "info"
capture_output = False
#capture_output = True


