import os
from jinja2 import Environment, FileSystemLoader, select_autoescape
from datetime import datetime

import xml.etree.ElementTree as ET

templateDir = './templates/'
deviceConfig = './configuration/'
outputDir = './output/'

PATH = os.path.dirname(os.path.abspath(__file__))     
env = Environment(
    autoescape=False,
    loader=FileSystemLoader(os.path.join(PATH, templateDir)),
    trim_blocks=True,
    lstrip_blocks =True)

        


for filename in os.listdir(deviceConfig):
    if(filename.endswith(".xml")):
        print filename
        tree = ET.parse(deviceConfig + filename)
        root = tree.getroot()
        replacements = {}
        for child in root:
            if child.text:
                replacements[child.tag] = child.text
            else:
                replacements[child.tag] = ''
        for templateFile in os.listdir(templateDir):
            if(templateFile.endswith(".ino")):
                print templateFile
                template = env.get_template(templateFile)
                
                outDir = outputDir + replacements['DeviceType'] + templateFile[0:-4] + '/'
                outFile = outDir + replacements['DeviceType'] + templateFile
                print(outFile)
                if not os.path.exists(outputDir):
                    os.mkdir(outputDir)
                if not os.path.exists(outDir):
                    os.mkdir(outDir)
                with open(outFile, 'w') as f:
                        html = template.render( replacements = replacements, Year = datetime.now().year  ).strip()
                        f.write(html)
