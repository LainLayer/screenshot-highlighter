# screenshot-highlighter

This is a tool i made to quickly highlight things in screenshots.
It uses OCR to find words in text and automatically draws red boxes around them on hover.

The code is pretty bad, I dont expect anyone to actually use this. But I do, so i wanna share it and keep it somewhere i can download.

# setup

requires ruby

```
gem install rtesseract
gem install gosu
<package manager> tesseract tesseract-data-eng
```

# usage

```
ruby main.rb test.png # => test_highlighted.png
```

The command will open a window with the image displayed on all of it.
After saving with `S`, it will save the file and print its new name.

See `example.sh` for a real usage example

# instructions

## select

`Right click`

Will create a green square. Clicking more words will expand the square to fit them

## make new selection

Press `enter`

The square will turn red. you can now start selecting a new area

## connect 2 selections

Press `C` when hovering on one of the red squares

The square will turn blue

Then press `C` on another red square

## delete selection

Hover on the red square and press `X`

## delete everything

Press `O`

## expand selection

Hover and press `+` or `-`

## save

Press `S`

## quit

Press `Q`

## free selection

To select a corner regardless of text press `R`

A green point will appear. Press `R` or click on anything to expand the selection.