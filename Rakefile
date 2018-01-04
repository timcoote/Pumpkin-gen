require 'rake/clean'

CLEAN.include( FileList[ 'stage3/00-install-packages/files/*.deb'])

desc "grab hubaccess .deb file"
task :default do
   Rake::Task["clean"].invoke
   `aws  s3 sync --exact-timestamps   --exclude "*" --include "*.deb" s3://pumpco/ stage3/00-install-packages/files/`
#   `scp tim@Tims-MBP-2:Projects/hubaccess/packageup/*.deb stage3/00-install-packages/files`
#   `scp tim@Tims-MBP-2:Projects/hub-connect/*.deb stage3/00-install-packages/files`
   files = `md5sum stage3/00-install-packages/files/*`
   puts files
end

# reminder on how to get the travis stuff for encrypting, for build automation
file "travis" do
    `gem install travis`
end

# build automation to insert creds into .travis.yml. Can use --add flag, but that mangles
# .travis.yml
task "encrypt_aws_creds" do
    akid = `travis encrypt AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id)" `
    ask  = `travis encrypt AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key)"`
    puts akid, ask
end

task "build_base_docker_image" do
    `docker build -t timcoote/iotaa-pi-gen -f Dockerfile .`
    `docker push timcoote/iotaa-pi-gen`
end

