# GIT-rsync Backup Script

A Bash script designed to automate the backup of remote websites (files and MySQL databases) to a local directory. It leverages **Git** to version control the backups, providing an incremental history of changes, and **rsync** for efficient file transfer.

## Project Overview

*   **Name**: GIT-rsync Backup Script
*   **Description**: This tool mirrors a remote website's file system and database to a local machine. It initializes a Git repository in the backup directory, commits changes after every backup run, and optionally pushes the history to a remote Git repository (like GitHub or Bitbucket).
*   **Status**: Production-ready for basic use cases.

## Tech Stack

The script relies on standard Unix/Linux utilities:

*   **Bash**: Core scripting language.
*   **Git**: For version control and history management.
*   **Rsync**: For efficient, incremental file synchronization.
*   **SSH**: For secure communication with the remote server.
*   **MySQL (mysqldump)**: For database backups.

## Project Structure

```text
.
├── backup.sh       # The main configuration and execution script
└── README.md       # Project documentation
```

## Features

*   **Incremental File Backups**: Uses `rsync` to pull only changed files from the remote server.
*   **Database Backup**: Dumps remote MySQL databases and stores them as `.sql` files.
*   **Version Control**: Automatically commits file and database changes to a local Git repository with a timestamp.
*   **Remote Git Push**: Optionally pushes the backup history to an external Git remote (e.g., GitHub, GitLab).
*   **File Exclusion**: Configurable support for excluding specific directories (e.g., cache, temporary uploads) from the backup.

## Installation & Setup

### Prerequisites

**Local Machine**:
*   Linux/Unix-like environment.
*   Installed packages: `git`, `rsync`, `ssh`.
*   **SSH Keys**: For automated backups without password prompts, you must configure passwordless SSH key authentication between the local machine and the remote server.

**Remote Server**:
*   SSH access.
*   `rsync` installed.
*   `mysqldump` installed (for database backups).
*   The user must have read permissions for the files and `mysqldump` permissions for the database.

### Configuration

1.  Clone or download this repository.
2.  Open `backup.sh` in a text editor.
3.  Modify the configuration variables at the top of the file:

    ```bash
    # Site Configuration
    SITE_NAME="mysite"          # Identifier for the site
    SSH_USER="root"             # Remote SSH user
    SSH_PORT=22                 # Remote SSH port

    # Database Configuration
    BACKUP_DB=1                 # 1 to enable, 0 to disable
    DB_NAME="mydb"              # Database name
    DB_USER="dbuser"            # Database username
    DB_PASS="dbpass"            # Database password

    # Git Configuration
    REMOTE_GIT_ENABLED=0        # 1 to push to remote git repo
    REMOTE_GIT_PATH=""          # URL of the remote git repo (e.g., git@github.com:user/repo.git)

    # File Exclusion
    EXCLUDE_ENABLED=1
    EXCLUDE_FOLDERS=( 'wp-content/cache' 'temp' )
    ```

### Important Path Configuration

The script currently defaults to saving backups in `/root/backups/sites/`. **If you run this script as a non-root user**, you **must** change the `BACKUP_PATH` variable to a directory you have write access to (e.g., `/home/youruser/backups`).

```bash
# Modify this line in backup.sh if not running as root
BACKUP_PATH="/path/to/your/writable/directory/$SITE_NAME"
```

## Usage

Once configured, simply execute the script:

```bash
./backup.sh
```

**Note**: Ensure the script is executable (`chmod +x backup.sh`).

### Automation

To run backups automatically (e.g., daily), add a cron job:

1.  Run `crontab -e`.
2.  Add a line like the following (runs every day at 3 AM):

    ```cron
    0 3 * * * /path/to/backup.sh >> /path/to/backup.log 2>&1
    ```

## License

GPL V2
