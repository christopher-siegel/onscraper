#!/bin/bash

PS3='What do you want to do? '
options=("Scrape immediately" "Watch for Changes" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Scrape immediately")
      cd components/scraper
      coffee app.coffee 
      cd ../..
      ;;
    "Watch for Changes")
      cd components/watcher
      coffee app.coffee
      cd ../..
      ;;
    "Quit")
      break
      ;;
    *) echo invalid Option;;
  esac
done
    
