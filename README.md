# Dotfiles Repo

- This repository contains my personal dotfiles and scripts for deployment/updates.

- deploy_dotfiles.sh -> Copies dotfiles from ~/.dotfiles into their respective directories
- update_repo.sh -> Copies current dotfiles back into the repo and pushes to GitHub

- To copy individual files, use cp -v SOURCE_FILE TARGET_FILE
- To copy whole directories, use cp -rv SOURCE_DIR/ TARGET_DIR/
- To copy only the conentents of a directory, use cp -rv SOURCE_DIR/* TARGET_DIR/ or cp -rv SOURCE_DIR/. TARGET_DIR/

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
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/PRIVATE_KEY > /dev/null 2>&1
~~~

-> eval "$(ssh-agent -s)" is needed if you're using an SSH key that requires the agent to be running.

-> mkdir -p creates the folder if it doesn’t exist and silently skips creation if it’s already there.

-> && operator is a logical AND. "Run the next command only if the previous one worked." Note: ; instead of &&: "Run the next command regardless of success or failure."

-> ssh-add ~/.ssh/PRIVATE_KEY loads your private SSH key into the ssh-agent so Git and other SSH-based tools can use it without asking for the passphrase every time.

-> > /dev/null redirects only the standard output (stdout) like any normal messages e.g. "Identity added" into the void.

-> 2>&1 additionaly redirects the standard error (stderr) like warnings or errors to the same place as standard output, i.e. the void in /dev/null.

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
