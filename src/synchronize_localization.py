import sys

f = open("Catty/Defines/LanguageTranslationDefines.h",'r')
filedata = f.read()
f.close()

newdata = filedata.replace("#define ","let ")
newdata = newdata.replace("NSLocalizedString(@", "= NSLocalizedString(")
newdata = newdata.replace("NSLocalizedString (@", "= NSLocalizedString(")
newdata = newdata.replace("@\"", "\"")
newdata = newdata.replace("\",\"", "\", \"")
newdata = newdata.replace("\",nil", "\", nil")
newdata = newdata.replace("\", ", "\", comment: ")
newdata = newdata.replace("nil", "\"\"")
newdata = newdata.replace("\%", "%")

f = open("Catty/Defines/LanguageTranslationDefinesSwift.swift",'w')
f.write(newdata)
f.close()

newdata = newdata.replace("\", comment: ", "\", bundle: Bundle(for: LanguageTranslation.self), comment: ")
newdata += "\nimport UIKit\n\nclass LanguageTranslation {}\n"
f = open("Catty UITests/Defines/LanguageTranslationDefinesUI.swift",'w')
f.write(newdata)
f.close()