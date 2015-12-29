require 'logger'
require 'docker'
require 'optparse'

args = { expire_sec: '7200',
         vimrc_path: nil,
         docker_host: 'localhost',
         docker_port: '4243' }

OptionParser.new do |opt|
  opt.on('-s=SEC', '--expire-sec', 'default: 7200') { |v| args[:expire_sec] = v }
  opt.on('-p=PATH', '--vimrc-path', 'もし指定しなければvimrcは消しません') { |v| args[:vimrc_path] = v }
  opt.on('-H=HOST', '--docker-host', 'default: localhost') { |v| args[:docker_host] = v }
  opt.on('-P=PORT', '--docker-port', 'default: 4243') { |v| args[:docker_port] = v }
  opt.parse!(ARGV)
end

logger = Logger.new(STDOUT)

logger.info('Start')
logger.info("Arguments: #{args}")

if args[:expire_sec].to_i.zero?
  logger.error('--expire-sec is not valid.')
  exit
end

Docker.url = "tcp://#{args[:docker_host]}:#{args[:docker_port]}"
containers_opt = { all: true }
containers = Docker::Container.all(containers_opt)

expire_datetime = (Time.now - args[:expire_sec].to_i).to_i

containers.each do |container|
  next if container.info['Created'] > expire_datetime

  container_id = container.info['id'][0, 12]
  del_container = Docker::Container.get(container_id)
  del_container.stop
  del_container.delete
  logger.info("Delete container(#{container_id})")

  next if args[:vimrc_path].nil?

  # 対象コンテナのvimrcファイルがあれば削除
  file = "#{args[:vimrc_path]}/#{container_id}/vimrc"
  if File.exist?(file)
    File.unlink(file)
    logger.info("Delete #{file}")
  end
end

logger.info('End')
