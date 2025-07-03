# frozen_string_literal: true

require_relative '../lib/utils'

# Sample log entry
module DataSources
  module Sample
    class << self
      # A VERY SIMPLE one
      # def generate_log_entry
      #   ['foo', 'bar']
      # end

      # Randomized sample with colors
      def generate_log_entry
        case rand(100)
        when 0..68
          # 68% chance of foo (green)
          "#{Colors::GREEN}foo#{Colors::RESET}"
        when 69..95
          # 27% chance of bar (blue)
          "#{Colors::BLUE}bar#{Colors::RESET}"
        when 96..99
          # 3% chance of baz (yellow)
          "#{Colors::YELLOW}baz#{Colors::RESET}"
        else
          # 1% chance of qux (red)
          "#{Colors::RED}qux#{Colors::RESET}"
        end
      end
    end
  end
end
