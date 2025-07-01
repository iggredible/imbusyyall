#!/usr/bin/env ruby
# frozen_string_literal: true

require 'securerandom'
require 'optparse'
require_relative 'lib/gaussian_distributor'

# Script to generate fake logs with colorization for various data sources
# Currently supports Rails logs, with more data sources coming soon

# Parse command line arguments
options = {
  lines: 1000,      # Default to 1000 lines
  sleep: 0.05,      # Default sleep time (in seconds)
  data_source: :rails  # Default data source
}

OptionParser.new do |opts|
  opts.banner = 'Usage: imbusyyall.rb [options]'

  opts.on('-l', '--lines LINES', 'Number of log lines to generate (use INFINITY for endless logs)') do |lines|
    options[:lines] = if lines.upcase == 'INFINITY'
                        Float::INFINITY
                      else
                        lines.to_i
                      end
  end

  opts.on('-s', '--sleep SECONDS', Float, 'Sleep time between log entries (in seconds)') do |sleep_time|
    options[:sleep] = sleep_time.to_f
  end

  opts.on('-d', '--data-source SOURCE', 'Data source to use (default: rails)') do |source|
    options[:data_source] = source.to_sym
  end
end.parse!

# Support for legacy argument format (just a number as first argument)
if ARGV[0] && !options[:lines].is_a?(Float)
  if ARGV[0].upcase == 'INFINITY'
    options[:lines] = Float::INFINITY
  elsif ARGV[0].to_i > 0
    options[:lines] = ARGV[0].to_i
  end
end

# Load data source
def load_data_source(source)
  case source
  when :rails
    require_relative 'data/rails'
    DataSources::Rails
  when :node
    require_relative 'data/node'
    DataSources::Node
  when :django
    require_relative 'data/django'
    DataSources::Django
  when :apache
    require_relative 'data/apache'
    DataSources::Apache
  when :rfc3164
    require_relative 'data/rfc3164'
    DataSources::Rfc3164
  when :nginx
    require_relative 'data/nginx'
    DataSources::Nginx
  when :aspnet
    require_relative 'data/aspnet'
    DataSources::Aspnet
  else
    puts "Unknown data source: #{source}. Using rails as default."
    require_relative 'data/rails'
    DataSources::Rails
  end
end

class LogGenerator
  def self.generate_log_entry(data_source)
    load_data_source(data_source).generate_log_entry
  end
end

# Generate log entries based on the count
# Generate log entries based on the count
count = 0
total_lines = options[:lines]
base_sleep = options[:sleep]

# Initialize the Gaussian distributor for sleep times
gaussian_distributor = GaussianDistributor.new(base_sleep, {
  total_iterations: total_lines,
  min_factor: 0.2,
  max_factor: 2.0,
  period_length: 1000  # Only used for infinite loops
})

loop do
  log_entry = LogGenerator.generate_log_entry(options[:data_source])
  puts log_entry
  puts '' if rand < 0.5 # 50% chance of blank line between entries

  # Get value based on current iteration and use it as sleep time
  sleep gaussian_distributor.calculate_value(count)
  # sleep base_sleep

  # Increment counter and break if we've reached the limit
  count += 1
  break if !total_lines.infinite? && count >= total_lines
end
