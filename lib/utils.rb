# frozen_string_literal: true

# ANSI color codes
module Colors
  RESET = "\e[0m"
  BOLD = "\e[1m"
  RED = "\e[31m"
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  BLUE = "\e[34m"
  MAGENTA = "\e[35m"
  CYAN = "\e[36m"
  GRAY = "\e[37m"
  BRIGHT_RED = "\e[91m"
  BRIGHT_GREEN = "\e[92m"
  BRIGHT_YELLOW = "\e[93m"
  BRIGHT_BLUE = "\e[94m"
  BRIGHT_MAGENTA = "\e[95m"
  BRIGHT_CYAN = "\e[96m"
  BRIGHT_WHITE = "\e[97m"
end

# Utility methods
module LogUtils
  def self.timestamp
    time = Time.now - rand(24 * 60 * 60) # Random time within the last day
    time.strftime('%Y-%m-%d %H:%M:%S.%L')
  end

  def self.ip_address
    "#{rand(256)}.#{rand(256)}.#{rand(256)}.#{rand(256)}"
  end

  def self.random_duration(min, max)
    (rand * (max - min) + min).round(1)
  end
end