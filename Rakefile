require 'rake/testtask'
require_relative './lambda_function'
require 'dotenv/load'

Rake::TestTask.new do |task|
 task.pattern = 'test/**/*_test.rb'
end

desc 'Run lambda function locally'
task 'lambda' do 
  lambda_handler(event: nil, context: nil)
end