package :deploy_user do
  description 'Create deploy user'

  requires :create_deploy_user, :add_deploy_ssh_keys, :set_permissions
end

package :create_deploy_user do
  description "Create the deploy user"

  runner "useradd --create-home --shell /bin/bash --user-group --groups users,sudo deploy"

  verify do
    has_directory "/home/deploy"
  end
end

package :add_deploy_ssh_keys do
  description "Add deployer public key to authorized ones"
  requires :create_deploy_user

  local_keys_file = "#{ENV['APP_ROOT']}/config/authorized_keys"
  keys = File.read(local_keys_file)
  authorized_keys_file = "/home/deploy/.ssh/authorized_keys"

  push_text keys, authorized_keys_file, :sudo => true do
    pre :install, "mkdir -p /home/deploy/.ssh"
    # make it idempotent
    pre :install, "rm /home/deploy/.ssh/authorized_keys"
  end
end

package :set_permissions do
  description "Set correct permissons and ownership"
  requires :add_deploy_ssh_keys

  runner "chmod 0700 /home/deploy/.ssh"
  runner "chown -R deploy:deploy /home/deploy/.ssh"
  runner "chmod 0700 /home/deploy/.ssh/authorized_keys"
end
