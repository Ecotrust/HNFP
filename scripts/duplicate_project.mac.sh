#!/bin/bash
echo
###ALL PATHS SHOULD BE RELATIVE TO marineplanner-core/scripts

SCRIPTS_DIR=`pwd`
CORE=${SCRIPTS_DIR%/scripts*}
core_array=(${CORE//\// })
PROJECT_NAME=${core_array[*]: -1}
VAGRANT_CORE=\\/usr\\/local\\/apps\\/$PROJECT_NAME

################################################################################
#      START PROJECT SPECIFIC CONFIGURATION
################################################################################

### APP_NAME is the name on the application you are developing.
# You can either change this line explicitly, or pass the name in as an argument
APP_NAME=hnfp

# "DEFAULT" installs the basic marineplanner modules. You can take more control below
MODULES="DEFAULT"

# If you know where you want your django app folder, uncomment and set the line below
#PROJ_FOLDER=Set_This_Yourself_To_Override

cd $CORE/apps
  ### Uncomment the modules you want included in this project, or leave modules as "DEFAULT":
  echo 'Cloning dependency repositories'
  if [ -n "$APP_NAME" ]; then
    if [ ! -d $APP_NAME ]; then git clone https://github.com/Ecotrust/$APP_NAME.git; fi
  else
    APP_NAME=mp_docs
    mkdir $CORE/apps/$APP_NAME
  fi
  if [ $MODULES == "DEFAULT" ]; then
    if [ ! -d madrona-features ]; then git clone https://github.com/Ecotrust/madrona-features.git; fi
    if [ ! -d madrona-manipulators ]; then git clone https://github.com/Ecotrust/madrona-manipulators.git; fi
    if [ ! -d mp-drawing ]; then git clone https://github.com/Ecotrust/mp-drawing.git; fi
    if [ ! -d mp-accounts ]; then git clone https://github.com/Ecotrust/mp-accounts.git; fi
    if [ ! -d mp-visualize ]; then git clone https://github.com/Ecotrust/mp-visualize.git; fi
    if [ ! -d mp-data-manager ]; then git clone https://github.com/Ecotrust/mp-data-manager.git; fi
    if [ ! -d p97-nursery ]; then git clone https://github.com/Ecotrust/p97-nursery.git; fi
  fi
  # if [ ! -d madrona-analysistools ]; then git clone https://github.com/Ecotrust/madrona-analysistools.git; fi
  # if [ ! -d madrona-features ]; then git clone https://github.com/Ecotrust/madrona-features.git; fi
  # if [ ! -d madrona-forms ]; then git clone https://github.com/Ecotrust/madrona-forms.git; fi
  # if [ ! -d madrona-scenarios ]; then git clone https://github.com/Ecotrust/madrona-scenarios.git; fi
  # if [ ! -d madrona-manipulators ]; then git clone https://github.com/Ecotrust/madrona-manipulators.git; fi
  # if [ ! -d mp-clipping ]; then git clone https://github.com/Ecotrust/mp-clipping.git; fi
  # if [ ! -d mp-drawing ]; then git clone https://github.com/Ecotrust/mp-drawing.git; fi
  # if [ ! -d mp-explore ]; then git clone https://github.com/Ecotrust/mp-explore.git; fi
  # if [ ! -d mp-accounts ]; then git clone https://github.com/Ecotrust/mp-accounts.git; fi
  # if [ ! -d mp-visualize ]; then git clone https://github.com/Ecotrust/mp-visualize.git; fi
  # if [ ! -d mp-data-manager ]; then git clone https://github.com/Ecotrust/mp-data-manager.git; fi
  # if [ ! -d mp-proxy ]; then git clone https://github.com/Ecotrust/mp-proxy.git; fi
  # if [ ! -d marco-map_groups ]; then git clone https://github.com/Ecotrust/marco-map_groups.git; fi
  # if [ ! -d p97-nursery ]; then git clone https://github.com/Ecotrust/p97-nursery.git; fi
  # if [ ! -d p97settings ]; then git clone https://github.com/Ecotrust/p97settings.git; fi
  # if [ ! -d django-recaptcha-develop ]; then git clone https://github.com/Ecotrust/django-recaptcha-develop.git; fi
  echo 'Done cloning repositories.'
  echo

################################################################################
#      END PROJECT SPECIFIC CONFIGURATION (you can ignore the rest!)
################################################################################

cd $CORE/scripts

#Identify best place for project settings file if not specified above
if [ ! -n "$PROJ_FOLDER" ]; then
  if [ -d $CORE/apps/$APP_NAME ]; then
    if [ -d $CORE/apps/$APP_NAME/$APP_NAME ]; then
      #local scope
      PROJ_FOLDER=$CORE/apps/$APP_NAME/$APP_NAME
      #vagrant vm scope
      VAGRANT_PROJ_FOLDER=$VAGRANT_CORE\\/apps\\/$APP_NAME\\/$APP_NAME
    else
      #local scope
      PROJ_FOLDER=$CORE/apps/$APP_NAME
      #vagrant vm scope
      VAGRANT_PROJ_FOLDER=$VAGRANT_CORE\\/apps\\/$APP_NAME
    fi
  fi
fi

### Copy and Link templates to full generated files
# Generate Vagrantfile
echo Replacing $PROJ_FOLDER/Vagrantfile
# cp $CORE/Vagrantfile.template $PROJ_FOLDER/Vagrantfile
# This allows us to maintain vagrant scope in the provision scripts, and
### local scope during setup.
sed -i '' 's/\#\#\#PROJ_DIR\#\#\#/'"$VAGRANT_PROJ_FOLDER"'/' $PROJ_FOLDER/Vagrantfile
if [ ! -e $CORE/Vagrantfile ]; then
  ln -s $PROJ_FOLDER/Vagrantfile $CORE/Vagrantfile
fi

#Generate basic provisoning script
echo Replacing $PROJ_FOLDER/vagrant_provision.sh
# cp vagrant_provision.sh.template $PROJ_FOLDER/vagrant_provision.sh
if [ ! -e $SCRIPTS_DIR/vagrant_provision.sh ]; then
  ln -s $PROJ_FOLDER/vagrant_provision.sh $SCRIPTS_DIR/vagrant_provision.sh
fi

#Generate project urls file
echo Replacing $PROJ_FOLDER/proj_urls.py
# cp $CORE/marineplanner/marineplanner/urls.py.template $PROJ_FOLDER/proj_urls.py

# $PROJ_SETTINGS=$PROJ_FOLDER/project_settings.py
#Copy project settings to the project folder to be preserved in its project repository
echo Replacing $PROJ_FOLDER/settings.py
# cp $CORE/marineplanner/marineplanner/settings.py.template $PROJ_FOLDER/project_settings.py

echo done.
