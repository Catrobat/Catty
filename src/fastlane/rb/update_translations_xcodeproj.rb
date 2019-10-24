require "xcodeproj"

project = Xcodeproj::Project.open("../Catty.xcodeproj")
saveProject = false

#
# Find Localizable
#
for proj_obj in project.objects do 
    if proj_obj.is_a? Xcodeproj::Project::Object::PBXGroup and
       proj_obj.hierarchy_path == "/Resources/Localization/Localizable.strings"
        localization_group = proj_obj
        puts "Successfully found Localizable: #{proj_obj.hierarchy_path}\n"
        break
    end
end

#
# Existing translations
#
existing_lang = Array[]
files = Dir.entries("../Catty/Resources/Localization/").sort
for file in files do
    if file.end_with? ".lproj"
        lang = file.chomp(".lproj")
        if lang != "sr-CS" # -> AppStore warning
            existing_lang.push(lang)
        end
    end
end

#
# Remove deprecated translations
#
files = localization_group.files
for file in files do
    if file.name != "en"
        if existing_lang.index(file.name) != nil
            existing_lang.delete(file.name)
            puts "Found Language: " + file.name + " -> not removing"
        else
            file.remove_from_project
            puts "Removed Language: " + file.path
            saveProject = true
        end
    end
end

#
# Add new languages
#
existing_lang.each { |lang| 
    if lang != "en"
        lang_file = project.new_file(lang+".lproj/Localizable.strings")
        lang_file.move(localization_group)
        lang_file.name = lang
        puts "Added Language: " + lang
        saveProject = true
    end
}

if saveProject
    project.save
end
