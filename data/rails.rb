# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Rails
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
      200 => "\e[32m", # GREEN
      201 => "\e[32m", # GREEN
      302 => "\e[36m", # CYAN
      304 => "\e[36m", # CYAN
      400 => "\e[33m", # YELLOW
      401 => "\e[33m", # YELLOW
      403 => "\e[33m", # YELLOW
      404 => "\e[33m", # YELLOW
      422 => "\e[31m", # RED
      500 => "\e[31m"  # RED
    }

    TABLES = %w[
      users recipes ingredients meals restaurants chefs menus dishes
      categories reviews orders reservations inventory allergies
      cooking_methods cuisines nutrition_facts dietary_restrictions
    ]

    SQL_OPERATIONS = [
      'SELECT * FROM',
      'SELECT id, name, description FROM',
      'SELECT id, status, created_at FROM',
      'SELECT COUNT(*) FROM',
      'INSERT INTO',
      'UPDATE',
      'DELETE FROM'
    ]

    SQL_CONDITIONS = [
      'WHERE id = ?',
      'WHERE status = ?',
      'WHERE restaurant_id = ? AND created_at > ?',
      'WHERE created_at BETWEEN ? AND ?',
      'WHERE name LIKE ?',
      'WHERE name = ? OR category = ?',
      'WHERE deleted_at IS NULL',
      'ORDER BY created_at DESC LIMIT 10',
      'GROUP BY category_id',
      'LEFT JOIN ingredients ON ingredients.id = recipes.ingredient_id'
    ]

    STATES = %w[
      created prepared cooking ready served expired featured
      archived canceled rejected pending active inactive
    ]

    ROUTES = [
      '/recipes',
      '/ingredients',
      '/meals',
      '/restaurants',
      '/admin/recipes',
      '/admin/restaurants',
      '/admin/reports',
      '/admin/dashboard',
      '/api/v1/recipes',
      '/api/v1/ingredients',
      '/api/v1/users',
      '/api/v1/orders',
      '/recipes/123/ingredients',
      '/restaurants/456/menus',
      '/reports/monthly',
      '/reports/popular_dishes',
      '/settings',
      '/profile'
    ]

    PARAMETERS = [
      "{\"id\":#{rand(1000)}}",
      "{\"restaurant_id\":#{rand(1000)},\"page\":#{rand(10)}}",
      '{"search":"pasta"}',
      '{"start_date":"2024-01-01","end_date":"2024-06-30"}',
      '{"status":"active"}',
      "{\"recipe\":{\"name\":\"Chocolate Cake\",\"chef_id\":#{rand(1000)}}}",
      "{\"dish\":{\"recipe_id\":#{rand(1000)},\"portions\":#{rand(10)}}}",
      '{"format":"json"}',
      '{"sort_by":"rating","direction":"desc"}'
    ]

    WORKER_CLASSES = %w[
      RecipeNotificationWorker EmailDeliveryWorker MenuExportWorker
      InventoryReminderWorker OrderProcessingJob IngredientStockJob
    ]

    CACHE_KEYS = [
      'views/recipes/123-20240615063022',
      'users/456-20240610124532',
      'menus/789/dishes-20240612081345',
      'restaurant_123/reports/monthly-20240601093012',
      'active_orders_count-20240614150023'
    ]

    EXCEPTIONS = [
      "ActiveRecord::RecordNotFound: Couldn't find Recipe with 'id'=12345",
      "ActiveRecord::RecordInvalid: Validation failed: Name can't be blank",
      "NoMethodError: undefined method `ingredients' for nil:NilClass",
      'ActionController::ParameterMissing: param is missing or the value is empty: recipe',
      'Pundit::NotAuthorizedError: not allowed to edit? this Recipe'
    ]

    BACKTRACE_ENTRIES = [
      "app/controllers/recipes_controller.rb:45:in `show'",
      "app/models/recipe.rb:123:in `calculate_calories'",
      "app/services/meal_planner_service.rb:67:in `process_weekly_plan'",
      "lib/nutrition_calculator.rb:89:in `update_values'",
      "app/jobs/order_notification_job.rb:34:in `perform'"
    ]

    STATUS_MESSAGES = {
      200 => 'OK',
      201 => 'Created',
      302 => 'Found',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      422 => 'Unprocessable Entity',
      500 => 'Internal Server Error'
    }

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

      def worker_class
        WORKER_CLASSES.sample
      end

      def cache_key
        CACHE_KEYS.sample
      end

      def exception
        EXCEPTIONS.sample
      end

      def backtrace_entry
        BACKTRACE_ENTRIES.sample
      end

      def status_message(status)
        STATUS_MESSAGES[status] || 'Unknown Status'
      end

      def generate_log_entry
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

      private

      def generate_request_line
        method = http_method
        route_path = route

        "Started #{Colors::GREEN}#{method}#{Colors::RESET} \"#{route_path}\" for #{LogUtils.ip_address} at #{LogUtils.timestamp}"
      end

      def generate_processing_line
        ctrl = controller
        act = action

        "Processing by #{Colors::YELLOW}#{ctrl}##{act}#{Colors::RESET} as #{format.upcase}"
      end

      def generate_parameters_line
        "  Parameters: #{parameters}"
      end

      def generate_sql_line
        operation = sql_operation
        tbl = table
        condition = sql_condition
        duration = LogUtils.random_duration(0.5, 20.0)

        "  #{Colors::BLUE}#{operation} #{tbl} #{condition}#{Colors::RESET}  #{Colors::GRAY}[#{duration}ms]#{Colors::RESET}"
      end

      def generate_rendering_line
        view = "#{controller.gsub('Controller', '').downcase}/#{action}.html.slim"
        duration = LogUtils.random_duration(1.0, 100.0)

        "  #{Colors::MAGENTA}Rendered #{view} (Duration: #{duration}ms | Allocations: #{rand(1000..5000)})#{Colors::RESET}"
      end

      def generate_completed_line
        status = status_code
        duration = LogUtils.random_duration(50.0, 500.0)

        status_color = STATUS_CODE_COLORS[status] || Colors::RED
        "Completed #{status_color}#{status}#{Colors::RESET} #{status_message(status)} in #{duration}ms (Views: #{LogUtils.random_duration(
          10.0, 200.0
        )}ms | ActiveRecord: #{LogUtils.random_duration(5.0, 100.0)}ms | Allocations: #{rand(10_000..50_000)})"
      end

      def generate_worker_line
        worker = worker_class
        duration = LogUtils.random_duration(10.0, 2000.0)
        jid = SecureRandom.hex(12)

        "#{Colors::CYAN}[ActiveJob]#{Colors::RESET} [#{jid}] Performed #{worker} in #{duration}ms"
      end

      def generate_sidekiq_line
        worker = worker_class
        jid = SecureRandom.hex(12)

        "#{Colors::BRIGHT_BLUE}[Sidekiq]#{Colors::RESET} #{worker} JID-#{jid} INFO: start"
      end

      def generate_cache_line
        key = cache_key
        hit_or_miss = %w[hit miss].sample
        duration = LogUtils.random_duration(0.1, 5.0)

        "  #{Colors::CYAN}Cache #{hit_or_miss} #{key} (#{duration}ms)#{Colors::RESET}"
      end

      def generate_exception_line
        "#{Colors::RED}#{exception}#{Colors::RESET}"
      end

      def generate_backtrace_line
        "#{Colors::GRAY}#{backtrace_entry}#{Colors::RESET}"
      end
    end
  end
end