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

try:
    import fcntl
except:
    pass

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
print "Uploading {0} to {1} - sketch: {2} hardware device: {3}".format(args[0], args[1], args[2], args[3])
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
    try:
        fcntl.flock(s.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
    except IOError:
        print 'Port {0} is busy'.format(args[1])
        sys.exit(-1)
    except:
        pass #windows doesn't have fcntl so ignore thisZ

except serial.serialutil.SerialException as err:
    print "Error opening serial port" , args[1], ":" , err
    print "Double check the serial port is available and retry."
    print "Upload Failed"
    sys.exit(-1)
except IOError as err:
    print "Error opening serial port" , args[1], ": IOError:" , err
    print "Double check the serial port is available and retry."
    print "Upload Failed"
    sys.exit(-1)
except:
    print "Error opening serial port" , args[1], ":", sys.exc_info()[0]
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
 
    readString = list(s.read(7))
    chipIdString = list(s.read(9))
    s.timeout=1
    count = 0
    startTime = time.clock()
    timeout = 10.0
    
    while(chipIdString != list(" ChipID: ")):
        readString[0:-1] = readString[1:]
        readString[-1] = chipIdString[0]
        chipIdString[0:-1] = chipIdString[1:]
        chipIdString[-1] = s.read(1)
        if(time.clock() - startTime > timeout):
            print "Failed to find bootloader before timeout. Aborting upload."
            sys.exit(-1)
    
    
    
    print "Firmware Version: "  + ''.join(readString)
    
    
    
    #check for a device type printout and compare the software device against the hardware device.
    s.timeout = 2
    found = True
    if(wait_until(s, 'T', 1) == True):
        found = found and wait_until(s, 'y', 1)
        found = found and wait_until(s, 'p', 1)
        found = found and wait_until(s, 'e', 1)
        found = found and wait_until(s, ':', 1)
        if(found == True):
            readString = s.read(16)
            readString = readString.strip()
            
            if(readString == args[3]):
                print "Verified hardware/software device match."
            else:
                print "Device Mismatch!!!"
                print "Hardware Device:" + readString
                print "Software Device:" + args[3]
                print "Change device selection in Tools->Board So the Software is built for the correct device."
                sys.exit(-1)
    else:
        print "Warning: Unknown Hardware Device! Uploading anyways!"
    
    s.timeout = None
    
    
    s.sendBreak(0.25)
    s.write(' ')
    s.sendBreak(0.25)
    
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
    print "Serial port" , args[1], "encountered an error:" , err
    print "Double check the serial port is available and retry."
    print "Upload Failed"
    sys.exit(-1)
except IOError as err:
    print "Serial port" , args[1], "encountered an error: IOError:" , err
    print "Double check the serial port is available and retry."
    print "Upload Failed"
    sys.exit(-1)
except:
    print "Serial port" , args[1], "encountered an error:", sys.exc_info()[0]
    print "Double check the serial port is available and retry."
    print "Upload Failed"
    sys.exit(-1)
    
sys.exit(0)
