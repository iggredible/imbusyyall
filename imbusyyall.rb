#!/usr/bin/env ruby
# frozen_string_literal: true

require 'securerandom'
require 'optparse'

# Script to generate fake Rails server logs with colorization
# Similar to what you'd see when running `rails server` in development mode

# Parse command line arguments
options = {
  lines: 1000,  # Default to 1000 lines
  sleep: 0.01   # Default sleep time (in seconds)
}

OptionParser.new do |opts|
  opts.banner = "Usage: fake_rails_logs.rb [options]"
  
  opts.on("-l", "--lines LINES", "Number of log lines to generate (use INFINITY for endless logs)") do |lines|
    if lines.upcase == "INFINITY"
      options[:lines] = Float::INFINITY
    else
      options[:lines] = lines.to_i
    end
  end
  
  opts.on("-s", "--sleep SECONDS", Float, "Sleep time between log entries (in seconds)") do |sleep_time|
    options[:sleep] = sleep_time.to_f
  end
end.parse!

# Support for legacy argument format (just a number as first argument)
if ARGV[0] && !options[:lines].is_a?(Float)
  if ARGV[0].upcase == "INFINITY"
    options[:lines] = Float::INFINITY
  else
    options[:lines] = ARGV[0].to_i if ARGV[0].to_i > 0
  end
end

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
    time.strftime("%Y-%m-%d %H:%M:%S.%L")
  end

  def self.ip_address
    "#{rand(256)}.#{rand(256)}.#{rand(256)}.#{rand(256)}"
  end
  
  def self.random_duration(min, max)
    (rand * (max - min) + min).round(1)
  end
end

# Fake data for log generation
class FakeData
  CONTROLLERS = %w[
    RecipesController IngredientsController MealsController RestaurantsController 
    ChefsController MenusController DishesController CategoriesController
    ReviewsController OrdersController ReservationsController
    InventoryController NutritionController
  ]
  
  ACTIONS = %w[
    index show create update destroy edit new search filter calculate_calories
    generate_menu process_order start_cooking monitor_temperature serve
    archive feature recommend validate bulk_update search_by_ingredient
  ]
  
  HTTP_METHODS = %w[GET POST PUT PATCH DELETE]
  
  FORMATS = %w[html json xml csv pdf]
  
  STATUS_CODES = [200, 201, 302, 304, 400, 401, 403, 404, 422, 500]
  
  STATUS_CODE_COLORS = {
    200 => Colors::GREEN,
    201 => Colors::GREEN, 
    302 => Colors::CYAN,
    304 => Colors::CYAN,
    400 => Colors::YELLOW,
    401 => Colors::YELLOW,
    403 => Colors::YELLOW,
    404 => Colors::YELLOW,
    422 => Colors::RED,
    500 => Colors::RED
  }
  
  TABLES = %w[
    users recipes ingredients meals restaurants chefs menus dishes
    categories reviews orders reservations inventory allergies
    cooking_methods cuisines nutrition_facts dietary_restrictions
  ]
  
  SQL_OPERATIONS = [
    "SELECT * FROM",
    "SELECT id, name, description FROM",
    "SELECT id, status, created_at FROM",
    "SELECT COUNT(*) FROM",
    "INSERT INTO",
    "UPDATE",
    "DELETE FROM"
  ]
  
  SQL_CONDITIONS = [
    "WHERE id = ?",
    "WHERE status = ?",
    "WHERE restaurant_id = ? AND created_at > ?",
    "WHERE created_at BETWEEN ? AND ?",
    "WHERE name LIKE ?",
    "WHERE name = ? OR category = ?",
    "WHERE deleted_at IS NULL",
    "ORDER BY created_at DESC LIMIT 10",
    "GROUP BY category_id",
    "LEFT JOIN ingredients ON ingredients.id = recipes.ingredient_id"
  ]
  
  STATES = %w[
    created prepared cooking ready served expired featured
    archived canceled rejected pending active inactive
  ]
  
  ROUTES = [
    "/recipes",
    "/ingredients",
    "/meals",
    "/restaurants",
    "/admin/recipes",
    "/admin/restaurants",
    "/admin/reports",
    "/admin/dashboard",
    "/api/v1/recipes",
    "/api/v1/ingredients",
    "/api/v1/users",
    "/api/v1/orders",
    "/recipes/123/ingredients",
    "/restaurants/456/menus",
    "/reports/monthly",
    "/reports/popular_dishes",
    "/settings",
    "/profile"
  ]
  
  PARAMETERS = [
    "{\"id\":#{rand(1000)}}",
    "{\"restaurant_id\":#{rand(1000)},\"page\":#{rand(10)}}",
    "{\"search\":\"pasta\"}",
    "{\"start_date\":\"2024-01-01\",\"end_date\":\"2024-06-30\"}",
    "{\"status\":\"active\"}",
    "{\"recipe\":{\"name\":\"Chocolate Cake\",\"chef_id\":#{rand(1000)}}}",
    "{\"dish\":{\"recipe_id\":#{rand(1000)},\"portions\":#{rand(10)}}}",
    "{\"format\":\"json\"}",
    "{\"sort_by\":\"rating\",\"direction\":\"desc\"}"
  ]

  class << self
    def controller
      CONTROLLERS.sample
    end
    
    def action
      ACTIONS.sample
    end
    
    def http_method
      HTTP_METHODS.sample
    end
    
    def format
      FORMATS.sample
    end
    
    def status_code
      STATUS_CODES.sample
    end
    
    def table
      TABLES.sample
    end
    
    def sql_operation
      SQL_OPERATIONS.sample
    end
    
    def sql_condition
      SQL_CONDITIONS.sample
    end
    
    def state
      STATES.sample
    end
    
    def route
      ROUTES.sample
    end
    
    def parameters
      PARAMETERS.sample
    end
  end
