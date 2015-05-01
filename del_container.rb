require 'logger'
require 'docker'
require 'optparse'

args = {:expire_sec => '7200',
        :vimrc_path => './', 
        :docker_host => 'localhost', 
        :docker_port => '4243',}

OptionParser.new do |opt|
  opt.on('-s=SEC', '--expire-sec', 'default: 7200') { |v| args[:expire_sec] = v }
  opt.on('-p=PATH', '--vimrc-path', 'default: current directory') { |v| args[:file_path] = v }
  opt.on('-H=HOST', '--docker-host', 'default: localhost') { |v| args[:docker_host] = v }
  opt.on('-P=PORT', '--docker-port', 'default: 4243') { |v| args[:docker_port] = v }
  opt.parse!(ARGV)
end

log_path = File.expand_path("../logs", __FILE__)
logger = Logger.new(STDOUT)

logger.info("Start")
logger.info("Arguments: #{args}")

if args[:expire_sec].to_i.zero?
  logger.error("--expire-sec is not valid.")
  exit
end


Docker.url = "tcp://#{args[:docker_host]}:#{args[:docker_port]}"
containers = Docker::Container.all(opts = {'all' => 1})

expire_datetime = (Time.now-args[:expire_sec].to_i).to_i

containers.each do |container|
  if( container.info['Created'] < expire_datetime )
    container_id = container.info['id'][0,12]
    del_container = Docker::Container.get(container_id)
    del_container.stop
    del_container.delete
    
    # 対象コンテナのvimrcファイルがあれば削除
    if File.exist?("#{args[:vimrc_path]}/vimrc_#{container_id}")
      File.unlink("#{args[:vimrc_path]}/vimrc_#{container_id}")
    end

    logger.info("Delete container(#{container_id}).")
  end
end

logger.info("End")
