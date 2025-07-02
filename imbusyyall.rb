#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to generate fake logs with colorization for various data sources
require 'securerandom'
require 'optparse'
require_relative 'lib/gaussian_distributor'

# Parse command line arguments
# Use --min-factor=0.1 --max-factor=3.0 for more extreme variations (very fast to very slow)
# Use --min-factor=0.8 --max-factor=1.2 for more consistent timing
# Use --min-factor=0.5 --max-factor=1.0 for only faster variations from the base sleep time
options = {
  lines: 1000,         # Default to 1000 lines
  sleep: 0.1,          # Default sleep time (in seconds)
  data_source: :rails, # Default data source is Rails
  min_factor: 0.2,     # Default minimum sleep time factor
  max_factor: 2.0      # Default maximum sleep time factor
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

  opts.on('--min-factor FACTOR', Float, 'Minimum sleep time multiplier (default: 0.2)') do |factor|
    options[:min_factor] = factor.to_f
  end

  opts.on('--max-factor FACTOR', Float, 'Maximum sleep time multiplier (default: 2.0)') do |factor|
    options[:max_factor] = factor.to_f
  end
end.parse!

class LogGenerator
  class << self
    def load_data(source)
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
      when :rfc5424
        require_relative 'data/rfc5424'
        DataSources::Rfc5424
      when :spring
        require_relative 'data/spring'
        DataSources::Spring
      when :laravel
        require_relative 'data/laravel'
        DataSources::Laravel
      else
        puts "Unknown data source: #{source}. Using rails as default."
        require_relative 'data/rails'
        DataSources::Rails
      end
    end

    def generate_log_entry(source)
      load_data(source).generate_log_entry
    end
  end
end

count = 0
total_lines = options[:lines]
base_sleep = options[:sleep]

gaussian_distributor = GaussianDistributor.new(base_sleep, {
  total_iterations: total_lines,
  min_factor: options[:min_factor],
  max_factor: options[:max_factor],
  period_length: 1000  # Only used for infinite loops
})

loop do
  log_entry = LogGenerator.generate_log_entry(options[:data_source])
  puts log_entry
  puts '' if rand < 0.5 # 50% chance of blank line between entries

  # Use a normal distribution sleep time instead of a constant sleep time
  sleep gaussian_distributor.calculate(count)

  count += 1
  break if !total_lines.infinite? && count >= total_lines
end
