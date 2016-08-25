#!./bashtard
#!/nuttin
echo "Wow! $0 ${@}"
cat >bashtard <<EOF
#!/usr/bin/env python3
import sys, time
print("Wow!", sys.argv)
time.sleep(60)
EOF
chmod +x bashtard
sleep 60
