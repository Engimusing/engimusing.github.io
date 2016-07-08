#!/usr/bin/python

"""
Original Code:
  Summary: XMODEM protocol implementation.
  Home-page: https://github.com/tehmaze/xmodem
  Author: Wijnand Modderman, Jeff Quast
  License: MIT

Stripped down and modified for this bootloader by Joe George 2015-2016
"""

import sys
import serial
import time
import os
import StringIO

from calcCRC import calc_crc
from getArgs import getArgs
from tty import wait_until
from fRead import sendPackets


"""
XMODEM 128 byte blocks

    SENDER                                 RECEIVER

                                            <-- C
    SOH 01 FE Data[128] CRC CRC            -->
                                            <-- ACK
    SOH 02 FD Data[128] CRC CRC            -->
                                            <-- ACK
    SOH 03 FC Data[128] CRC CRC             -->
                                            <-- ACK
    SOH 04 FB Data[100] CPMEOF[28] CRC CRC  -->
                                            <-- ACK
    EOT                                     -->
                                            <-- ACK
"""

# Protocol bytes
SOH = chr(0x01)
STX = chr(0x02)
EOT = chr(0x04)
ACK = chr(0x06)
DLE = chr(0x10)
NAK = chr(0x15)
CAN = chr(0x18)
CRC = chr(0x43) # C

timeout = 10

args = getArgs()  # get filename and serial port
print "Uploading {0} to {1}".format(args[2], args[1])
sys.stdout.flush()

try:
    s = serial.Serial(port= args[1],
                  baudrate=115200, 
                  bytesize=8,
                  parity='N',
                  stopbits=1,
                  timeout=None,
                  xonxoff=0,
                  rtscts=0)
except serial.serialutil.SerialException as err:
    print "Error opening serial port" , args[1], ":" , err
    print "Double check the serial port is available and retry."
    print "Upload Failed"
    sys.exit(-1)

try:
    
    if(s.isOpen() == False):
        s.open()
        print args[1] + " is open already"
        sys.exit(-1)

    print "Reset Device"
    sys.stdout.flush()
    s.sendBreak(0.25)
    s.write('r')

    # loop waiting for question mark, send r and ' ' again after timeout
    print "Device Reset Check"
    sys.stdout.flush()

    cnt = timeout
    while True:
        s.write(' ')
        if(wait_until(s, '?', 1) == True):
            break;
        else:
            cnt = cnt -1
            if cnt == 0:
                print "Timed out checking for device reset."
                s.close()
                sys.exit(-1)

    
    print "Erase Previous Sketch"
    sys.stdout.flush()
    
    s.write('u')
    # loop while flash erase printing ....
    ch = 0
    mustend = time.time() + timeout
    while ((ch != '.') and (time.time() < mustend)):
        ch = s.read()
        #if ch == '.' or ch == '#':
        #    sys.stdout.write(ch)
        if(ch == '#'):
            break
        ch = 0
        
    if ch == '#':
        print "Erase Complete"
        sys.stdout.flush()
    else:
        print "Erase Error"
        print "Upload Failed"
        s.close()
        sys.exit(-1)
    
    
    #reset timeout
    mustend = time.time() + timeout
    
    
    # timeout if C doesn't come
    ch = 0
    while ((ch != 'C') and (time.time() < mustend)):
        ch = s.read()
    
    if(ch == 'C'):
        print "Upload Starting"
        sys.stdout.flush()
    else:
        print "Upload Failed to Start"
        s.close()
        sys.exit(-1)
        
    #hide sendPackets print outs from the end user
    if(sendPackets(s, args[0])):
        print "Upload Finished"
        sys.stdout.flush()
        s.write(EOT)        # end of transmission
    else:
        sys.stdout = stdout
        print "Error Uploading Sketch"
        print "Upload Failed"
        s.close()
        sys.exit(-1)

    print "Starting Sketch"
    sys.stdout.flush()
    
    #wait until ? is sent or 1 second, this allows the board enough time to finish the upload before we send the b
    wait_until(s, '?', 1) 
    
    s.write('b')

    s.close()
    print "Upload Completed Successfully"
    
except serial.serialutil.SerialException as err:
    print "Serial port " , args[1], " encountered an error:" , err
    print "Double check the serial port is available and retry."
    print "Upload Failed"
    sys.exit(-1)