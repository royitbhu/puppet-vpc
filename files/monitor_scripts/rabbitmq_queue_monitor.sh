#!/usr/bin/env python

import os
import re
import time

#interval in second for each rabbitmqctl output
INTERVAL = 3
ITERATION = 5

#variables for storing hostname and corresponding queuesize.
hostName = []
queueSize = [[] for _ in range(ITERATION)]
totalQueues = 0

#Status for OMD server
STATUS = {"success" : 0,
    "warning" : 1,
    "critical" : 2,
     }

#output format supported by OMD server
OUTPUT_FORMAT = "{status} {entity} - {message}"

#function to parse 'rabbitmqctl list_queues' output and store it in queueSize
def getQueueSize(x):
        cmd = "rabbitmqctl list_queues"
        out = os.popen(cmd).read()
        global totalQueues
        #totalQueues = out.count('\n')
        lines = out.splitlines()
        pattern = '(\S+)\s+(\d+)'
	i = 0
        for line in lines:
                matchObj = re.match(pattern, line, re.M|re.I)
                if matchObj:
                        if x == 0:
                                hostName.append(matchObj.group(1))
                                totalQueues = totalQueues + 1
                        queueSize[x].append(int(matchObj.group(2)))
        return

for i in range(ITERATION):
        getQueueSize(i)
        time.sleep(INTERVAL);

#Verify if any queue is continuously growing
for i in range(totalQueues):
        flag = 0
	msg = ""
        for j in range(ITERATION-1):
                if queueSize[j][i] == 0:
                        flag = 0
                        break;
                elif queueSize[j][i] <= queueSize[j+1][i]:
                        flag = 1
                else:
                        flag = 0
                        break;
        if flag == 1:
		msg = "CRITICAL: " + "Queue for host {} not getting consumed, Please take appropiate action.".format(hostName[i])
                status = STATUS.get("critical")
        else:
		msg = "OK: " + "Queue for host {} is normal, No action required.".format(hostName[i])
                status = STATUS.get("success")
	print OUTPUT_FORMAT.format(status=status, entity="RabbitMQ:QueueSize", message=msg)
