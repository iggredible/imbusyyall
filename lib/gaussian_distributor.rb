# A generic class to generate values following a Gaussian (bell curve) distribution
class GaussianDistributor
  # Initialize the Gaussian distributor with configuration parameters
  # @param base_value [Numeric] The reference value to scale
  # @param options [Hash] Configuration options
  def initialize(base_value, options = {})
    @base_value = base_value
    @total_iterations = options[:total_iterations] || Float::INFINITY
    @min_factor = options[:min_factor] || 0.2
    @max_factor = options[:max_factor] || 2.0
    @period_length = @total_iterations.infinite? ? (options[:period_length] || 1000) : @total_iterations
    
    # Calculate parameters for Gaussian distribution
    @mean = @period_length / 2.0
    @std_dev = options[:std_dev] || (@period_length / 6.0)  # Default so ±3σ covers the whole range
  end
  
  # Calculate a value following the Gaussian distribution
  # @param iteration [Integer] Current iteration in the sequence
  # @return [Numeric] The calculated value for this iteration
  def calculate_value(iteration)
    # Calculate the position in the bell curve
    # For infinite sequences, use modulo to create a repeating pattern
    position = @total_iterations.infinite? ? (iteration % @period_length) : iteration
    
    # Calculate Gaussian value (peaks at 1.0 in the middle)
    z_score = (position - @mean) / @std_dev
    gaussian_value = Math.exp(-(z_score ** 2) / 2)
    
    # Scale the factor between min and max
    factor = @min_factor + (@max_factor - @min_factor) * gaussian_value
    
    # Apply the factor to the base value
    @base_value * factor
  end
  
  # Get the raw Gaussian factor (0.0 to 1.0) without applying to base value
  # @param iteration [Integer] Current iteration in the sequence
  # @return [Float] The raw Gaussian factor (0.0 to 1.0)
  def raw_factor(iteration)
    position = @total_iterations.infinite? ? (iteration % @period_length) : iteration
    z_score = (position - @mean) / @std_dev
    Math.exp(-(z_score ** 2) / 2)
  end
end
