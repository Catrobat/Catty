require "xcodeproj"

project = Xcodeproj::Project.open("../Catty.xcodeproj")

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
# Remove all current translations
#
files = localization_group.files
for file in files do
    if file != "en"
        file.remove_from_project
        puts "Removed Language: " + file.path
    end
end

#
# Add all existing translations
#
files = Dir.entries("../Catty/Resources/Localization/").sort
for file in files do
    if file.end_with? ".lproj"
        lang = file.chomp(".lproj")
        lang_file = project.new_file(lang+".lproj/Localizable.strings")
        lang_file.move(localization_group)
        lang_file.name = lang
        puts "Added Language: " + lang
    end
end

project.save
