require 'rake/testtask'
require_relative './lambda_function'
require 'dotenv/load'

Rake::TestTask.new do |task|
 task.pattern = 'test/**/*_test.rb'
 task.warning = false
end

desc 'Run lambda function locally'
task 'lambda' do 
  lambda_handler(event: nil, context: nil)
end

require 'meteoalarm'

spec = Gem::Specification.find_by_name 'meteoalarm'
Dir.glob("#{spec.gem_dir}/lib/meteoalarm/tasks/*.rake").each { |f| import f }