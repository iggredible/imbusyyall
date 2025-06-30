#!/usr/bin/env ruby
# frozen_string_literal: true

require 'securerandom'
require 'optparse'
require_relative 'lib/utils'

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
  else
    puts "Unknown data source: #{source}. Using rails as default."
    require_relative 'data/rails'
    DataSources::Rails
  end
end

# Log entry generators
class LogGenerator
  def self.generate_log_entry(data_source)
    # Load the data source module
    data = load_data_source(data_source)
    
    # Delegate log generation to the data provider
    data.generate_log_entry
  end
end

# Generate log entries based on the specified line count
count = 0
loop do
  log_entry = LogGenerator.generate_log_entry(options[:data_source])
  puts log_entry
  puts '' if rand < 0.5 # 50% chance of blank line between entries

  # Use the specified sleep time
  sleep options[:sleep]

  # Increment counter and break if we've reached the limit (infinite runs forever)
  count += 1
  break if !options[:lines].infinite? && count >= options[:lines]
end
