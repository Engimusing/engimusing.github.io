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
        replacements['DeviceCount'] = 0
        for child in root:
            if child.tag == 'Device':
                for devices in child:
                    if not devices.tag in replacements:
                        replacements[devices.tag] = []
                        
                    if child.text:
                        replacements[devices.tag].append(devices.text)
                        replacements[devices.tag + 'Set'] = set(replacements[devices.tag])
                    else:
                        replacements[devices.tag].append('')   
                    print devices.tag
                    print replacements[devices.tag]
                replacements['DeviceCount'] += 1
            else:
                if child.text:
                    replacements[child.tag] = child.text
                else:
                    replacements[child.tag] = ''
          
        if not 'FilePrefix' in replacements:
            replacements['FilePrefix'] = replacements['DeviceType']
        if 'DeviceTypeSet' in replacements:
            print replacements['DeviceTypeSet']
        
        for templateFile in os.listdir(templateDir):
            if(templateFile.endswith(".ino")):
                print templateFile
                template = env.get_template(templateFile)
                
                
                generatedFile = template.render( replacements = replacements, Year = datetime.now().year  ).strip()
                
                if(generatedFile != ''):
                    outDir = outputDir + replacements['FilePrefix'] + templateFile[0:-4] + '/'
                    outFile = outDir + replacements['FilePrefix'] + templateFile
                    print(outFile)
                    if not os.path.exists(outputDir):
                        os.mkdir(outputDir)
                    if not os.path.exists(outDir):
                        os.mkdir(outDir)
                    
                    with open(outFile, 'w') as f:
                            html = template.render( replacements = replacements, Year = datetime.now().year  ).strip()
                            f.write(html)
