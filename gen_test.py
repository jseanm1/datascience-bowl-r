import os
import sys
import subprocess

fi = "/home/gjanindu/datascience-bowl-r/data/test/"
fo = "/home/gjanindu/datascience-bowl-r/data_c/test/"

cmd = "-resize 60x60 -gravity center -background white -extent 60x60" 

imgs = os.listdir(fi)
#print imgs
for img in imgs:
    md = "convert "
    md += fi + img
    md += " " + cmd
    md += " " + fo + img

    print md
    os.system(md)
