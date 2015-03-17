import os
import sys
import subprocess

fi = "/home/gjanindu/datascience-bowl-r/data/train/"
fo = "/home/gjanindu/datascience-bowl-r/data_c/train/"

cmd = "-resize 60x60 -gravity center -background white -extent 60x60" 

classes = os.listdir(fi)

os.chdir(fo)
for cls in classes:
    print cls
    try:
        os.mkdir(cls)
    except:
        pass
    imgs = os.listdir(fi + cls + "/")
    #print imgs
    for img in imgs:
        md = "convert "
        md += fi + cls + "/" + img
        md += " " + cmd
        md += " " + fo + cls + "/" + img

        #print md
        os.system(md)
