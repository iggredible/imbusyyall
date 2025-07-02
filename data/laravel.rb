# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Laravel
    # Laravel log levels with colors (Monolog style)
    LOG_LEVELS = {
      'emergency' => { color: Colors::BRIGHT_RED, weight: 1 },
      'alert'     => { color: Colors::BRIGHT_RED, weight: 1 },
      'critical'  => { color: Colors::RED, weight: 2 },
      'error'     => { color: Colors::RED, weight: 5 },
      'warning'   => { color: Colors::YELLOW, weight: 10 },
      'notice'    => { color: Colors::CYAN, weight: 15 },
      'info'      => { color: Colors::GREEN, weight: 50 },
      'debug'     => { color: Colors::GRAY, weight: 16 }
    }

    # Laravel environment prefixes
    ENVIRONMENTS = %w[local production staging testing]

    # Common Laravel routes
    ROUTES = [
      { path: '/', methods: %w[GET] },
      { path: '/login', methods: %w[GET POST] },
      { path: '/logout', methods: %w[POST] },
      { path: '/register', methods: %w[GET POST] },
      { path: '/password/reset', methods: %w[GET POST] },
      { path: '/password/email', methods: %w[POST] },
      { path: '/dashboard', methods: %w[GET] },
      { path: '/profile', methods: %w[GET] },
      { path: '/profile/update', methods: %w[PUT PATCH] },
      { path: '/api/users', methods: %w[GET POST] },
      { path: '/api/users/{user}', methods: %w[GET PUT PATCH DELETE] },
      { path: '/api/posts', methods: %w[GET POST] },
      { path: '/api/posts/{post}', methods: %w[GET PUT DELETE] },
      { path: '/api/posts/{post}/comments', methods: %w[GET POST] },
      { path: '/api/categories', methods: %w[GET POST] },
      { path: '/api/products', methods: %w[GET POST] },
      { path: '/api/products/{product}', methods: %w[GET PUT DELETE] },
      { path: '/api/orders', methods: %w[GET POST] },
      { path: '/api/orders/{order}', methods: %w[GET PATCH] },
      { path: '/admin/users', methods: %w[GET] },
      { path: '/admin/settings', methods: %w[GET POST] },
      { path: '/storage/{path}', methods: %w[GET] },
      { path: '/broadcasting/auth', methods: %w[POST] }
    ]

    # HTTP status codes with weights
    STATUS_CODES = {
      200 => { weight: 45 },
      201 => { weight: 8 },
      204 => { weight: 3 },
      301 => { weight: 2 },
      302 => { weight: 10 },
      304 => { weight: 3 },
      400 => { weight: 5 },
      401 => { weight: 5 },
      403 => { weight: 3 },
      404 => { weight: 8 },
      419 => { weight: 3 },  # Laravel CSRF token mismatch
      422 => { weight: 3 },
      429 => { weight: 1 },
      500 => { weight: 3 },
      503 => { weight: 1 }
    }

    # Eloquent/Database queries
    QUERIES = [
      "select * from `users` where `email` = ? limit 1",
      "select * from `users` where `users`.`id` = ? limit 1",
      "select * from `posts` where `posts`.`user_id` = ? and `posts`.`user_id` is not null",
      "select `categories`.*, `category_product`.`product_id` as `pivot_product_id`, `category_product`.`category_id` as `pivot_category_id` from `categories` inner join `category_product` on `categories`.`id` = `category_product`.`category_id` where `category_product`.`product_id` = ?",
      "insert into `users` (`name`, `email`, `password`, `updated_at`, `created_at`) values (?, ?, ?, ?, ?)",
      "update `users` set `last_login_at` = ?, `users`.`updated_at` = ? where `id` = ?",
      "delete from `sessions` where `last_activity` <= ?",
      "select count(*) as aggregate from `orders` where `status` = ? and `created_at` >= ?",
      "select * from `products` where `stock` > ? order by `created_at` desc limit 10 offset 0",
      "update `products` set `stock` = `stock` - ?, `products`.`updated_at` = ? where `id` = ?"
    ]

    # Laravel exceptions
    EXCEPTIONS = [
      { 
        type: 'Illuminate\\Database\\Eloquent\\ModelNotFoundException',
        message: 'No query results for model [App\\Models\\User].',
        file: 'vendor/laravel/framework/src/Illuminate/Database/Eloquent/Builder.php',
        line: 553
      },
      { 
        type: 'Symfony\\Component\\HttpKernel\\Exception\\NotFoundHttpException',
        message: 'The route posts/999 could not be found.',
        file: 'vendor/laravel/framework/src/Illuminate/Routing/AbstractRouteCollection.php',
        line: 44
      },
      { 
        type: 'Illuminate\\Auth\\AuthenticationException',
        message: 'Unauthenticated.',
        file: 'vendor/laravel/framework/src/Illuminate/Auth/Middleware/Authenticate.php',
        line: 69
      },
      { 
        type: 'Illuminate\\Validation\\ValidationException',
        message: 'The given data was invalid.',
        file: 'app/Http/Controllers/UserController.php',
        line: 45
      },
      { 
        type: 'Illuminate\\Database\\QueryException',
        message: 'SQLSTATE[23000]: Integrity constraint violation: 1062 Duplicate entry \'admin@example.com\' for key \'users.users_email_unique\'',
        file: 'vendor/laravel/framework/src/Illuminate/Database/Connection.php',
        line: 760
      },
      { 
        type: 'TokenMismatchException',
        message: 'CSRF token mismatch.',
        file: 'vendor/laravel/framework/src/Illuminate/Foundation/Http/Middleware/VerifyCsrfToken.php',
        line: 80
      },
      { 
        type: 'Symfony\\Component\\HttpKernel\\Exception\\MethodNotAllowedHttpException',
        message: 'The GET method is not supported for this route. Supported methods: POST, PUT.',
        file: 'vendor/laravel/framework/src/Illuminate/Routing/AbstractRouteCollection.php',
        line: 118
      },
      { 
        type: 'ErrorException',
        message: 'Trying to access array offset on value of type null',
        file: 'app/Services/PaymentService.php',
        line: 127
      }
    ]

    # Queue/Job messages
    QUEUE_MESSAGES = [
      { job: 'App\\Jobs\\SendEmailJob', action: 'Processing', queue: 'default' },
      { job: 'App\\Jobs\\SendEmailJob', action: 'Processed', queue: 'default' },
      { job: 'App\\Jobs\\ProcessImageJob', action: 'Processing', queue: 'media' },
      { job: 'App\\Jobs\\ProcessImageJob', action: 'Failed', queue: 'media' },
      { job: 'App\\Jobs\\GenerateReportJob', action: 'Processing', queue: 'reports' },
      { job: 'App\\Jobs\\UpdateSearchIndexJob', action: 'Processed', queue: 'search' },
      { job: 'App\\Jobs\\CleanupOldFilesJob', action: 'Processing', queue: 'maintenance' },
      { job: 'App\\Jobs\\SendNotificationJob', action: 'Processed', queue: 'notifications' }
    ]

    # Cache operations
    CACHE_OPERATIONS = [
      { action: 'hit', key: 'user.1.profile' },
      { action: 'miss', key: 'products.featured' },
      { action: 'set', key: 'api.rate.limit.192.168.1.100' },
      { action: 'forget', key: 'posts.recent' },
      { action: 'flush', key: 'tag:products' },
      { action: 'forever', key: 'settings.app' }
    ]

    # Event messages
    EVENT_MESSAGES = [
      'User registered: user@example.com',
      'Login attempt failed for: admin@example.com',
      'Password reset requested for: user@example.com',
      'Order completed: #12345 - Total: $299.99',
      'Payment failed for order: #67890',
      'Product out of stock: SKU-123456',
      'Newsletter subscription: subscriber@example.com',
      'File uploaded: document.pdf (2.5MB)'
    ]

    # Common channels
    CHANNELS = %w[stack single daily slack syslog errorlog]

    class << self
      def generate_log_entry
        env = ENVIRONMENTS.sample
        
        case rand(100)
        when 0..40
          # HTTP request logs (40%)
          generate_http_request_log(env)
        when 41..55
          # Database query logs (15%)
          generate_database_log(env)
        when 56..65
          # Application logs (10%)
          generate_application_log(env)
        when 66..73
          # Exception logs (8%)
          generate_exception_log(env)
        when 74..80
          # Queue logs (7%)
          generate_queue_log(env)
        when 81..85
          # Cache logs (5%)
          generate_cache_log(env)
        when 86..90
          # Authentication logs (5%)
          generate_auth_log(env)
        when 91..95
          # Event logs (5%)
          generate_event_log(env)
        else
          # Debug/development logs (5%)
          generate_debug_log(env)
        end
      end

      private

      def weighted_log_level
        total_weight = LOG_LEVELS.values.sum { |v| v[:weight] }
        random = rand(total_weight)
        
        cumulative = 0
        LOG_LEVELS.each do |level, config|
          cumulative += config[:weight]
          return level if random < cumulative
        end
        
        'info' # fallback
      end

      def weighted_status_code
        total_weight = STATUS_CODES.values.sum { |v| v[:weight] }
        random = rand(total_weight)
        
        cumulative = 0
        STATUS_CODES.each do |code, config|
          cumulative += config[:weight]
          return code if random < cumulative
        end
        
        200 # fallback
      end

      def format_timestamp
        Time.now.strftime('[%Y-%m-%d %H:%M:%S]')
      end

      def generate_http_request_log(env)
        route = ROUTES.sample
        method = route[:methods].sample
        path = route[:path].gsub(/{[^}]+}/, rand(1..1000).to_s)
        status = weighted_status_code
        duration = rand(10..500)
        ip = LogUtils.ip_address
        
        # Laravel HTTP logs format
        level = status >= 500 ? 'error' : (status >= 400 ? 'warning' : 'info')
        level_color = LOG_LEVELS[level][:color]
        
        # Request ID for tracking
        request_id = SecureRandom.hex(8)
        
        logs = []
        
        # Main request log
        logs << "#{format_timestamp} #{env}.#{level}: " \
                "#{ip} - #{method} #{path} - " \
                "Status: #{status} - Duration: #{duration}ms - " \
                "Request ID: #{request_id}"
        
        # Add validation errors for 422
        if status == 422
          logs << "#{format_timestamp} #{env}.warning: " \
                  "Validation failed: {\"email\":[\"The email field is required.\"],\"password\":[\"The password must be at least 8 characters.\"]}"
        end
        
        # Add auth errors for 401
        if status == 401
          logs << "#{format_timestamp} #{env}.warning: " \
                  "Authentication failed: Invalid credentials provided"
        end
        
        logs.map { |log| colorize_log(log, level_color) }
      end

      def generate_database_log(env)
        query = QUERIES.sample
        duration = rand(0.5..50.0).round(2)
        connection = %w[mysql pgsql sqlite].sample
        
        # Add bindings
        bindings = query.scan(/\?/).count
        binding_values = bindings.times.map do
          case rand(4)
          when 0 then "'user#{rand(1000)}@example.com'"
          when 1 then rand(1..10000)
          when 2 then "'2024-01-15 10:30:00'"
          else "'active'"
          end
        end
        
        log = "#{format_timestamp} #{env}.debug: " \
              "Database query - Connection: #{connection} - " \
              "Duration: #{duration}ms - " \
              "Query: #{query}"
        
        log += " - Bindings: [#{binding_values.join(', ')}]" unless binding_values.empty?
        
        colorize_log(log, LOG_LEVELS['debug'][:color])
      end

      def generate_application_log(env)
        messages = [
          "Application is starting...",
          "Configuration cache cleared successfully",
          "Routes cache created successfully",
          "Compiled views cleared successfully",
          "Application is now in maintenance mode",
          "Application is now live",
          "Scheduled command finished successfully: inspire",
          "Broadcasting connection established",
          "Telescope enabled in local environment",
          "Debugbar enabled in local environment"
        ]
        
        level = 'info'
        log = "#{format_timestamp} #{env}.#{level}: #{messages.sample}"
        
        colorize_log(log, LOG_LEVELS[level][:color])
      end

      def generate_exception_log(env)
        exception = EXCEPTIONS.sample
        
        logs = []
        
        # Main exception message
        logs << "#{format_timestamp} #{env}.error: " \
                "#{exception[:type]}: #{exception[:message]}"
        
        # Stack trace header
        logs << ""
        logs << "Stack trace:"
        
        # Primary location
        logs << "#0 #{exception[:file]}:#{exception[:line]}"
        
        # Additional stack frames
        stack_frames = [
          "app/Http/Middleware/Authenticate.php:44",
          "vendor/laravel/framework/src/Illuminate/Pipeline/Pipeline.php:180",
          "vendor/laravel/framework/src/Illuminate/Routing/Middleware/SubstituteBindings.php:50",
          "vendor/laravel/framework/src/Illuminate/Foundation/Http/Kernel.php:142",
          "public/index.php:51"
        ]
        
        stack_frames.take(3 + rand(2)).each_with_index do |frame, i|
          logs << "##{i + 1} #{frame}"
        end
        
        logs << "{main}"
        logs << ""
        
        logs.map { |log| colorize_log(log, LOG_LEVELS['error'][:color]) }
      end

      def generate_queue_log(env)
        job_info = QUEUE_MESSAGES.sample
        job_id = SecureRandom.uuid
        
        level = job_info[:action] == 'Failed' ? 'error' : 'info'
        level_color = LOG_LEVELS[level][:color]
        
        logs = []
        
        # Main job log
        log = "#{format_timestamp} #{env}.#{level}: " \
              "Queue job #{job_info[:action].downcase} - " \
              "Job: #{job_info[:job]} - " \
              "Queue: #{job_info[:queue]} - " \
              "Job ID: #{job_id}"
        
        logs << log
        
        # Add failure details
        if job_info[:action] == 'Failed'
          logs << "#{format_timestamp} #{env}.error: " \
                  "Job failed after 3 attempts. Error: Timeout exceeded while processing image"
        end
        
        logs.map { |log| colorize_log(log, level_color) }
      end

      def generate_cache_log(env)
        operation = CACHE_OPERATIONS.sample
        duration = rand(0.1..5.0).round(2)
        
        level = 'debug'
        
        log = "#{format_timestamp} #{env}.#{level}: " \
              "Cache #{operation[:action]} - " \
              "Key: #{operation[:key]} - " \
              "Duration: #{duration}ms"
        
        # Add TTL for set operations
        if operation[:action] == 'set'
          ttl = [60, 300, 600, 3600].sample
          log += " - TTL: #{ttl}s"
        end
        
        colorize_log(log, LOG_LEVELS[level][:color])
      end

      def generate_auth_log(env)
        events = [
          { action: 'Login successful', user: "user#{rand(1000)}@example.com", ip: LogUtils.ip_address },
          { action: 'Login failed', user: "admin@example.com", ip: LogUtils.ip_address, reason: 'Invalid password' },
          { action: 'Logout', user: "user#{rand(1000)}@example.com", ip: LogUtils.ip_address },
          { action: 'Password reset requested', user: "forgot#{rand(100)}@example.com", ip: LogUtils.ip_address },
          { action: 'Account locked', user: "suspicious#{rand(100)}@example.com", reason: 'Too many failed attempts' },
          { action: 'Two-factor authentication enabled', user: "secure#{rand(100)}@example.com" },
          { action: 'API token created', user: "developer#{rand(100)}@example.com", token: 'tok_' + SecureRandom.hex(8) }
        ]
        
        event = events.sample
        level = event[:action].include?('failed') || event[:action].include?('locked') ? 'warning' : 'info'
        
        log = "#{format_timestamp} #{env}.#{level}: " \
              "Auth: #{event[:action]} - User: #{event[:user]}"
        
        log += " - IP: #{event[:ip]}" if event[:ip]
        log += " - Reason: #{event[:reason]}" if event[:reason]
        log += " - Token: #{event[:token][0..11]}..." if event[:token]
        
        colorize_log(log, LOG_LEVELS[level][:color])
      end

      def generate_event_log(env)
        event = EVENT_MESSAGES.sample
        level = 'info'
        
        log = "#{format_timestamp} #{env}.#{level}: Event: #{event}"
        
        colorize_log(log, LOG_LEVELS[level][:color])
      end

      def generate_debug_log(env)
        messages = [
          "Route matched: {route: api.users.show, parameters: {user: 123}}",
          "Model event: eloquent.created: App\\Models\\Post",
          "View rendered: resources/views/dashboard/index.blade.php",
          "Session started for user: #{rand(1000)}",
          "Middleware: Authenticate -> Authorize -> Throttle:api",
          "Config loaded from cache",
          "Service provider registered: App\\Providers\\EventServiceProvider",
          "Blade component rendered: x-alert",
          "Database transaction started",
          "Database transaction committed",
          "Request cycle: 125.43ms | Memory: 12.5MB"
        ]
        
        log = "#{format_timestamp} #{env}.debug: #{messages.sample}"
        
        colorize_log(log, LOG_LEVELS['debug'][:color])
      end

      def colorize_log(log, color)
        # Colorize the log level part
        if log =~ /(\[[\d\-\s:]+\]\s+\w+\.)(\w+)(:.*)/
          timestamp_and_env = $1
          level = $2
          rest = $3
          "#{timestamp_and_env}#{color}#{level}#{Colors::RESET}#{rest}"
        else
          log
        end
      end
    end
  end
end