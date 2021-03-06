#!/bin/bash

if [ ! -d  $SIMPATH/generators/pythia6 ];
then 
  cd $SIMPATH/generators
  if [ ! -e pythia6.tar.gz ];
  then
    echo "*** Downloading pythia6 sources ***"
    download_file https://root.cern.ch/download/pythia6.tar.gz
    echo "*** Downloading $PYTHIA6_LOCATION/$PYTHIA6VERSION.f.gz ***"
    download_file $PYTHIA6_LOCATION/$PYTHIA6VERSION.f.gz
  fi
  untar pythia6 pythia6.tar.gz
  gunzip $PYTHIA6VERSION.f.gz
  mysed "SUBROUTINE PDFSET" "SUBROUTINE PDFSETX" $PYTHIA6VERSION.f
  mysed "SUBROUTINE STRUCTM" "SUBROUTINE STRUCTMX" $PYTHIA6VERSION.f
  mysed "SUBROUTINE STRUCTP" "SUBROUTINE STRUCTPX" $PYTHIA6VERSION.f
  mypatch pythia6_infLoop.patch
  mv $PYTHIA6VERSION.f $SIMPATH/generators/pythia6
fi 

install_prefix=$SIMPATH_INSTALL

checkfile=$install_prefix/lib/libPythia6.so

if [ ! -d $install_prefix/lib ];
then
  mkdir -p $install_prefix/lib
fi

if (not_there Pythia6 $checkfile);
then

  cd $SIMPATH/generators/pythia6
  cp ../CMakeLists.txt_pythia6 CMakeLists.txt
  mkdir build
  cd build
  cmake .. -DCMAKE_INSTALL_PREFIX=$install_prefix 
  make install 

  if [ "$platform" = "macosx" ];
  then
      cp libPythia6.dylib $install_prefix/lib
      cd  $install_prefix/lib
      create_links dylib so
  fi

  check_all_libraries $install_prefix/lib

  check_success Pythia6 $checkfile
  check=$?
fi


if [ "$platform" = "macosx" ];
then
  export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:$install_prefix/lib
else
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$install_prefix/lib
fi

cd $SIMPATH

return 1
