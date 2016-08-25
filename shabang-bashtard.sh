#!./bashtard
#!/nuttin
echo "Wow! $0 ${@}"
cat >bashtard <<EOF
#!/usr/bin/env python3
import sys
print("Wow!", sys.argv)
EOF
chmod +x bashtard
