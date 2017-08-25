import subprocess as sp
import sys
from datetime import datetime
from dateutil.parser import *

rawtimings = sp.check_output ('egrep "^\[" {}'.format (sys.argv[1]), shell=True).decode ('utf-8').split ('\n')

events = {}
last_time = parse ("12:00:00")
for l in rawtimings:
    event = l.split (']')
    try:
        ts = datetime.strptime (event[0], "[%H:%M:%S")
    except ValueError:
            break

    events [event[1].strip ()] = ts
    
#    print (events)
    print (ts, ts - events ['Begin /pi-gen'], ts - last_time, "{}".format (event [1]))
    last_time = ts


#print (rawtimings)

