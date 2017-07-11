on_chroot << EOF
cd pi-gen/smart-home
ansible-playbook -vvv -i 'localhost ansible_connection=local,' site.yml
EOF



