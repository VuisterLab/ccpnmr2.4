#!/usr/bin/env python
'''
Execute like: $CINGROOT/python/cing/Scripts/vCing/Utils.py
or execute from vCing.py
'''

from cing.Libs.disk import * #@UnusedWildImport
import commands

def prepareMain(main_target_dir, doClean=False):
    "Return True on error."
    cwd = os.getcwd()
    if not os.path.exists(main_target_dir):
        # Setup in April 2011. Where XXXXXX is the not to be committed pool id.
#            jd:dodos/vCingSubordinate/ pwd
#            /Library/WebServer/Documents/tmp/vCingSubordinate
#            jd:dodos/vCingSubordinate/ ls -l
#            lrwxr-xr-x  1 jd  admin  18 Apr 15 21:39 vCingXXXXX@ -> /Volumes/tetra/vCingXXXXX
        print "Creating path that probably should be created manually because it might be an indirect one: %s" % main_target_dir
        mkdirs(main_target_dir)
    if not os.path.exists(main_target_dir):
        print "ERROR: Failed to create: " + main_target_dir
        return True
    os.chdir(main_target_dir)
    for d in 'log log2 result'.split():
        if doClean:
            print "DEBUG: Removing and recreating %s" % d
            rmdir(d)
        else:
            print "DEBUG: Creating if needed %s" % d
        mkdirs(d)
    # end for
    os.chdir(cwd)
# end def

def onEachSubordinate( cmd='uptime', subordinateListFile="subordinateList.py"):
    
    subordinateList = []
    subordinateList += [ '145.100.57.%s' % x for x in range(6,7) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(41,46) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(47,51) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(52,56) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(57,61) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(62,64) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(65,78) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(79,81) ]
#    subordinateList += [ '145.100.58.%s' % x for x in range(85,97) ]
    coresTotal = 12*0 + 0*8*8 + 1*4
#    subordinateList += [ '145.100.57.%s' % x for x in range(244,252) ]
#    subordinateList += [ '145.100.57.%s' % x for x in [221,210,212] ]
    # Disable some security checks.
    n = len(subordinateList)
    print "there are %8d subordinates" % n
    print "there are %8d cores" % coresTotal
    print "there are %8.3f cores/subordinate" % (coresTotal / n)
    sshOptionList = '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
    sshOptionList += ' -q'
    i = 0
    for subordinate in subordinateList:
        i += 1
        cmdComplete = 'ssh %(sshOptionList)s i@%(subordinate)s %(cmd)s' % {                                                             
                'sshOptionList':sshOptionList, 'subordinate':subordinate, 'cmd':cmd}
        status, result = commands.getstatusoutput(cmdComplete)
        if not status:
            print "%3d %s %s" % (i, subordinate, result)
            continue
        # end if
        print "%3d %s %s" % (i, subordinate, "ERROR: Failed command: %s with status: %s with result: %s, now sleeping a short while." % (
            cmd, status, result))
        time.sleep(1)        
    # end for    
# end def
    
if __name__ == "__main__":
    if False:
        if prepareMain(sys.argv[1]):
            print "ERROR: Failed to prepareMain"
        # end if
    # end if
    if 1:    
        if onEachSubordinate():
            print "ERROR: Failed to prepareMain"
        # end if
    # end if
# end if
        