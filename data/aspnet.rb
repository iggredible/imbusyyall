# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Aspnet
    CONTROLLERS = %w[
      HomeController AccountController ProductController OrderController
      CartController CheckoutController AdminController ApiController
      InventoryController CustomerController PaymentController ReportController
      ShippingController CategoryController ReviewController
    ]

    ACTIONS = %w[
      Index Details Create Edit Delete Login Logout Register
      Search Filter Export Import Process Submit Validate
      Calculate Authorize Capture Refund Ship Track
      GenerateReport DownloadInvoice UpdateStatus
    ]

    HTTP_METHODS = %w[GET POST PUT DELETE PATCH HEAD OPTIONS]

    LOG_LEVELS = {
      'Information' => "\e[32m",  # GREEN
      'Warning' => "\e[33m",      # YELLOW
      'Error' => "\e[31m",        # RED
      'Critical' => "\e[91m",     # BRIGHT_RED
      'Debug' => "\e[36m",        # CYAN
      'Trace' => "\e[90m"         # GRAY
    }

    STATUS_CODES = [200, 201, 202, 204, 301, 302, 304, 400, 401, 403, 404, 409, 422, 500, 502, 503]

    STATUS_CODE_COLORS = {
      200 => "\e[32m", # GREEN
      201 => "\e[32m", # GREEN
      202 => "\e[32m", # GREEN
      204 => "\e[32m", # GREEN
      301 => "\e[36m", # CYAN
      302 => "\e[36m", # CYAN
      304 => "\e[36m", # CYAN
      400 => "\e[33m", # YELLOW
      401 => "\e[33m", # YELLOW
      403 => "\e[33m", # YELLOW
      404 => "\e[33m", # YELLOW
      409 => "\e[33m", # YELLOW
      422 => "\e[31m", # RED
      500 => "\e[31m", # RED
      502 => "\e[31m", # RED
      503 => "\e[31m"  # RED
    }

    CATEGORIES = [
      'Microsoft.AspNetCore.Hosting.Diagnostics',
      'Microsoft.AspNetCore.Mvc.Infrastructure.ControllerActionInvoker',
      'Microsoft.AspNetCore.Routing.EndpointMiddleware',
      'Microsoft.AspNetCore.Authorization.DefaultAuthorizationService',
      'Microsoft.EntityFrameworkCore.Database.Command',
      'Microsoft.EntityFrameworkCore.Infrastructure',
      'Microsoft.AspNetCore.DataProtection.KeyManagement.XmlKeyManager',
      'Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationHandler',
      'Microsoft.AspNetCore.Server.Kestrel',
      'Microsoft.Extensions.Hosting.Internal.Host',
      'System.Net.Http.HttpClient',
      'MyApp.Controllers',
      'MyApp.Services',
      'MyApp.Data'
    ]

    ROUTES = [
      '/',
      '/Home/Index',
      '/Account/Login',
      '/Account/Register',
      '/Products',
      '/Products/Details/{id}',
      '/Cart',
      '/Cart/Add',
      '/Checkout',
      '/api/products',
      '/api/orders',
      '/api/customers/{id}',
      '/Admin/Dashboard',
      '/Admin/Reports',
      '/Admin/Users',
      '/Admin/Settings'
    ]

    SQL_QUERIES = [
      'SELECT [p].[Id], [p].[Name], [p].[Price], [p].[Stock] FROM [Products] AS [p] WHERE [p].[CategoryId] = @__categoryId_0',
      'SELECT TOP(1) [u].[Id], [u].[Email], [u].[PasswordHash] FROM [Users] AS [u] WHERE [u].[Email] = @__normalizedEmail_0',
      'INSERT INTO [Orders] ([CustomerId], [OrderDate], [Status], [Total]) VALUES (@p0, @p1, @p2, @p3)',
      'UPDATE [Products] SET [Stock] = @p0 WHERE [Id] = @p1',
      'DELETE FROM [CartItems] WHERE [CartId] = @__cart_Id_0',
      'SELECT COUNT(*) FROM [Orders] WHERE [Status] = @__status_0',
      'EXEC GetOrdersByDateRange @StartDate, @EndDate'
    ]

    EXCEPTIONS = [
      'System.InvalidOperationException: Unable to resolve service for type',
      'System.NullReferenceException: Object reference not set to an instance of an object',
      'Microsoft.EntityFrameworkCore.DbUpdateException: An error occurred while updating the entries',
      'System.ArgumentException: Value cannot be null or empty. (Parameter \'key\')',
      'Microsoft.AspNetCore.Authorization.AuthorizationFailureException: Authorization failed',
      'System.Data.SqlClient.SqlException: Timeout expired',
      'System.Net.Http.HttpRequestException: Response status code does not indicate success: 404 (Not Found)'
    ]

    STACK_TRACE_ENTRIES = [
      'at MyApp.Controllers.ProductController.Details(Int32 id) in /src/Controllers/ProductController.cs:line 45',
      'at MyApp.Services.OrderService.ProcessOrder(Order order) in /src/Services/OrderService.cs:line 78',
      'at Microsoft.EntityFrameworkCore.Storage.RelationalCommand.ExecuteReaderAsync()',
      'at Microsoft.AspNetCore.Mvc.Infrastructure.ActionMethodExecutor.Execute()',
      'at System.Threading.Tasks.Task.ThrowIfExceptional(Boolean includeTaskCanceledExceptions)'
    ]

    REQUEST_IDS = []

    class << self
      def generate_request_id
        "0HN#{SecureRandom.hex(8).upcase}"
      end

      def log_level
        weights = {
          'Information' => 60,
          'Warning' => 15,
          'Error' => 10,
          'Debug' => 10,
          'Critical' => 2,
          'Trace' => 3
        }
        LogUtils.weighted_sample(weights)
      end

      def controller
        CONTROLLERS.sample
      end

      def action
        ACTIONS.sample
      end

      def http_method
        HTTP_METHODS.sample
      end

      def status_code
        STATUS_CODES.sample
      end

      def category
        CATEGORIES.sample
      end

      def route
        ROUTES.sample
      end

      def sql_query
        SQL_QUERIES.sample
      end

      def exception
        EXCEPTIONS.sample
      end

      def stack_trace_entry
        STACK_TRACE_ENTRIES.sample
      end

      def generate_log_entry
        case rand(10)
        when 0..5
          # HTTP Request logs (60%)
          generate_request_logs
        when 6..7
          # Database operation logs (20%)
          generate_database_logs
        when 8
          # Application lifecycle logs (10%)
          generate_lifecycle_logs
        when 9
          # Error logs (10%)
          generate_error_logs
        end
      end

      private

      def generate_request_logs
        request_id = generate_request_id
        method = http_method
        path = route
        status = status_code
        duration = LogUtils.random_duration(1.0, 500.0)

        [
          format_log_line('Information', 'Microsoft.AspNetCore.Hosting.Diagnostics',
            "Request starting #{method} #{path} - -", request_id),
          rand < 0.3 ? format_log_line('Information', 'Microsoft.AspNetCore.Authorization.DefaultAuthorizationService',
            "Authorization was successful.", request_id) : nil,
          format_log_line('Information', "MyApp.Controllers.#{controller}",
            "Executing action #{action}", request_id),
          rand < 0.5 ? generate_single_database_log(request_id) : nil,
          format_log_line('Information', "MyApp.Controllers.#{controller}",
            "Executed action #{action} in #{duration}ms", request_id),
          format_log_line('Information', 'Microsoft.AspNetCore.Hosting.Diagnostics',
            "Request finished #{method} #{path} - #{status} in #{duration}ms", request_id)
        ].compact
      end

      def generate_database_logs
        request_id = generate_request_id
        [generate_single_database_log(request_id)]
      end

      def generate_single_database_log(request_id = nil)
        query = sql_query
        duration = LogUtils.random_duration(0.5, 100.0)

        format_log_line('Information', 'Microsoft.EntityFrameworkCore.Database.Command',
          "Executed DbCommand (#{duration}ms) [Parameters=[@p0='?', @p1='?'], CommandType='Text', CommandTimeout='30']\n      #{query}",
          request_id)
      end

      def generate_lifecycle_logs
        messages = [
          "Application started. Press Ctrl+C to shut down.",
          "Now listening on: http://localhost:5000",
          "Application is shutting down...",
          "Hosting environment: Production",
          "Content root path: /app"
        ]

        [format_log_line('Information', 'Microsoft.Extensions.Hosting.Internal.Host', messages.sample)]
      end

      def generate_error_logs
        exc = exception
        [
          format_log_line('Error', "MyApp.Controllers.#{controller}",
            "An unhandled exception has occurred while executing the request.\n      #{exc}"),
          format_log_line('Debug', 'Microsoft.AspNetCore.Diagnostics.ExceptionHandlerMiddleware',
            "   #{stack_trace_entry}"),
          format_log_line('Debug', 'Microsoft.AspNetCore.Diagnostics.ExceptionHandlerMiddleware',
            "   #{stack_trace_entry}")
        ]
      end

      def format_log_line(level, category, message, request_id = nil)
        level_color = LOG_LEVELS[level]
        timestamp = Time.now.strftime('%Y-%m-%d %H:%M:%S')

        # Format: level: timestamp [RequestId?] Category[EventId] Message
        request_part = request_id ? "[#{request_id}] " : ""

        "#{level_color}#{level.ljust(11)}#{Colors::RESET}: #{timestamp} #{request_part}#{Colors::CYAN}#{category}[0]#{Colors::RESET}\n      #{message}"
      end
    end
  end
end

# Add weighted_sample to LogUtils if it doesn't exist
module LogUtils
  def self.weighted_sample(weights)
    total = weights.values.sum
    rand_num = rand * total

    cumulative = 0
    weights.each do |item, weight|
      cumulative += weight
      return item if rand_num <= cumulative
    end

    weights.keys.last
  end
end
