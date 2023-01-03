import os

RELEVANTTAGS = ["<key>", "<string>", "</key>", "</string>"]
SCRIPTPATH =  os.path.dirname(os.path.realpath(__file__))

stringFile = []
stringHmap = dict()

def createLineForStringFile(s):
    if ("$" in s or "https://" in s):
        return
    tmp = s.replace(RELEVANTTAGS[0], '').replace(RELEVANTTAGS[1], ' = "').replace(RELEVANTTAGS[2], '').replace(RELEVANTTAGS[3], '";')
    stringFile.append(tmp + '\n')
    split = tmp.split()
    if(len(split) > 2):
        stringHmap[split[0]] = ' '.join(split[1:]) + '\n'

def main():
    
    file = open(SCRIPTPATH + "/../Catty/Supporting Files/App-Info.plist", "r")
    lines = file.readlines()

    prev = ""
    for line in lines:
        if (RELEVANTTAGS[1] in line 
        and RELEVANTTAGS[0] in prev):
            createLineForStringFile(prev.strip() + line.strip())
        prev = line
    
    enBaseLocalisationPath = SCRIPTPATH + "/../Catty/Resources/Localization/en.lproj/InfoPlist.strings"
    baseFile = open(enBaseLocalisationPath, "w")
    baseFile.writelines(stringFile)

    subfolders = [ f.path for f in os.scandir(SCRIPTPATH + "/../Catty/Resources/Localization") if f.is_dir() ]
    for folder in subfolders:
        if(folder in enBaseLocalisationPath):
            continue
        
        subFile = open(folder + '/InfoPlist.strings', "r+")
        subLines = subFile.readlines()
        hmap = dict()

        for line in subLines:
            split = line.split()
            if(len(split) > 2):
                hmap[split[0]] = ' '.join(split[1:]) + '\n'

        for key in stringHmap:
            if(key not in hmap):
                subFile.writelines(key + ' ' + stringHmap[key])


if __name__ == "__main__":
    main()

