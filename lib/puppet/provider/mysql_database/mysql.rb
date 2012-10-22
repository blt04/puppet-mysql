require 'puppet/provider/package'

Puppet::Type.type(:mysql_database).provide(:mysql,
		:parent => Puppet::Provider::Package) do

	desc "Use mysql as database."
	commands :mysql => '/usr/bin/mysql'
	commands :mysqladmin => '/usr/bin/mysqladmin'

	def self.mysql_opts
		'--defaults-extra-file=/root/.my.cnf'
	end
	def mysql_opts
		self.class.mysql_opts
	end

	# retrieve the current set of mysql users
	def self.instances
		dbs = []

		cmd = "#{command(:mysql)} #{mysql_opts} mysql -NBe 'show databases'"
		execpipe(cmd) do |process|
			process.each do |line|
				dbs << new( { :ensure => :present, :name => line.chomp } )
			end
		end
		return dbs
	end

	def query
		result = {
			:name => @resource[:name],
			:ensure => :absent
		}

		cmd = "#{command(:mysql)} #{mysql_opts} mysql -NBe 'show databases'"
		execpipe(cmd) do |process|
			process.each do |line|
				if line.chomp.eql?(@resource[:name])
					result[:ensure] = :present
				end
			end
		end
		result
	end

	def create
		mysqladmin mysql_opts, "create", @resource[:name]
	end
	def destroy
		mysqladmin mysql_opts, "-f", "drop", @resource[:name]
	end

	def exists?
		if mysql(mysql_opts, "mysql", "-NBe", "show databases").match(/^#{@resource[:name]}$/)
			true
		else
			false
		end
	end
end

