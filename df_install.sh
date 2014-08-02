# !/bin/bash
################
SRCFOLDER=~/Jeux/src/df
TMPARCHIVE="archive_temp"
CFOLDER=current
INF="\033[34m[INFO]:\033[0m"
ERR="\033[31m[ERROR]:\033[0m"
STY="\033[33m"
ENC="\033[0m"
################
 
string=$(curl http://www.bay12games.com/dwarves/dev_release.rss | sed -n '/DF [    0-9]./p')
removePrefix=${string#*DF [0-9]*.}
result=${removePrefix% R*}

echo "\033[32m[START]\033[0m"

rawVersion=$result

echo "$INF The latest version is $STY${rawVersion}$ENC"

echo "$INF Go to source folder: $STY${SRCFOLDER}$ENC"

#Go to the source fodlder
cd "$SRCFOLDER"
  
echo "$INF Refactor version string: $STY${1}$ENC"
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
