import sys
import os
import getpass

print("Me: ", sys.argv[0])
print("Args: ", sys.argv[1:])
print("File: ", __file__)
print("Name: ", __name__)
print("Exec: ", sys.executable)

print("Real uid: ", os.getuid())
print("Effective uid: ", os.geteuid())

print("I am: ", getpass.getuser())

for v in os.environ:
    print(v, "=", os.environ[v])
print()

print("Return some stuff, hit ctrl-d to end")
for l in sys.stdin:
    print("Hi ", l.rstrip('\r\n'))

print("Done")
if len(sys.argv) >1 and sys.argv[1] == 'error':
    exit(5)
