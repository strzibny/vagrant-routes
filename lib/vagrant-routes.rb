module VagrantPlugins
  module Routes
    # Update hosts file on the host with OpenShift routes hostnames
    class Plugin < Vagrant.plugin(2)
      name 'route'

      command('route', primary: false) do
        require_relative 'command'
        Command
      end
    end
  end
end
