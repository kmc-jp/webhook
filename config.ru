require 'logger'
require './applog'

logdir = File.dirname(__FILE__) + "/logs"
logger = ::Logger.new(logdir + '/app.log')

# CommonLoggerに渡すのに必要。
def logger.write(msg)
  self << msg
end

use AppLog, logger

# rackup(rack/server.rb)が設定するCommonLoggerは$stderrに、
# sinatra(sinatra/base.rb) が設定するCommonLoggerはenv['rack.errors'] に
# 出力しようとする。ファイルに書くため、独自に use する。
use Rack::CommonLogger, logger

require './app'
run Webhook