end

# Log entry generators
class LogGenerator
  def self.generate_request_line
    controller = FakeData.controller
    action = FakeData.action
    method = FakeData.http_method
    format = FakeData.format
    route = FakeData.route
    
    "Started #{Colors::GREEN}#{method}#{Colors::RESET} \"#{route}\" for #{LogUtils.ip_address} at #{LogUtils.timestamp}"
  end
  
  def self.generate_processing_line
    controller = FakeData.controller
    action = FakeData.action
    
    "Processing by #{Colors::YELLOW}#{controller}##{action}#{Colors::RESET} as #{FakeData.format.upcase}"
  end
  
  def self.generate_parameters_line
    "  Parameters: #{FakeData.parameters}"
  end
  
  def self.generate_sql_line
    operation = FakeData.sql_operation
    table = FakeData.table
    condition = FakeData.sql_condition
    duration = LogUtils.random_duration(0.5, 20.0)
    
    "  #{Colors::BLUE}#{operation} #{table} #{condition}#{Colors::RESET}  #{Colors::GRAY}[#{duration}ms]#{Colors::RESET}"
  end
  
  def self.generate_rendering_line
    view = "#{FakeData.controller.gsub('Controller', '').downcase}/#{FakeData.action}.html.slim"
    duration = LogUtils.random_duration(1.0, 100.0)
    
    "  #{Colors::MAGENTA}Rendered #{view} (Duration: #{duration}ms | Allocations: #{rand(1000..5000)})#{Colors::RESET}"
  end
  
  def self.generate_completed_line
    status = FakeData.status_code
    duration = LogUtils.random_duration(50.0, 500.0)
    
    status_color = FakeData::STATUS_CODE_COLORS[status] || Colors::RED
    "Completed #{status_color}#{status}#{Colors::RESET} #{status_message(status)} in #{duration}ms (Views: #{LogUtils.random_duration(10.0, 200.0)}ms | ActiveRecord: #{LogUtils.random_duration(5.0, 100.0)}ms | Allocations: #{rand(10000..50000)})"
  end
  
  def self.generate_worker_line
    worker_classes = ["RecipeNotificationWorker", "EmailDeliveryWorker", "MenuExportWorker", 
                      "InventoryReminderWorker", "OrderProcessingJob", "IngredientStockJob"]
    worker = worker_classes.sample
    duration = LogUtils.random_duration(10.0, 2000.0)
    jid = SecureRandom.hex(12)
    
    "#{Colors::CYAN}[ActiveJob]#{Colors::RESET} [#{jid}] Performed #{worker} in #{duration}ms"
  end

  def self.generate_sidekiq_line
    worker_classes = ["RecipeNotificationWorker", "EmailDeliveryWorker", "MenuExportWorker", 
                      "InventoryReminderWorker", "OrderProcessingJob", "IngredientStockJob"]
    worker = worker_classes.sample
    jid = SecureRandom.hex(12)
    
    "#{Colors::BRIGHT_BLUE}[Sidekiq]#{Colors::RESET} #{worker} JID-#{jid} INFO: start"
  end
  
  def self.generate_cache_line
    cache_key = [
      "views/recipes/123-20240615063022",
      "users/456-20240610124532",
      "menus/789/dishes-20240612081345",
      "restaurant_123/reports/monthly-20240601093012",
      "active_orders_count-20240614150023"
    ].sample
    
    hit_or_miss = ["hit", "miss"].sample
    duration = LogUtils.random_duration(0.1, 5.0)
    
    "  #{Colors::CYAN}Cache #{hit_or_miss} #{cache_key} (#{duration}ms)#{Colors::RESET}"
  end
  
  def self.generate_exception_line
    exceptions = [
      "ActiveRecord::RecordNotFound: Couldn't find Recipe with 'id'=12345",
      "ActiveRecord::RecordInvalid: Validation failed: Name can't be blank",
      "NoMethodError: undefined method `ingredients' for nil:NilClass",
      "ActionController::ParameterMissing: param is missing or the value is empty: recipe",
      "Pundit::NotAuthorizedError: not allowed to edit? this Recipe"
    ]
    
    "#{Colors::RED}#{exceptions.sample}#{Colors::RESET}"
  end
  
  def self.generate_backtrace_line
    backtrace_entries = [
      "app/controllers/recipes_controller.rb:45:in `show'",
      "app/models/recipe.rb:123:in `calculate_calories'",
      "app/services/meal_planner_service.rb:67:in `process_weekly_plan'",
      "lib/nutrition_calculator.rb:89:in `update_values'",
      "app/jobs/order_notification_job.rb:34:in `perform'"
    ]
    
    "#{Colors::GRAY}#{backtrace_entries.sample}#{Colors::RESET}"
  end
  
  def self.status_message(status)
    case status
    when 200 then "OK"
    when 201 then "Created"
    when 302 then "Found"
    when 304 then "Not Modified"
    when 400 then "Bad Request"
    when 401 then "Unauthorized"
    when 403 then "Forbidden"
    when 404 then "Not Found"
    when 422 then "Unprocessable Entity"
    when 500 then "Internal Server Error"
    else "Unknown Status"
    end
  end
  
  def self.generate_log_entry
    case rand(10)
    when 0..6
      # Regular request flow (70% probability)
      [
        generate_request_line,
        generate_processing_line,
        generate_parameters_line,
        generate_sql_line,
        generate_sql_line,
        rand < 0.3 ? generate_cache_line : generate_sql_line, # 30% chance of cache line
        generate_rendering_line,
        generate_completed_line
      ]
    when 7
      # Just a background worker (10% probability)
      [generate_worker_line]
    when 8
      # Just a Sidekiq job (10% probability)
      [generate_sidekiq_line]
    when 9
      # Error case (10% probability)
      [
        generate_request_line,
        generate_processing_line,
        generate_parameters_line,
        generate_sql_line,
        generate_exception_line,
        generate_backtrace_line,
        generate_backtrace_line,
        generate_backtrace_line
      ]
    end
  end
end

# Generate log entries based on the specified line count
count = 0
loop do
  log_entry = LogGenerator.generate_log_entry
  puts log_entry
  puts "" if rand < 0.5 # 50% chance of blank line between entries
  
  # Use the specified sleep time
  sleep options[:sleep]
  
  # Increment counter and break if we've reached the limit (infinite runs forever)
  count += 1
  break if !options[:lines].infinite? && count >= options[:lines]
end
