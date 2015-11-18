module VagrantPlugins
  module Routes
    # Issue when `oc get routes` returns empty responce
    class NoRoutesError < StandardError; end

    class Command < Vagrant.plugin(2, :command)
      def self.synopsis
        'Access OpenShift routes from the host'
      end

      def execute
        with_target_vms(nil, single_target: true) do |machine|
          machine.communicate.execute('oc get routes', sudo: false) do |type, data|
            @result = data
          end
          @env.ui.info("Updating hosts file with new hostnames:\n#{routes_hostnames(@result).join(', ')}")
          ip = machine.ssh_info[:host]
          update_hosts(routes_hostnames(@result), ip)
        end
      rescue NoRoutesError
        @env.ui.error('No routes are defined.')
      rescue => e
        case @result
        # We are not signed-in
        when /.*the server has asked for the client to provide credentials.*/
          @env.ui.error('You need to sign in and select a project in OpenShift first.')
        # OpenShift is not installed on the guest
        when /.*oc: command not found.*/
          @env.ui.error('oc command was not found on guest. Is OpenShift installed?')
        else
          @env.ui.error("Unexpected error occured:\n#{e.message}")
        end
      end

      private

      # Add +hostnames+ entries associated with the +ip+ address
      # to the given +file+
      def update_hosts_file(file, hostnames, ip)
        header = "## vagrant-routes-start\n"
        footer = "## vagrant-routes-end\n"
        body = String.new
        hostnames.each { |h| body << "#{ip}\t#{h}\n" }
        block = "\n\n" + header + body + footer + "\n"
        content = file.read
        header_pattern = Regexp.quote(header)
        footer_pattern = Regexp.quote(footer)
        pattern = Regexp.new("\n*#{header_pattern}.*?#{footer_pattern}\n*", Regexp::MULTILINE)
        content = content.match(pattern) ? content.sub(pattern, block) : content.rstrip + blockt
        file.open('wb') { |io| io.write(content) }
      end

      def update_hosts(hostnames, ip)
        # Copy and modify hosts file on host with Vagrant-managed entries
        file = @env.tmp_path.join('hosts.local')
        if WindowsSupport.windows?
          # Lazily include windows Module
          class << self
            include WindowsSupport unless include? WindowsSupport
          end
          copy_proc = Proc.new { windows_copy_file(file, hosts_file_location) }
        else
          copy_proc = Proc.new { `sudo cp #{file} #{hosts_file_location}` }
        end
        FileUtils.cp(hosts_file_location, file)
        copy_proc.call if update_hosts_file(file, hostnames, ip)
      end

      # Example output of `oc get routes` is as follows:
      #
      #   $ oc get routes
      #   NAME      HOST/PORT                                       PATH      SERVICE   LABELS      INSECURE POLICY   TLS TERMINATION
      #   ruby20    ruby20-ruby-app.router.default.svc.cluster.local          ruby20    app=ruby20
      #   pyapp     pyapp-python.router.default.svc.cluster.local             pyapp     app=pyapp
      def routes_hostnames(output)
        fail NoRoutesError unless output
        lines = output.split("\n")[1..-1]
        hostnames = []
        lines.each do |line|
          hostnames << line.split[1]
        end
        fail NoRoutesError if hostnames.empty?
        hostnames
      end

      # Return appropriate location of +hosts+ file
      def hosts_file_location
        if WindowsSupport.windows?
          "#{ENV['WINDIR']}\\System32\\drivers\\etc\\hosts"
        else
          '/etc/hosts'
        end
      end

      # Windows support is taken from vagrant-hostmanager
      module WindowsSupport
        require 'rbconfig'

        def self.windows?
          RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
        end

        require 'win32ole' if windows?

        def windows_copy_file(source, dest)
          FileUtils.cp(source, dest)
        # Access denied, try with elevated privileges
        rescue Errno::EACCES
          windows_copy_file_elevated(source, dest)
        end

        private

        def windows_copy_file_elevated(source, dest)
          # copy command only supports backslashes as separators
          source, dest = [source, dest].map { |s| s.to_s.gsub(/\//, '\\') }

          # run 'cmd /C copy ...' with elevated privilege, minimized
          copy_cmd = "copy \"#{source}\" \"#{dest}\""
          WIN32OLE.new('Shell.Application').ShellExecute('cmd', "/C #{copy_cmd}", nil, 'runas', 7)

          # Unfortunately, ShellExecute does not give us a status code and it
          # is non-blocking so we can't reliably compare the file contents
          # to see if they were copied.
          #
          # If the user rejects the UAC prompt, vagrant will silently continue
          # without updating the hostsfile.
        end
      end
    end
  end
end
