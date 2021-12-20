#!/bin/sh

# this is expected to be bound to a keyboard shortcut
# and to work with another screenshot taking software that puts images in $screendir

#example directory
sceendir=$HOME/screenshots

# take last modified screenshot
last=$(ls -dt $sceendir/* | head -1)

# get name of highlighted screenshot
new=$(ruby main.rb $last)

# copy it into clipboard
# youd probably want to check if $new isnt empty
xclip -selection clipboard -t image/png -i $new