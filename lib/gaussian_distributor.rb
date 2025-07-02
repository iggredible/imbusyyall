# Generates values following a Gaussian (bell curve) distribution pattern
# Used to create realistic variations in sleep times between log entries
class GaussianDistributor
  # Initialize with a base value and optional parameters
  # @param base_value [Float] The base sleep time to vary around
  # @param options [Hash] Configuration options:
  #   - total_iterations: Total number of values to generate (default: infinity)
  #   - min_factor: Minimum multiplier for base_value (default: 0.2)
  #   - max_factor: Maximum multiplier for base_value (default: 2.0)
  #   - period_length: Length of one bell curve cycle (default: 1000 for infinite, or total_iterations)
  #   - std_dev: Standard deviation for the curve (default: period_length/6)
  def initialize(base_value, options = {})
    @base_value = base_value
    @total_iterations = options[:total_iterations] || Float::INFINITY
    @min_factor = options[:min_factor] || 0.2
    @max_factor = options[:max_factor] || 2.0
    @period_length = @total_iterations.infinite? ? 1000 : @total_iterations

    # Center the bell curve at the midpoint of the period
    @mean = @period_length / 2.0
    @std_dev = options[:std_dev] || (@period_length / 6.0) # Default so ±3σ covers the whole range
  end

  # Calculate the sleep time for a given iteration
  # Returns values that follow a bell curve pattern:
  # - Higher values (slower) at the edges of the period
  # - Lower values (faster) at the center of the period
  # @param iteration [Integer] Current iteration number
  # @return [Float] Calculated sleep time
  def calculate(iteration)
    # For infinite loops, wrap around using modulo
    position = @total_iterations.infinite? ? (iteration % @period_length) : iteration

    # Calculate position on the bell curve
    z_score = (position - @mean) / @std_dev
    gaussian_value = Math.exp(-(z_score ** 2) / 2)

    # Map gaussian value (0-1) to factor range (min_factor-max_factor)
    factor = @min_factor + (@max_factor - @min_factor) * gaussian_value

    @base_value * factor
  end
end
