desc "grab hubaccess .deb file"
task :default do
   `scp tim@Tims-MBP-2:Projects/hubaccess/packageup/hubaccess*.deb stage3/00-install-packages/files`
   files = `md5sum stage3/00-install-packages/files/*`
   puts files
end
