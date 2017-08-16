require 'rake/clean'

CLEAN.include( FileList[ 'stage3/00-install-packages/files/*.deb'])

desc "grab hubaccess .deb file"
task :default do
   Rake::Task["clean"].invoke
   `scp tim@Tims-MBP-2:Projects/hubaccess/packageup/*.deb stage3/00-install-packages/files`
   `scp tim@Tims-MBP-2:Projects/hub-connect/*.deb stage3/00-install-packages/files`
   files = `md5sum stage3/00-install-packages/files/*`
   puts files
end
