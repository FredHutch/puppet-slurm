#!/usr/bin/env python

# Accounting post-processor from Slurm job completion logs

import sys,getopt,hostlist
import datetime,time
from operator import itemgetter
import gzip
import smtplib
import ldap

SENDER="root@fhcrc.org"
RECIPIENTS=["<addr>@fhcrc.org",]  # separate multiple addresses with comma / phshelpdesk@fhcrc.org,
MAILHOST="mx.fhcrc.org"

try:
  conn = ldap.initialize('ldap://<servername>:389')
  conn.simple_bind_s('*******@fhcrc.org','**************')
except ldap.LDAPError, error_message:
  print ("Couldn't Connect to LDAP server:  %s " % error_message)
  sys.exit()

users=[] 
partitions=[]

def get_users_canceled_jobs(filename,partitions,days=0):
  matchlines=''
  try:
    that_day = datetime.date.today() - datetime.timedelta(days=days)
    for line in open(filename,'r'):
      parse_state=0
      for field in line.strip().split():
        if '=' not in field: # probably failed job
          continue
        name,value=field.split('=',1)
        # Ignore FAILED and NODE_FAIL jobs
        if name=="JobState" and value not in ["XXX","CANCELLED"]:
          parse_state=1
          break
        elif name=="Partition":
          if partitions and value not in partitions:
            parse_state=1
            break
        elif name=="EndTime":
          end_time=parse_time(value)
          if end_time.date() < that_day:
            parse_state=1;
            break
        elif name=="UserId": # assume uid(uidnumber) format
          user=value.split('(')[0] 
      # line is not filtered, please process
      if parse_state == 0:
        if not user in users:        
          results = getLdapAttributes(user,['mail'])
          for key, values in results.items():
            for value in values:
              if value:
                if not value.endswith("@fhcrc.org"):
                  user=value
          if not user in users:
            users.append(user)
        matchlines=matchlines+line+'\n'
    return users,matchlines

  except IOError:
    print "Error: cannot open completions file '"+filename+"'"

def getLdapAttributes(user,attributes=None):
  resultSet = []
  if user.startswith("CN="):
    id = conn.search(user,ldap.SCOPE_BASE,'(objectClass=*)',attributes)
  else:
    id = conn.search('dc=fhcrc,dc=org',ldap.SCOPE_SUBTREE,'(sAMAccountName=%s)' % user,attributes)
  while True:
    try:
      resultType, resultData = conn.result(id, 0)
    except:
      break
    if not resultData:
      break
    elif resultType == ldap.RES_SEARCH_ENTRY:
      resultSet.append(resultData)
  results = resultSet[0][0][1]
  return results

# parse Slurm time format yyyy-mm-ddThh:mm:ss ex:2011-01-04T11:33:03
def parse_time(job_comp_time):
  date_str,time_str=job_comp_time.split('T')
  date=map(int,date_str.split('-'))
  time=map(int,time_str.split(':'))

  d=datetime.date(date[0],date[1],date[2])
  t=datetime.time(time[0],time[1],time[2])

  return datetime.datetime.combine(d,t)

def sendMsg(to,subject='',text=''):
  headers="From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n" % (SENDER,", ".join(to),subject)
  try:
    session=smtplib.SMTP(MAILHOST)
    result=session.sendmail(SENDER.lower(),to,headers+text)
  except:
    print "Error sending notification email"

def concatAttr(*args):
    """concatenate lists (separated by space) and strings (separated by comma) to a single string"""
    newstr=''
    for arg in args:
        if arg is not None:
            try:
                newstr += ', '+arg
            except:
                newstr += ', '+';'.join(arg)
    return newstr[2:]

def getMsgBody(days, users, matchlines):
  body = """
The following users canceled jobs on Gizmo in the last %s days (0 days = today):

%s

Details:
%s

""" % (days, users, matchlines)
  return body

def usage():
   print "xxxx [options] job_completion_log[.gz] ..."
   print "\t-h show this help"
   print "\t-p partitions:limit data to certain partitions (comma separated)"
   print "\t-d show only the last x days: -d 0 -> today"
   print "\t-l ldap demo: -l userid"

def main(argv):
  try:
    opts,args=getopt.getopt(argv,"d:h:l:p")
    days=0
    for opt,arg in opts:
      if opt in ("-h"):
        usage()
        sys.exit()
      elif opt in ("-l"):
        print("**** DEMO getLdapAttributes ****")
        #results=getLdapAttributes(arg)
        results=getLdapAttributes(arg,['distinguishedName', 'mail','manager','title','department','division','uid','sn',\
             'givenName','displayName','uidNumber','gidNumber','gecos','loginShell','unixHomeDirectory','fhcrcpaygroup',\
             'physicalDeliveryOfficeName','telephoneNumber','directReports','logonCount','lastLogonTimestamp','publicDelegates'])
        for key, values in results.items():
          print(key)
          for value in values:
            print("\t%s" % value)
        sys.exit()
      elif opt in ("-p"): # add to list of included partitions
        partitions.extend(arg.split(','))
      elif opt in ("-d"):
        days = int(arg)
    if not args:
      args.append('/var/log/slurm-llnl/slurmjobcomp.log')      
    for filename in args:
      users,matchlines=get_users_canceled_jobs(filename,partitions,days)
      if users:
        users.sort()
        subject="Gizmo: %s users with %s canceled jobs in the last %s days" % \
              (len(users), len(matchlines.split('\n'))/2, days)
        sendMsg(RECIPIENTS, subject, getMsgBody(days,concatAttr(users),matchlines))

  except getopt.GetoptError:
      usage()

if __name__ == '__main__':
  main(sys.argv[1:])


