
# Colors
#white="\e[1;37m"
bold="\e[1m"
ul="\e[4m"
normal="\e[0m"

black="\e[30m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
magenta="\e[35m"
cyan="\e[36m"
light_gray="\e[37m"
dark_gray="\e[90m"
light_red="\e[91m"
light_green="\e[92m"
light_yellow="\e[93m"
light_blue="\e[94m"
light_magenta="\e[95m"
light_cyan="\e[96m"
white="\e[97m"

bg_black="\e[40m"
bg_red="\e[41m"
bg_green="\e[42m"
bg_yellow="\e[43m"
bg_blue="\e[44m"
bg_magenta="\e[45m"
bg_cyan="\e[46m"
bg_light_gray="\e[47m"
bg_dark_gray="\e[100m"
bg_light_red="\e[101m"
bg_light_green="\e[102m"
bg_light_yellow="\e[103m"
bg_light_blue="\e[104m"
bg_light_magenta="\e[105m"
bg_light_cyan="\e[106m"
bg_white="\e[107m"

H1() {
  echo -e "\n${bold}${bg_blue}${yellow}$@${normal}\n"
  [[ -z $outfile ]] || echo -e "\n# $@\n" >> $outfile
}

H2() {
  echo -e "${bold}${ul}$@:u${normal}"
  [[ -z $outfile ]] || echo -e "\n## $@" >> $outfile
}

H3() {
  echo -e "${bold}▸ $@${normal}"
  [[ -z $outfile ]] || echo -e "### $@" >> $outfile
}

INFO() {
  echo -e "$@"
  [[ -z $outfile ]] || echo -e "INFO: $@" >> $outfile
}

ERROR() {
  echo -e "${red}Error: $@${normal}"
  [[ -z $outfile ]] || echo -e "ERROR: $@" >> $outfile
}

bumpPatchVersion() {
  version=$1
  major=`echo $version | cut -d. -f1`
  minor=`echo $version | cut -d. -f2`
  patch=`echo $version | cut -d. -f3`
  patch=`expr $patch + 1`

  echo "$major.$minor.$patch"
}

pascalCase() {
  echo "`camelCase $1`" | gsed 's/^[a-z]/\U&/' 
}

camelCase() {
  echo "$1" | gsed 's/_\([[:alnum:]]\)/\U\1/g'   
}

