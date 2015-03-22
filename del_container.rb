require 'logger'
require 'docker'
require 'optparse'

args = {:expire_sec => '7200',
        :docker_host => 'localhost', 
        :docker_port => '4243',}

OptionParser.new do |opt|
  opt.on('-s=SEC', '--expire-sec', 'default: 7200') { |v| args[:expire_sec] = v }
  opt.on('-H=HOST', '--docker-host', 'default: localhost') { |v| args[:docker_host] = v }
  opt.on('-P=PORT', '--docker-port', 'default: 4243') { |v| args[:docker_port] = v }
  opt.parse!(ARGV)
end

# logger setting
log_path = File.expand_path("../logs", __FILE__)
logger = Logger.new("#{log_path}/del_container.log")

logger.info("Start")
logger.info("Arguments: #{args}")

if args[:expire_sec].to_i.zero?
  logger.error("--expire-sec is not valid.")
  exit
end


begin
  Docker.url = "tcp://#{args[:docker_host]}:#{args[:docker_port]}"
  containers = Docker::Container.all(opts = {'all' => 1})
  
  expire_datetime = (Time.now-args[:expire_sec].to_i).to_i
  
  containers.each do |container|
    if( container.info['Created'] < expire_datetime )
      container_id = container.info['id'][0,12]
      del_container = Docker::Container.get(container_id)
      #del_container.stop
      #del_container.delete
  
      logger.info("Delete container(#{container_id}).")
    end
  end
rescue => e
  logger.error("[#{e.class}] #{e.message}")
end

logger.info("End")