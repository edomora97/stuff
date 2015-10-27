from time import gmtime, strftime
import cherrypy
import os

class Root(object):

    @cherrypy.expose
    def index(self):
        raise cherrypy.HTTPRedirect("index.html")

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def time(self):
        f = os.popen('date')
    	return { "time" : f.read() }

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def uptime(self):
		f = os.popen('uptime')
		up = f.read().split(',')
		return { "uptime" : up[:(len(up)-7)] }

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def users(self):
		f = os.popen('w -h')
		data = f.read()
		res = []
		for user in data.splitlines():
			x = filter(None, user.split(' '))
			y = {
				"user"	: x[0],
				"tty"	: x[1],
				"from"	: x[2],
				"when"	: x[3],
				"idle"	: x[4],
				"jcpu"	: x[5],
				"pcpu"	: x[6],
				"what"	: x[7:]
			}
			res.append(y)
		return res

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def process(self):
		f = os.popen('ps --no-headers aux')
		data = f.read()
		res = []
		for proc in data.splitlines():
			x = filter(None, proc.split(' '))
			y = {
				"user"	: x[0],
				"pid"	: x[1],
				"cpu"	: x[2],
				"mem"	: x[3],
				"tty"	: x[6],
				"start"	: x[8],
				"time"	: x[9],
				"command": x[10:]
			}
			res.append(y)
		return res

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def disk(self):
		f = os.popen('df -h -t ext4 -t ext3 -t fat32 -t ntfs -t vfat | tail -n +2')
		data = f.read()
		res = []
		for proc in data.splitlines():
			x = filter(None, proc.split(' '))
			y = {
				"device": x[0],
				"size"	: x[1],
				"used"	: x[2],
				"free"	: x[3],
				"perc"	: x[4],
				"mount"	: x[5]
			}
			res.append(y)
		return res

    @cherrypy.expose
    @cherrypy.tools.json_out()
    def load(self):
		f = os.popen('cat /proc/loadavg')
		data = f.read()
		usage = filter(None, data.split(' '))
		res = {
			"load1m" : usage[0],
			"load5m" : usage[1],
			"load15m" : usage[2],
		}
		return res

if __name__ == '__main__':
   cherrypy.quickstart(Root(), '/', 'app.conf')
