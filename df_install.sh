# !/bin/bash
################
CONFIG=df_install.config
SRCFOLDER=.
#TODO Set a config file to put this variables in
TMPARCHIVE="archive_temp"
CFOLDER=current
INF="\033[34m[INFO]:\033[0m"
ERR="\033[31m[ERROR]:\033[0m"
WAR="\033[33m[WARN]:\033[0m"
ISS="\033[36m[ISSUE]:\033[0m"
STY="\033[33m"
ENC="\033[0m"
################

### This function display the usage description of this script
#TODO Finish this function
usage () {
  
  echo "-h --help hello world !"
}

### This function write the config file
#TODO Add the shorcut creation part
set_config_file () {
  
  # Ask for the path of the source folder
  echo "$ISS Where would you like to install the game? (default: $(pwd)) > "
  response=
  read response
  if [ -z $response ];then
    # If there is no path specified, the default one will the current folder
    echo "$WAR The path will be: \033[32m$(pwd)\033[0m"
    response="$(pwd)"
  fi
  
  # Write the new source folder path in the config (and create the config file)
  echo "SRCFOLDER:${response}" > $CONFIG

  # Set the source folder variable to this instance
  SRCFOLDER="$response"

  # Ask for the shortcut
  #echo "$ISS Would you like to create a shortcut? (y/n) > "
  #read response
  #if [ "$response" == "y"  ];then
    
  #fi
}

### This function return the shortcut folder path from the config file (or ask for it) 
set_source_folder () {
  if [ -f $CONFIG ];then
    srcfolder_line=$(cat $CONFIG | grep "SRCFOLDER")
    SRCFOLDER="${srcfolder_line#*:}"
  else
    set_config_file
  fi
  echo "$INF The game will be installed to the path: $STY${SRCFOLDER}$ENC"
}

### This function return the shortcut folder path from the config file (or ask for it)
#TODO Finish this function
set_shortcut_folder () {
  echo "$WAR The shortcut function is not ready yet."
}


### This function get and return the latest version of Dwarf Fortress
get_latest_version () {
  
  # Get the content of the rss feed of the release canal and search for the
  #line which contains the latest version
  rssLatestRelease=$(curl -s http://www.bay12games.com/dwarves/dev_release.rss | sed -n '/DF [0-9]./p')
  
  # Remove the part of the string before the version
  removePrefix=${rssLatestRelease#*DF [0-9]*.}
  
  # Remove the part of the string after the version
  result=${removePrefix% R*}
  
  # Return the version
  echo $result
}

init () {
  echo "$INF The config will be loaded from $STY${CONFIG}${ENC}. If you want to change the config, edit the file or remove it."
  set_source_folder
  set_shortcut_folder
}

### Main script begin here
echo "\033[32m[START]\033[0m"

init

rawVersion=$(get_latest_version)

echo "$INF The latest version is $STY${rawVersion}$ENC"

echo "$INF Go to source folder: $STY${SRCFOLDER}$ENC"

#Go to the source fodlder
cd "$SRCFOLDER"
  
echo "$INF Refactor version string: $STY${rawVersion}$ENC"
#Replace '.' by '_' to match the url expression
version=$( echo ${rawVersion} | tr '.' '_')

#Build the url from the version
url="http://www.bay12games.com/dwarves/df_${version}_linux.tar.bz2"  

echo "$INF Check if the url $STY${url}$ENC exist."

#Check if the url is fine
urlExist=$(curl -s --head $url | head -n 1 | grep "200")  
if [ -z "$urlExist" ];then
  echo "$ERR The url does not exist. Check the version of the game."
  exit
fi

#Create the new directory for the game sources
newDir="df_$version"
if [ -d $newDir ];then
   echo "$ERR The game version ${version} is already installed."
   exit
fi
mkdir "$newDir"
  
echo "$INF Download Dwarf Fortress verion $STY${version}$ENC\033[35m"

#Download the archive on the Bay12 serveur
echo "\033[35m" #Set the output color to magenta (35)
wget -O $TMPARCHIVE $url
echo "\033[0m" #Remove the color set

echo "$INF Extract archive: $STY$TMPARCHIVE$ENC"

#Check if the archive has been well created
if [ ! -f $TMPARCHIVE ];then
  echo "$ERR The archive does not exist."
  exit
fi

#Extract archive
tar -xjf $TMPARCHIVE -C $newDir

echo "$INF Delete archive: $STY$TMPARCHIVE$ENC"

#Remove archive
rm $TMPARCHIVE
  
echo "$INF Add lib symlinks"

rm -rf $CFOLDER #Remove previous simlink
ln -s "${newDir}/df_linux" $CFOLDER #Create new simlink

#Create lib simlink for linux
ln -s /usr/lib/i386-linux-gnu/libopenal.so.1 ./${newDir}/df_linux/libs/libopenal.so
ln -s /usr/lib/i386-linux-gnu/libsndfile.so.1 ./${newDir}/df_linux/libs/libsndfile.so

echo "\033[32m[SUCCESS]\033[0m"
### The end

