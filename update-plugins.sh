#!/bin/bash

cd ~/.vim/bundle
ls | xargs -P10 -I{} git -C {} pull
