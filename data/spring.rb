# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Spring
    # Spring Boot log levels with colors
    LOG_LEVELS = {
      'ERROR' => { color: Colors::BRIGHT_RED, weight: 5 },
      'WARN'  => { color: Colors::BRIGHT_YELLOW, weight: 10 },
      'INFO'  => { color: Colors::GREEN, weight: 70 },
      'DEBUG' => { color: Colors::CYAN, weight: 10 },
      'TRACE' => { color: Colors::GRAY, weight: 5 }
    }

    # Common Spring Boot logger names
    LOGGER_NAMES = [
      'com.example.api.controller.UserController',
      'com.example.api.controller.ProductController',
      'com.example.api.controller.OrderController',
      'com.example.api.controller.AuthController',
      'com.example.api.service.UserService',
      'com.example.api.service.ProductService',
      'com.example.api.service.OrderService',
      'com.example.api.service.EmailService',
      'com.example.api.repository.UserRepository',
      'com.example.api.repository.ProductRepository',
      'com.example.api.security.JwtTokenProvider',
      'com.example.api.security.SecurityConfig',
      'com.example.api.config.WebMvcConfig',
      'com.example.api.filter.RequestLoggingFilter',
      'com.example.api.exception.GlobalExceptionHandler',
      'org.springframework.boot.StartupInfoLogger',
      'org.springframework.boot.web.embedded.tomcat.TomcatWebServer',
      'org.springframework.boot.actuate.endpoint.web.EndpointLinksResolver',
      'org.springframework.web.servlet.DispatcherServlet',
      'org.springframework.data.repository.config.RepositoryConfigurationDelegate',
      'org.springframework.security.web.DefaultSecurityFilterChain',
      'org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration',
      'org.springframework.context.support.PostProcessorRegistrationDelegate',
      'org.hibernate.jpa.internal.util.LogHelper',
      'org.hibernate.Version',
      'org.hibernate.engine.transaction.jta.platform.internal.JtaPlatformInitiator',
      'org.hibernate.SQL',
      'org.hibernate.type.descriptor.sql.BasicBinder',
      'com.zaxxer.hikari.HikariDataSource',
      'com.zaxxer.hikari.pool.HikariPool',
      'org.apache.catalina.core.StandardService',
      'org.apache.coyote.http11.Http11NioProtocol',
      'org.springframework.kafka.listener.KafkaMessageListenerContainer',
      'org.springframework.amqp.rabbit.connection.CachingConnectionFactory',
      'org.springframework.data.redis.core.RedisTemplate',
      'org.springframework.cache.interceptor.CacheInterceptor',
      'org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor',
      'org.springframework.transaction.interceptor.TransactionInterceptor',
      'org.springframework.orm.jpa.JpaTransactionManager',
      'io.micrometer.core.instrument.binder.jvm.JvmGcMetrics',
      'springfox.documentation.spring.web.plugins.DocumentationPluginsBootstrapper'
    ]

    # REST endpoints
    ENDPOINTS = [
      { path: '/api/v1/users', methods: %w[GET POST] },
      { path: '/api/v1/users/{id}', methods: %w[GET PUT DELETE] },
      { path: '/api/v1/users/{id}/profile', methods: %w[GET PATCH] },
      { path: '/api/v1/products', methods: %w[GET POST] },
      { path: '/api/v1/products/{id}', methods: %w[GET PUT DELETE] },
      { path: '/api/v1/products/search', methods: %w[GET] },
      { path: '/api/v1/orders', methods: %w[GET POST] },
      { path: '/api/v1/orders/{id}', methods: %w[GET PATCH] },
      { path: '/api/v1/orders/{id}/items', methods: %w[GET POST] },
      { path: '/api/v1/auth/login', methods: %w[POST] },
      { path: '/api/v1/auth/logout', methods: %w[POST] },
      { path: '/api/v1/auth/refresh', methods: %w[POST] },
      { path: '/api/v1/auth/register', methods: %w[POST] },
      { path: '/actuator/health', methods: %w[GET] },
      { path: '/actuator/metrics', methods: %w[GET] },
      { path: '/actuator/info', methods: %w[GET] },
      { path: '/swagger-ui.html', methods: %w[GET] },
      { path: '/v3/api-docs', methods: %w[GET] }
    ]

    # HTTP status codes
    STATUS_CODES = {
      200 => { message: 'OK', weight: 50 },
      201 => { message: 'Created', weight: 10 },
      204 => { message: 'No Content', weight: 5 },
      400 => { message: 'Bad Request', weight: 10 },
      401 => { message: 'Unauthorized', weight: 5 },
      403 => { message: 'Forbidden', weight: 3 },
      404 => { message: 'Not Found', weight: 8 },
      409 => { message: 'Conflict', weight: 2 },
      422 => { message: 'Unprocessable Entity', weight: 3 },
      500 => { message: 'Internal Server Error', weight: 3 },
      503 => { message: 'Service Unavailable', weight: 1 }
    }

    # SQL queries
    SQL_QUERIES = [
      "select user0_.id as id1_0_, user0_.created_at as created_2_0_, user0_.email as email3_0_, user0_.enabled as enabled4_0_, user0_.first_name as first_na5_0_, user0_.last_name as last_nam6_0_, user0_.password as password7_0_, user0_.updated_at as updated_8_0_ from users user0_ where user0_.email=?",
      "select product0_.id as id1_1_, product0_.category as category2_1_, product0_.created_at as created_3_1_, product0_.description as descript4_1_, product0_.name as name5_1_, product0_.price as price6_1_, product0_.stock as stock7_1_ from products product0_ where product0_.category=? order by product0_.created_at desc limit ?",
      "insert into orders (created_at, customer_id, status, total_amount, updated_at) values (?, ?, ?, ?, ?)",
      "update users set last_login_at=?, updated_at=? where id=?",
      "delete from user_sessions where expires_at<?",
      "select count(*) from products where category=? and price between ? and ?",
      "select o.* from orders o inner join order_items oi on o.id = oi.order_id where o.customer_id=? and o.status=?",
      "update products set stock=stock-? where id=? and stock>=?"
    ]

    # Exception types
    EXCEPTIONS = [
      { type: 'java.lang.NullPointerException', message: 'Cannot invoke "com.example.api.entity.User.getId()" because "user" is null' },
      { type: 'org.springframework.security.access.AccessDeniedException', message: 'Access is denied' },
      { type: 'javax.validation.ConstraintViolationException', message: 'Validation failed for classes [com.example.api.dto.UserCreateDto] during persist time for groups [javax.validation.groups.Default, ]\nList of constraint violations:[\n\tConstraintViolationImpl{interpolatedMessage=\'must be a well-formed email address\', propertyPath=email, rootBeanClass=class com.example.api.dto.UserCreateDto, messageTemplate=\'{javax.validation.constraints.Email.message}\'}\n]' },
      { type: 'org.springframework.dao.DataIntegrityViolationException', message: 'could not execute statement; SQL [n/a]; constraint [uk_users_email]; nested exception is org.hibernate.exception.ConstraintViolationException' },
      { type: 'com.example.api.exception.ResourceNotFoundException', message: 'User not found with id: 12345' },
      { type: 'io.jsonwebtoken.ExpiredJwtException', message: 'JWT expired at 2024-01-15T10:30:00Z. Current time: 2024-01-15T11:00:00Z' },
      { type: 'org.springframework.web.client.HttpClientErrorException$NotFound', message: '404 Not Found: [{"error":"Resource not found"}]' },
      { type: 'java.net.ConnectException', message: 'Connection refused: connect' },
      { type: 'org.springframework.transaction.CannotCreateTransactionException', message: 'Could not open JPA EntityManager for transaction; nested exception is javax.persistence.PersistenceException' },
      { type: 'org.springframework.kafka.KafkaException', message: 'Failed to send message to topic user-events' }
    ]

    # Common hostnames
    HOSTNAMES = [
      'prod-api-01', 'prod-api-02', 'prod-api-03',
      'staging-api-01', 'dev-api-01',
      'localhost'
    ]

    # Application events
    APP_EVENTS = [
      "Starting Application using Java 17 with PID",
      "The following profiles are active: prod,swagger",
      "Started Application in 12.456 seconds (JVM running for 13.234)",
      "Tomcat started on port(s): 8080 (http) with context path ''",
      "Initializing ExecutorService 'applicationTaskExecutor'",
      "HikariPool-1 - Starting...",
      "HikariPool-1 - Start completed.",
      "Mapped \"{[/error]}\" onto public org.springframework.http.ResponseEntity<java.util.Map<java.lang.String, java.lang.Object>> org.springframework.boot.autoconfigure.web.servlet.error.BasicErrorController.error(javax.servlet.http.HttpServletRequest)",
      "Registered JWT token filter",
      "Creating filter chain: any request",
      "Will secure any request with filters",
      "Exposing 15 endpoint(s) beneath base path '/actuator'",
      "LiveReload server is running on port 35729",
      "Shutting down ExecutorService 'applicationTaskExecutor'",
      "HikariPool-1 - Shutdown initiated...",
      "HikariPool-1 - Shutdown completed."
    ]

    class << self
      def generate_log_entry
        case rand(100)
        when 0..40
          # HTTP request logs (40%)
          generate_http_request_log
        when 41..55
          # SQL logs (15%)
          generate_sql_log
        when 56..70
          # Application logs (15%)
          generate_application_log
        when 71..80
          # Service/business logs (10%)
          generate_service_log
        when 81..88
          # Exception logs (8%)
          generate_exception_log
        when 89..94
          # Framework logs (6%)
          generate_framework_log
        when 95..97
          # Performance logs (3%)
          generate_performance_log
        else
          # Security logs (3%)
          generate_security_log
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

        'INFO' # fallback
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
        # Spring Boot default timestamp format
        Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')
      end

      def format_thread
        threads = ['http-nio-8080-exec-1', 'http-nio-8080-exec-2', 'http-nio-8080-exec-3',
                  'http-nio-8080-exec-4', 'http-nio-8080-exec-5', 'http-nio-8080-exec-6',
                  'scheduling-1', 'task-1', 'task-2', 'kafka-listener-1', 'async-1']
        threads.sample
      end

      def generate_http_request_log
        endpoint = ENDPOINTS.sample
        method = endpoint[:methods].sample
        path = endpoint[:path].gsub('{id}', rand(1..10000).to_s)
        status = weighted_status_code
        duration = rand(5..500)

        level = status >= 500 ? 'ERROR' : (status >= 400 ? 'WARN' : 'INFO')
        level_color = LOG_LEVELS[level][:color]

        # Spring Boot request logging format
        "#{format_timestamp} #{level_color}#{level.ljust(5)}#{Colors::RESET} [#{format_thread}] " \
        "#{Colors::CYAN}com.example.api.filter.RequestLoggingFilter#{Colors::RESET} : " \
        "#{method} #{path} - Status: #{status}, Duration: #{duration}ms"
      end

      def generate_sql_log
        query = SQL_QUERIES.sample
        duration = rand(1..100)

        logs = []

        # Hibernate SQL logging
        logs << "#{format_timestamp} #{Colors::CYAN}DEBUG#{Colors::RESET} [#{format_thread}] " \
                "#{Colors::CYAN}org.hibernate.SQL#{Colors::RESET} : #{query}"

        # Sometimes add parameter binding logs
        if rand < 0.5
          param_count = query.scan(/\?/).count
          param_count.times do |i|
            value = case rand(3)
                   when 0 then "'user#{rand(1000)}@example.com'"
                   when 1 then rand(1..10000)
                   else "'2024-01-15 10:30:00'"
                   end

            logs << "#{format_timestamp} #{Colors::GRAY}TRACE#{Colors::RESET} [#{format_thread}] " \
                    "#{Colors::GRAY}org.hibernate.type.descriptor.sql.BasicBinder#{Colors::RESET} : " \
                    "binding parameter [#{i + 1}] as [#{%w[VARCHAR BIGINT TIMESTAMP].sample}] - [#{value}]"
          end
        end

        # Sometimes add statistics
        if rand < 0.3
          logs << "#{format_timestamp} #{Colors::GREEN}INFO#{Colors::RESET}  [#{format_thread}] " \
                  "#{Colors::GREEN}org.hibernate.engine.internal.StatisticalLoggingSessionEventListener#{Colors::RESET} : " \
                  "Session Metrics { #{rand(10000)}00 nanoseconds spent acquiring #{rand(1..5)} JDBC connections; " \
                  "#{rand(1000)}00 nanoseconds spent releasing #{rand(1..3)} JDBC connections; " \
                  "#{rand(10000)}00 nanoseconds spent preparing #{rand(1..10)} JDBC statements; }"
        end

        logs.join("\n")
      end

      def generate_application_log
        event = APP_EVENTS.sample

        # Most app events are INFO level
        "#{format_timestamp} #{Colors::GREEN}INFO#{Colors::RESET}  [main] " \
        "#{Colors::GREEN}com.example.api.Application#{Colors::RESET} : #{event}"
      end

      def generate_service_log
        services = [
          { logger: 'UserService', message: "User authentication successful for: user#{rand(1000)}@example.com" },
          { logger: 'UserService', message: "Creating new user account with email: newuser#{rand(1000)}@example.com" },
          { logger: 'ProductService', message: "Fetching products for category: #{%w[electronics clothing books food].sample}" },
          { logger: 'ProductService', message: "Product inventory updated - SKU: PROD#{rand(10000)}, Stock: #{rand(0..100)}" },
          { logger: 'OrderService', message: "Processing order ##{rand(100000..999999)} for customer #{rand(1000)}" },
          { logger: 'OrderService', message: "Order completed successfully - Total: $#{rand(10..1000)}.#{rand(10..99)}" },
          { logger: 'EmailService', message: "Sending order confirmation email to: customer#{rand(1000)}@example.com" },
          { logger: 'EmailService', message: "Email sent successfully via SMTP server" },
          { logger: 'CacheService', message: "Cache hit for key: user:#{rand(1000)}:profile" },
          { logger: 'CacheService', message: "Evicting cache entries for pattern: product:*" }
        ]

        service = services.sample
        level = weighted_log_level
        level_color = LOG_LEVELS[level][:color]

        "#{format_timestamp} #{level_color}#{level.ljust(5)}#{Colors::RESET} [#{format_thread}] " \
        "#{level_color}com.example.api.service.#{service[:logger]}#{Colors::RESET} : #{service[:message]}"
      end

      def generate_exception_log
        exception = EXCEPTIONS.sample

        logs = []

        # Main error message
        logs << "#{format_timestamp} #{Colors::BRIGHT_RED}ERROR#{Colors::RESET} [#{format_thread}] " \
                "#{Colors::BRIGHT_RED}com.example.api.exception.GlobalExceptionHandler#{Colors::RESET} : " \
                "Handling exception: #{exception[:type]}: #{exception[:message]}"

        # Stack trace
        logs << "#{exception[:type]}: #{exception[:message]}"
        logs << "\tat com.example.api.service.UserService.findById(UserService.java:#{rand(50..200)})"
        logs << "\tat com.example.api.controller.UserController.getUser(UserController.java:#{rand(30..100)})"
        logs << "\tat java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)"
        logs << "\tat org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:#{rand(200..300)})"
        logs << "\tat org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:#{rand(100..200)})"
        logs << "\t... #{rand(20..50)} more"

        logs.join("\n")
      end

      def generate_framework_log
        frameworks = [
          { logger: 'org.springframework.web.servlet.DispatcherServlet',
            message: "Completed initialization in #{rand(100..1000)} ms" },
          { logger: 'org.springframework.data.repository.config.RepositoryConfigurationDelegate',
            message: "Bootstrapping Spring Data JPA repositories in DEFAULT mode." },
          { logger: 'org.springframework.security.web.DefaultSecurityFilterChain',
            message: "Will secure any request with #{rand(10..15)} filters" },
          { logger: 'org.springframework.boot.actuate.endpoint.web.EndpointLinksResolver',
            message: "Exposing #{rand(10..20)} endpoint(s) beneath base path '/actuator'" },
          { logger: 'org.springframework.kafka.listener.KafkaMessageListenerContainer',
            message: "partitions assigned: [user-events-0, user-events-1]" },
          { logger: 'org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor',
            message: "Initializing ExecutorService 'applicationTaskExecutor'" },
          { logger: 'com.zaxxer.hikari.HikariDataSource',
            message: "HikariPool-1 - Starting..." },
          { logger: 'org.springframework.cache.interceptor.CacheInterceptor',
            message: "Cache entry for key 'product:#{rand(1000)}' found in cache 'products'" }
        ]

        framework = frameworks.sample

        "#{format_timestamp} #{Colors::GREEN}INFO#{Colors::RESET}  [#{format_thread}] " \
        "#{Colors::GREEN}#{framework[:logger]}#{Colors::RESET} : #{framework[:message]}"
      end

      def generate_performance_log
        metrics = [
          "GC pause: G1 Young Generation - duration: #{rand(10..200)}ms, freed: #{rand(50..500)}MB",
          "Method execution time: UserService.findAll() - #{rand(100..2000)}ms",
          "Database connection pool: active=#{rand(0..20)}, idle=#{rand(0..10)}, total=30",
          "HTTP request queue: size=#{rand(0..50)}, rejected=#{rand(0..5)}",
          "Cache statistics: hits=#{rand(1000..10000)}, misses=#{rand(100..1000)}, hit-ratio=#{rand(70..95)}%",
          "JVM memory: heap=#{rand(200..800)}MB/1024MB, non-heap=#{rand(50..150)}MB"
        ]

        "#{format_timestamp} #{Colors::GREEN}INFO#{Colors::RESET}  [metrics-logger] " \
        "#{Colors::GREEN}com.example.api.monitoring.PerformanceMonitor#{Colors::RESET} : #{metrics.sample}"
      end

      def generate_security_log
        events = [
          "Authentication attempt for user: admin@example.com from IP: #{LogUtils.ip_address}",
          "JWT token validated successfully for user: user#{rand(1000)}",
          "Failed login attempt for user: test@example.com - Invalid credentials",
          "Access denied to /api/v1/admin/users for user: regular.user@example.com",
          "Password changed for user: user#{rand(1000)}@example.com",
          "Account locked due to #{rand(3..5)} failed login attempts: suspicious@example.com",
          "CORS request from origin: https://example.com - Allowed",
          "Suspicious activity detected: Multiple failed login attempts from IP: #{LogUtils.ip_address}"
        ]

        level = events.last.include?('Failed') || events.last.include?('denied') ? 'WARN' : 'INFO'
        level_color = LOG_LEVELS[level][:color]

        "#{format_timestamp} #{level_color}#{level.ljust(5)}#{Colors::RESET} [#{format_thread}] " \
        "#{level_color}com.example.api.security.SecurityEventLogger#{Colors::RESET} : #{events.sample}"
      end
    end
  end
end
