#Setting up Site Name
SITE_NAME=""
SSH_USER=""
SSH_PORT=22

#Setting up DB Credentials
BACKUP_DB=1
DB_NAME=""
DB_USER=""
DB_PASS=""
#@todo Allow passing of DB array in case of multiple databases for a single site

#If you have a remote git server as well, for push the backup enable this
REMOTE_GIT_ENABLED=0
REMOTE_GIT_PATH=""

#Change the value to 1 to enable exclude folders in rsync
EXCLUDE_ENABLED=1

#Listing folders to exclude
EXCLUDE_FOLDERS=( 'wp-content/cache' 'wp-content/uploads/backupbuddy_backups' 'wp-content/uploads/pb_backupbuddy' );

#Setting up Remote path to be backed up
REMOTE_PATH="/var/www/$SITE_NAME"

#Setting up backup baths
BACKUP_PATH="/root/backups/sites/$SITE_NAME"
BACKUP_PATH_FILES="$BACKUP_PATH/files"
BACKUP_PATH_DB="$BACKUP_PATH/db"

#Creating exclude string for rsync
EXCLUDE_STRING=""
if [ "$EXCLUDE_ENABLED" -eq 1 ]; then
    for i in "${EXCLUDE_FOLDERS[@]}"
    do
        EXCLUDE_STRING+=" --exclude=$i"
    done
fi

#Creating paths that don't exist and initialize git
if [ ! -d "$BACKUP_PATH" ]; then
    mkdir -p $BACKUP_PATH
    cd $BACKUP_PATH
    git init
    if [ "$REMOTE_GIT_ENABLED" -eq 1 ]; then
        git remote add origin $REMOTE_GIT_PATH
    fi
fi
if [ ! -d "$BACKUP_PATH_FILES" ]; then
    mkdir -p $BACKUP_PATH_FILES
fi
if [ ! -d "$BACKUP_PATH_DB" ]; then
    mkdir -p $BACKUP_PATH_DB
fi

#Backing up the site
rsync -e "ssh -p $SSH_PORT" -az --delete $EXCLUDE_STRING $SSH_USER:$REMOTE_PATH/ $BACKUP_PATH_FILES/
if [ "$BACKUP_DB" -eq 1 ]; then
    ssh $SSH_USER -p $SSH_PORT "mysqldump --opt --extended-insert=FALSE -u '$DB_USER' -p'$DB_PASS' '$DB_NAME'" > $BACKUP_PATH_DB/$DB_NAME.sql
fi

#Committing backup to the git
cd $BACKUP_PATH
git add -A
git commit -am "$(date)"
if [ "$REMOTE_GIT_ENABLED" -eq 1 ]; then
    git push origin master
fi
