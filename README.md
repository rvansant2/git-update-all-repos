# Git Update All Repos Bash Script

This script updates all git repositories within a given directory or path. It can be easily aliased in a shell profile for quick execution. What sets this script apart is its ability to safely handle local changes by stashing them before switching branches and pulling the latest changes, helping avoid merge conflicts and making repository updates smoother.

## Git started :)
- Create a scripts directory via the command `mkdir scripts`, if you do not have one already.
- Then change directory via `cd scripts` and clone the repo in the `scripts` directory via command `git clone git@github.com:rvansant2/git-update-all-repos.git`
- Change into directory via command `cd git-update-all-repos`
- Ensure the script is executable using the following command: `chmod +x git_update_all_repos.sh`
- Add the following to your bash or zsh or fish profile: `alias gitupdate="~/scripts/git-update-all.sh PATH_TO_PROJECTS_DIRECTORY (e.g., ~/Projects)"`
- View changes in terminal shell or in log created in `git-update-all-repos` directory called: `gitupdateallrepos.log`

