# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Node
    # Common Node.js/Express routes
    ROUTES = [
      '/api/users',
      '/api/users/:id',
      '/api/posts',
      '/api/posts/:id/comments',
      '/api/auth/login',
      '/api/auth/logout',
      '/api/auth/refresh',
      '/api/products',
      '/api/products/:id',
      '/api/orders',
      '/api/orders/:id/items',
      '/api/search',
      '/api/analytics/events',
      '/api/upload',
      '/api/notifications',
      '/health',
      '/metrics',
      '/',
      '/dashboard',
      '/profile/:username',
      '/settings',
      '/admin/users',
      '/admin/logs'
    ]

    HTTP_METHODS = %w[GET POST PUT PATCH DELETE OPTIONS]

    # Node.js specific log levels
    LOG_LEVELS = {
      error: { color: Colors::BRIGHT_RED, label: 'ERROR' },
      warn: { color: Colors::BRIGHT_YELLOW, label: 'WARN' },
      info: { color: Colors::BRIGHT_CYAN, label: 'INFO' },
      http: { color: Colors::GREEN, label: 'HTTP' },
      verbose: { color: Colors::BLUE, label: 'VERBOSE' },
      debug: { color: Colors::GRAY, label: 'DEBUG' },
      silly: { color: Colors::MAGENTA, label: 'SILLY' }
    }

    # Common Node.js error types
    ERROR_TYPES = [
      'TypeError',
      'ReferenceError',
      'SyntaxError',
      'RangeError',
      'ValidationError',
      'MongoError',
      'SequelizeError',
      'JsonWebTokenError',
      'MulterError',
      'AxiosError'
    ]

    ERROR_MESSAGES = [
      "Cannot read property 'id' of undefined",
      "Cannot set headers after they are sent to the client",
      "req.user is not defined",
      "Invalid token provided",
      "ECONNREFUSED 127.0.0.1:5432",
      "ENOENT: no such file or directory",
      "Unexpected token < in JSON at position 0",
      "Maximum call stack size exceeded",
      "connect ETIMEDOUT",
      "Request failed with status code 404",
      "Validation error: email must be unique",
      "JWT expired",
      "PayloadTooLargeError: request entity too large"
    ]

    # Database operations
    DB_OPERATIONS = [
      'Executing (default):',
      'mongodb',
      'Redis',
      'Elasticsearch'
    ]

    DB_QUERIES = [
      "SELECT * FROM users WHERE email = $1",
      "INSERT INTO posts (title, content, user_id) VALUES ($1, $2, $3) RETURNING *",
      "UPDATE users SET last_login = NOW() WHERE id = $1",
      "DELETE FROM sessions WHERE expires_at < NOW()",
      "users.find({ email: 'user@example.com' })",
      "posts.aggregate([{ $match: { status: 'published' } }, { $sort: { createdAt: -1 } }])",
      "HGET session:abc123 user_id",
      "SETEX cache:user:123 3600 '{\"id\":123,\"name\":\"John\"}'",
      "GET /api/products/_search"
    ]

    # Middleware names
    MIDDLEWARE = [
      'cors',
      'helmet',
      'morgan',
      'body-parser',
      'express-session',
      'passport',
      'multer',
      'express-rate-limit',
      'compression',
      'cookie-parser'
    ]

    # Common status codes with colors
    STATUS_CODE_COLORS = {
      200 => Colors::GREEN,
      201 => Colors::GREEN,
      204 => Colors::GREEN,
      301 => Colors::CYAN,
      302 => Colors::CYAN,
      304 => Colors::CYAN,
      400 => Colors::YELLOW,
      401 => Colors::YELLOW,
      403 => Colors::YELLOW,
      404 => Colors::YELLOW,
      422 => Colors::YELLOW,
      429 => Colors::BRIGHT_YELLOW,
      500 => Colors::RED,
      502 => Colors::RED,
      503 => Colors::RED
    }

    STATUS_MESSAGES = {
      200 => 'OK',
      201 => 'Created',
      204 => 'No Content',
      301 => 'Moved Permanently',
      302 => 'Found',
      304 => 'Not Modified',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      422 => 'Unprocessable Entity',
      429 => 'Too Many Requests',
      500 => 'Internal Server Error',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable'
    }

    # Process/cluster messages
    PROCESS_MESSAGES = [
      'Server running on port 3000',
      'Connected to MongoDB',
      'Redis client connected',
      'Database connection established',
      'Gracefully shutting down...',
      'Worker 2 started',
      'PM2: Starting execution sequence in -cluster mode- for app name:api id:0',
      'SIGTERM received, closing server...',
      'Unhandled rejection at:',
      'Memory usage:',
      'CPU usage:'
    ]

    class << self
      def route
        route = ROUTES.sample
        # Replace :id and :username with actual values
        route.gsub(':id', rand(1000).to_s).gsub(':username', "user#{rand(100)}")
      end

      def http_method
        HTTP_METHODS.sample
      end

      def status_code
        STATUS_CODE_COLORS.keys.sample
      end

      def status_message(code)
        STATUS_MESSAGES[code] || 'Unknown'
      end

      def response_time
        # More realistic response times for Node.js
        case rand(100)
        when 0..70 then rand(1..50)      # 70% fast responses
        when 71..90 then rand(51..200)   # 20% medium responses
        when 91..99 then rand(201..1000) # 9% slow responses
        else rand(1001..5000)            # 1% very slow responses
        end
      end

      def error_type
        ERROR_TYPES.sample
      end

      def error_message
        ERROR_MESSAGES.sample
      end

      def db_operation
        DB_OPERATIONS.sample
      end

      def db_query
        DB_QUERIES.sample
      end

      def middleware
        MIDDLEWARE.sample
      end

      def process_message
        PROCESS_MESSAGES.sample
      end

      def user_agent
        agents = [
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
          'PostmanRuntime/7.29.0',
          'axios/0.27.2',
          'node-fetch/1.0.0',
          'curl/7.79.1'
        ]
        agents.sample
      end

      def generate_log_entry
        case rand(100)
        when 0..60
          # HTTP request logs (60%)
          generate_http_logs
        when 61..75
          # Database logs (15%)
          [generate_database_log]
        when 76..85
          # Error logs (10%)
          generate_error_logs
        when 86..92
          # Process/system logs (7%)
          [generate_process_log]
        when 93..97
          # Debug logs (5%)
          [generate_debug_log]
        else
          # Warning logs (3%)
          [generate_warning_log]
        end
      end

      private

      def generate_http_logs
        method = http_method
        path = route
        status = status_code
        response_ms = response_time
        ip = LogUtils.ip_address
        
        logs = []
        
        # Morgan-style HTTP log
        logs << generate_morgan_log(method, path, status, response_ms, ip)
        
        # Sometimes add detailed logs
        if rand < 0.3
          logs << generate_detailed_request_log(method, path)
        end
        
        # Add response details for non-200 status
        if status >= 400
          logs << generate_error_response_log(status)
        end
        
        logs
      end

      def generate_morgan_log(method, path, status, response_ms, ip)
        status_color = STATUS_CODE_COLORS[status] || Colors::RED
        method_color = method == 'GET' ? Colors::GREEN : Colors::YELLOW
        
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')
        
        "#{Colors::GRAY}[#{timestamp}]#{Colors::RESET} " \
        "#{method_color}#{method}#{Colors::RESET} #{path} " \
        "#{status_color}#{status}#{Colors::RESET} " \
        "#{response_ms}ms - #{ip} " \
        "\"#{user_agent}\""
      end

      def generate_detailed_request_log(method, path)
        level = LOG_LEVELS[:debug]
        body = case method
               when 'POST', 'PUT', 'PATCH'
                 { 
                   email: "user#{rand(1000)}@example.com",
                   name: "Test User",
                   timestamp: Time.now.strftime('%Y-%m-%dT%H:%M:%S.%LZ')
                 }.to_s
               else
                 'undefined'
               end
        
        "#{level[:color]}[#{level[:label]}]#{Colors::RESET} " \
        "Request body: #{body}"
      end

      def generate_error_response_log(status)
        level = LOG_LEVELS[:error]
        message = case status
                  when 400 then "Invalid request body"
                  when 401 then "Authentication required"
                  when 403 then "Insufficient permissions"
                  when 404 then "Resource not found"
                  when 429 then "Rate limit exceeded"
                  when 500 then "Internal server error"
                  else "Request failed"
                  end
        
        "#{level[:color]}[#{level[:label]}]#{Colors::RESET} #{message}"
      end

      def generate_database_log
        operation = db_operation
        query = db_query
        duration = LogUtils.random_duration(0.5, 50.0)
        
        case operation
        when 'Executing (default):'
          # Sequelize style
          "#{Colors::BLUE}#{operation}#{Colors::RESET} #{query} #{Colors::GRAY}(#{duration}ms)#{Colors::RESET}"
        when 'mongodb'
          # MongoDB style
          "#{Colors::GREEN}[MongoDB]#{Colors::RESET} #{query} #{Colors::GRAY}+#{duration.to_i}ms#{Colors::RESET}"
        when 'Redis'
          # Redis style
          "#{Colors::YELLOW}[Redis]#{Colors::RESET} #{query} #{Colors::GRAY}(#{duration}ms)#{Colors::RESET}"
        else
          # Elasticsearch style
          "#{Colors::MAGENTA}[ES]#{Colors::RESET} #{query} #{Colors::GRAY}took:#{duration}ms#{Colors::RESET}"
        end
      end

      def generate_error_logs
        error_type = self.error_type
        error_msg = error_message
        
        logs = []
        
        # Main error
        level = LOG_LEVELS[:error]
        logs << "#{level[:color]}[#{level[:label]}]#{Colors::RESET} " \
                "#{Colors::RED}#{error_type}: #{error_msg}#{Colors::RESET}"
        
        # Stack trace
        3.times do |i|
          logs << "#{Colors::GRAY}    at #{generate_stack_frame(i)}#{Colors::RESET}"
        end
        
        logs
      end

      def generate_stack_frame(index)
        frames = [
          "Router.handle (/app/node_modules/express/lib/router/index.js:#{rand(100..500)}:#{rand(1..50)})",
          "processTicksAndRejections (internal/process/task_queues.js:#{rand(50..100)}:#{rand(1..20)})",
          "async middleware (/app/src/middleware/auth.js:#{rand(10..50)}:#{rand(1..30)})",
          "UserController.getProfile (/app/src/controllers/user.controller.js:#{rand(20..100)}:#{rand(1..40)})",
          "Array.map (<anonymous>)",
          "Promise.then (<anonymous>)"
        ]
        frames.sample
      end

      def generate_process_log
        level = LOG_LEVELS[:info]
        message = process_message
        
        # Add some dynamic data to certain messages
        message = case message
                  when /Memory usage:/
                    "#{message} RSS: #{rand(50..200)}MB, Heap: #{rand(30..150)}MB"
                  when /CPU usage:/
                    "#{message} #{rand(5..95)}%"
                  when /Worker \d+ started/
                    "Worker #{rand(1..8)} started with pid #{rand(1000..9999)}"
                  else
                    message
                  end
        
        "#{level[:color]}[#{level[:label]}]#{Colors::RESET} #{message}"
      end

      def generate_debug_log
        level = LOG_LEVELS[:debug]
        messages = [
          "Cache hit for key: user:#{rand(1000)}",
          "Middleware stack: #{middleware} -> #{middleware} -> router",
          "Query execution plan: SCAN -> FILTER -> SORT",
          "WebSocket connection established: client_#{SecureRandom.hex(4)}",
          "Session created: #{SecureRandom.hex(16)}",
          "File uploaded: avatar_#{rand(1000)}.jpg (#{rand(100..5000)}KB)"
        ]
        
        "#{level[:color]}[#{level[:label]}]#{Colors::RESET} #{messages.sample}"
      end

      def generate_warning_log
        level = LOG_LEVELS[:warn]
        warnings = [
          "Deprecation warning: bodyParser() is deprecated, use express.json()",
          "Memory usage high: 85% of heap used",
          "Slow query detected: #{rand(1000..5000)}ms",
          "Rate limit approaching for IP: #{LogUtils.ip_address}",
          "Failed to connect to Redis, using memory cache",
          "Large payload detected: #{rand(5..50)}MB"
        ]
        
        "#{level[:color]}[#{level[:label]}]#{Colors::RESET} #{warnings.sample}"
      end
    end
  end
end