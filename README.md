# Fun With Linux!

Someplace to deposit snippets, thoughts and miscellany on Tux Life.

## Fun With Sha-Bangs

Y'know... the little `#!` at the beginning of scripts.

First, if you haven't tried it, do a quick `man magic`. [The sha-bang is in fact a two byte _magic number_](http://www.tldp.org/LDP/abs/html/sha-bang.html) that tells the OS the given file is an executable shell script. Usually the given file is `/usr/bin/env` with `bash` or `python3` passed as an argument.

In truth, the given file can be any executable, which can lead to some interesting behavior.

Consider this example. Paste the following into a file named `shabang-bashtard.sh` and make it executable:

```bash
#!./bashtard
#!/nuttin
echo "Wow! $0 ${@}"
cat >bashtard <<EOF
#!/usr/bin/env python3
import sys
print("Wow!", sys.argv)
EOF
chmod +x bashtard
```

You can see this is some Bash scripting, trying to `echo` the command-line arguments and then `cat` some Python to a `bashtard` file. Let's try to run this script.

```
$ ./shabang-bashtard.sh What?
bash: ./shabang-bashtard.sh: ./bashtard: bad interpreter: No such file or directory
```

There's no executable named `./bashtard` to act as an interpreter, so the magic fizzles. That's too bad, it looked like a promising script. I especially like the pointless `#!/nuttin` comment.

Ahh, but what if we `source` our script instead? Since we're lazy, let's just hit the up arrow, delete the `/` and hit return.

```
$ . shabang-bashtard.sh What?
Wow! /bin/bash What?
```

Kinda weird, right? When we sourced the file, it ignored the sha-bang and just executed the Bash `echo` statement, spilling out all the command-line arguments. This makes sense: we can see that `$0` is `/bin/bash` the current shell into which we sourced the script. But did it create the `bashtard` executable?

```
$ ls
bashtard  shabang-bashtard.sh
```

And would you look at that! Now we can try executing `shabang-bashtard.sh` again. Let's see if our generated Python script will act as a command interpreter.

```
$ ./shabang-bashtard.sh What?
Wow! ['./bashtard', './shabang-bashtard.sh', 'What?']
```

Our Python script spits out the arguments, and as you can see `bashtard` is invoked with the full arguments that we passed to `shabang-bashtard.sh`, including `shabang-bashtard.sh` itself.

Nifty, right?

But what's going on under the hood? Let's change our script a bit and find out. Let's add some `sleep`.

```bash
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
```

Now open another terminal and get ready to check running processes with `ps`.

First, do `. shabang-bashtard.sh` and while it sleeps check the processes. Not much to see, since we sourced into an already running shell.

```
$ ps fx | grep bash
 2643 pts/4    Ss+    0:00  |   |       \_ /bin/bash
 3324 pts/0    S+     0:00  |   |           \_ grep --colour=auto bash
```

Now that `bashtard` has been created, do `./shabang-bashtard.sh` and while it sleeps we'll check again.

```
$ ps fx | grep bash
 2643 pts/4    Ss     0:00  |   |       \_ /bin/bash
 3329 pts/4    S+     0:00  |   |       |   \_ python3 ./bashtard ./shabang-bashtard.sh
 3331 pts/0    S+     0:00  |   |           \_ grep --colour=auto bash
```

And look at that, there's our `bashtard` running in the `python3` interpreter, as expected.