# Dotfiles Repo

- This repository contains my personal dotfiles and scripts for deployment/updates.

- deploy_dotfiles.sh -> Copies dotfiles from ~/.dotfiles into their respective directories
- update_repo.sh -> Copies current dotfiles back into the repo and pushes to GitHub

- To copy individual files, use cp -v SOURCE_FILE TARGET_FILE
- To copy whole directories, use cp -rv SOURCE_DIR/ TARGET_DIR/
- To copy only the contents of a directory, use cp -rv SOURCE_DIR/* TARGET_DIR/ or cp -rv SOURCE_DIR/. TARGET_DIR/

- WSL Error:
    - Open nvim
    - :set ff?
        - ff=unix → OK (LF)
        - ff=dos → Not OK (CRLF)
    - :set ff=unix
    - :wq

---

1. Install Git & OpenSSH

~~~bash
sudo pacman -S git openssh
~~~

---

2. Generate SSH key & add it to GitHub

~~~bash
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
mkdir -p ~/.ssh && mv PRIVATE_KEY PUBLIC_KEY.pub ~/.ssh/
ssh-add ~/.ssh/PRIVATE_KEY
cat ~/.ssh/PUBLIC_KEY.pub
~~~

-> Copy the key output and add it to GitHub → Settings → SSH and GPG keys

-> To auto-load the SSH key on startup, add at the end of ~/.bashrc:

~~~bash
# Start the SSH agent for this session
eval "$(ssh-agent -s)" > /dev/null

# Add your specific key (silencing errors if it's already there or missing)
ssh-add ~/.ssh/PRIVATE_KEY 2>/dev/null

# Automatically kill the agent when the terminal session ends
trap "ssh-agent -k > /dev/null" EXIT
~~~

-> eval "$(ssh-agent -s)" is needed if you're using an SSH key that requires the agent to be running.

-> mkdir -p creates the folder if it doesn’t exist and silently skips creation if it’s already there.

-> && operator is a logical AND. "Run the next command only if the previous one worked." Note: ; instead of &&: "Run the next command regardless of success or failure."

-> ssh-add ~/.ssh/PRIVATE_KEY loads your private SSH key into the ssh-agent so Git and other SSH-based tools can use it without asking for the passphrase every time.

-> > /dev/null redirects only the standard output (stdout) like any normal messages e.g. "Identity added" into the void.

-> 2>&1 additionaly redirects the standard error (stderr) like warnings or errors to the same place as standard output, i.e. the void in /dev/null.

---

2. Testing

Check if the Agent is running. The ssh-agent communicates via an environment variable. If this command returns a file path, the agent is active in your current session.

~~~bash
echo $SSH_AUTH_SOCK
~~~

- Success: You see something like /tmp/ssh-XXXXXX/agent.1234
- Failure: The output is blank

Verify the Key is loaded. Run this to see if the agent actually "holds" your github_test key.

~~~bash
ssh-add -l
~~~

- Success: You see the fingerprint and the path ~/.ssh/PRIVATE_KEY
- Failure: It says "The agent has no identities" or "Could not open a connection."

Test the connection to GitHub. You can test the actual handshake without cloning anything.

~~~bash
ssh -T git@github.com
~~~

- Success: You should see: "Hi [YourUsername]! You've successfully authenticated, but GitHub does not provide shell access."
- Failure: git@github.com: Permission denied (publickey) or ssh: connect to host github.com port 22: Connection timed out or Error connecting to agent: No such file or directory

---

3. Clone/Initialize repo

If the repo exists already.

~~~bash
git clone git@github.com:USERNAME/.dotfiles.git ~/.dotfiles
~~~

If the repo doesn't exist yet.

~~~bash
mkdir ~/.dotfiles && cd ~/.dotfiles
git init
git branch -M main
git remote add origin git@github.com:USERNAME/dotfiles.git
cd ~/.dotfiles
git add .
git commit -m "Initial commit"
git push -u origin main
~~~

---

4. Make shell scripts executable

~~~bash
cd ~/.dotfiles
chmod +x deploy_dotfiles.sh
chmod +x update_repo.sh
~~~

5. Deploy dotfiles // Update repo

~~~bash
./deploy_dotfiles.sh
~~~

or

~~~bash
./update_repo.sh
~~~

---
