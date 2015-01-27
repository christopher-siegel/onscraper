#!/bin/bash

PS3='What do you want to do? '
options=("Scrape immediately" "Watch for Changes" "Quit")
select opt in "${options[@]}"
do
  case $opt in
    "Scrape immediately")
      coffee ./components/scraper/app.coffee 
      ;;
    "Watch for Changes")
      coffee ./components/watcher/app.coffee
      ;;
    "Quit")
      break
      ;;
    *) echo invalid Option;;
  esac
done
    
