# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Django
    # Django URL patterns
    URL_PATTERNS = [
      '/api/v1/users/',
      '/api/v1/users/<int:pk>/',
      '/api/v1/products/',
      '/api/v1/products/<int:pk>/reviews/',
      '/api/v1/orders/',
      '/api/v1/orders/<uuid:order_id>/',
      '/api/v1/auth/login/',
      '/api/v1/auth/logout/',
      '/api/v1/auth/token/refresh/',
      '/admin/',
      '/admin/auth/user/',
      '/admin/shop/product/',
      '/admin/blog/post/add/',
      '/accounts/login/',
      '/accounts/register/',
      '/accounts/password/reset/',
      '/blog/',
      '/blog/<slug:slug>/',
      '/shop/cart/',
      '/shop/checkout/',
      '/api/graphql/',
      '/api/schema/',
      '/__debug__/sql/',
      '/media/uploads/',
      '/static/css/main.css',
      '/static/js/app.js',
      '/health/',
      '/metrics/'
    ]

    # Django apps and views
    APPS_AND_VIEWS = [
      'django.contrib.admin.sites.index',
      'django.contrib.auth.views.LoginView',
      'django.contrib.auth.views.LogoutView',
      'shop.views.ProductListView',
      'shop.views.ProductDetailView',
      'blog.views.PostListView',
      'blog.views.PostDetailView',
      'api.views.UserViewSet',
      'api.views.OrderViewSet',
      'accounts.views.ProfileView',
      'accounts.views.RegisterView',
      'core.views.HomeView',
      'analytics.views.DashboardView'
    ]

    HTTP_METHODS = %w[GET POST PUT PATCH DELETE HEAD OPTIONS]

    # Django log levels with colors
    LOG_LEVELS = {
      critical: { color: Colors::BRIGHT_RED, label: 'CRITICAL', django_label: 'django' },
      error: { color: Colors::RED, label: 'ERROR', django_label: 'django.request' },
      warning: { color: Colors::YELLOW, label: 'WARNING', django_label: 'django.security' },
      info: { color: Colors::CYAN, label: 'INFO', django_label: 'django.server' },
      debug: { color: Colors::GRAY, label: 'DEBUG', django_label: 'django.db.backends' }
    }

    # Django specific errors
    DJANGO_ERRORS = [
      "DoesNotExist: User matching query does not exist.",
      "MultipleObjectsReturned: get() returned more than one User -- it returned 2!",
      "ValidationError: {'email': ['Enter a valid email address.']}",
      "PermissionDenied: You do not have permission to perform this action.",
      "Http404: No Product matches the given query.",
      "ImproperlyConfigured: The SECRET_KEY setting must not be empty.",
      "FieldError: Cannot resolve keyword 'user_id' into field.",
      "IntegrityError: UNIQUE constraint failed: auth_user.username",
      "OperationalError: no such table: shop_product",
      "ProgrammingError: relation 'blog_post' does not exist",
      "SuspiciousOperation: Invalid HTTP_HOST header",
      "DisallowedHost: Invalid HTTP_HOST header: 'example.com'",
      "TemplateDoesNotExist: 404.html"
    ]

    # SQL queries with Django ORM style
    SQL_QUERIES = [
      'SELECT "auth_user"."id", "auth_user"."username" FROM "auth_user" WHERE "auth_user"."is_active" = True',
      'SELECT COUNT(*) AS "__count" FROM "shop_product" WHERE "shop_product"."category_id" = 1',
      'INSERT INTO "blog_post" ("title", "slug", "content", "created_at") VALUES (%s, %s, %s, %s)',
      'UPDATE "shop_order" SET "status" = %s WHERE "shop_order"."id" = %s',
      'DELETE FROM "django_session" WHERE "django_session"."expire_date" < %s',
      'SELECT "shop_product"."id" FROM "shop_product" INNER JOIN "shop_category" ON ("shop_product"."category_id" = "shop_category"."id")',
      'BEGIN; INSERT INTO "auth_user" ... COMMIT;',
      'SAVEPOINT "s140735624254208_x1"',
      'RELEASE SAVEPOINT "s140735624254208_x1"',
      'SELECT "django_migrations"."app", "django_migrations"."name" FROM "django_migrations"'
    ]

    # Middleware components
    MIDDLEWARE = [
      'django.middleware.security.SecurityMiddleware',
      'django.contrib.sessions.middleware.SessionMiddleware',
      'django.middleware.common.CommonMiddleware',
      'django.middleware.csrf.CsrfViewMiddleware',
      'django.contrib.auth.middleware.AuthenticationMiddleware',
      'django.contrib.messages.middleware.MessageMiddleware',
      'django.middleware.clickjacking.XFrameOptionsMiddleware',
      'corsheaders.middleware.CorsMiddleware',
      'debug_toolbar.middleware.DebugToolbarMiddleware',
      'whitenoise.middleware.WhiteNoiseMiddleware'
    ]

    # Django management commands
    MANAGEMENT_COMMANDS = [
      'migrate',
      'makemigrations',
      'collectstatic',
      'createsuperuser',
      'runserver',
      'shell',
      'test',
      'check',
      'dbshell',
      'dumpdata',
      'loaddata'
    ]

    # Cache operations
    CACHE_OPERATIONS = [
      'cache.get("user_profile_123")',
      'cache.set("product_list_page_1", queryset, 300)',
      'cache.delete("session_abc123")',
      'cache.clear()',
      'cache.get_many(["key1", "key2", "key3"])',
      'cache.touch("api_response_456", 3600)'
    ]

    # Celery task names
    CELERY_TASKS = [
      'shop.tasks.process_order',
      'accounts.tasks.send_welcome_email',
      'analytics.tasks.generate_report',
      'blog.tasks.update_search_index',
      'core.tasks.cleanup_expired_sessions',
      'notifications.tasks.send_push_notification'
    ]

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
      405 => Colors::YELLOW,
      422 => Colors::YELLOW,
      500 => Colors::RED,
      502 => Colors::RED,
      503 => Colors::RED
    }

    class << self
      def url_pattern
        pattern = URL_PATTERNS.sample
        # Replace Django URL parameters with actual values
        pattern.gsub('<int:pk>', rand(1..1000).to_s)
               .gsub('<uuid:order_id>', SecureRandom.uuid)
               .gsub('<slug:slug>', "post-#{rand(100)}")
      end

      def app_and_view
        APPS_AND_VIEWS.sample
      end

      def http_method
        HTTP_METHODS.sample
      end

      def status_code
        STATUS_CODE_COLORS.keys.sample
      end

      def django_error
        DJANGO_ERRORS.sample
      end

      def sql_query
        SQL_QUERIES.sample
      end

      def middleware
        MIDDLEWARE.sample
      end

      def management_command
        MANAGEMENT_COMMANDS.sample
      end

      def cache_operation
        CACHE_OPERATIONS.sample
      end

      def celery_task
        CELERY_TASKS.sample
      end

      def generate_log_entry
        case rand(100)
        when 0..50
          # HTTP request logs (50%)
          generate_request_logs
        when 51..65
          # Database logs (15%)
          generate_database_logs
        when 66..75
          # Error logs (10%)
          generate_error_logs
        when 76..83
          # Cache logs (8%)
          [generate_cache_log]
        when 84..90
          # Celery logs (7%)
          [generate_celery_log]
        when 91..95
          # Management command logs (5%)
          [generate_management_log]
        else
          # Security/warning logs (5%)
          [generate_security_log]
        end
      end

      private

      def generate_request_logs
        method = http_method
        path = url_pattern
        status = status_code
        response_time = rand(10..500)
        
        logs = []
        
        # Django development server log
        timestamp = Time.now.strftime('[%d/%b/%Y %H:%M:%S]')
        status_color = STATUS_CODE_COLORS[status] || Colors::RED
        
        logs << "#{Colors::GRAY}#{timestamp}#{Colors::RESET} " \
                "\"#{method} #{path} HTTP/1.1\" " \
                "#{status_color}#{status}#{Colors::RESET} " \
                "#{rand(100..50000)}"
        
        # Sometimes add debug info
        if rand < 0.2 && status >= 400
          logs << generate_traceback
        end
        
        logs
      end

      def generate_database_logs
        query = sql_query
        duration = rand(0.5..100.0).round(3)
        
        logs = []
        
        # Django DB backend log
        level = LOG_LEVELS[:debug]
        logs << "#{Colors::GRAY}[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]#{Colors::RESET} " \
                "#{level[:color]}#{level[:django_label]}#{Colors::RESET} " \
                "(#{duration}) #{Colors::BLUE}#{query}#{Colors::RESET}; args=#{generate_query_args}"
        
        # Sometimes add EXPLAIN output
        if rand < 0.1 && query.start_with?('SELECT')
          logs << "#{Colors::GRAY}[EXPLAIN]#{Colors::RESET} Seq Scan on auth_user  (cost=0.00..1.52 rows=52 width=161)"
        end
        
        logs
      end

      def generate_error_logs
        error = django_error
        
        logs = []
        
        # Main error log
        level = LOG_LEVELS[:error]
        logs << "#{Colors::RED}[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]#{Colors::RESET} " \
                "#{level[:color]}#{level[:django_label]}#{Colors::RESET} " \
                "Internal Server Error: #{url_pattern}"
        
        logs << "#{level[:color]}#{error}#{Colors::RESET}"
        
        # Add traceback
        logs.concat(generate_django_traceback)
        
        logs
      end

      def generate_cache_log
        operation = cache_operation
        level = LOG_LEVELS[:debug]
        
        result = case operation
                 when /get/ then rand < 0.7 ? "HIT" : "MISS"
                 when /set/ then "STORED"
                 when /delete/ then "DELETED"
                 else "OK"
                 end
        
        "#{Colors::GRAY}[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]#{Colors::RESET} " \
        "#{level[:color]}django.core.cache#{Colors::RESET} " \
        "#{Colors::MAGENTA}#{operation}#{Colors::RESET} -> #{result}"
      end

      def generate_celery_log
        task = celery_task
        task_id = SecureRandom.hex(16)
        
        case rand(3)
        when 0
          # Task received
          "#{Colors::CYAN}[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]#{Colors::RESET} " \
          "#{Colors::CYAN}celery.worker#{Colors::RESET} " \
          "Task #{task}[#{task_id}] received"
        when 1
          # Task succeeded
          duration = rand(100..5000)
          "#{Colors::GREEN}[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]#{Colors::RESET} " \
          "#{Colors::GREEN}celery.worker#{Colors::RESET} " \
          "Task #{task}[#{task_id}] succeeded in #{duration/1000.0}s"
        else
          # Task failed
          "#{Colors::RED}[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]#{Colors::RESET} " \
          "#{Colors::RED}celery.worker#{Colors::RESET} " \
          "Task #{task}[#{task_id}] raised unexpected: #{django_error}"
        end
      end

      def generate_management_log
        command = management_command
        
        case command
        when 'migrate'
          "#{Colors::GREEN}Operations to perform:#{Colors::RESET}\n" \
          "  Apply all migrations: admin, auth, contenttypes, sessions, shop\n" \
          "#{Colors::GREEN}Running migrations:#{Colors::RESET}\n" \
          "  Applying shop.0003_auto_#{Time.now.strftime('%Y%m%d_%H%M')}... #{Colors::GREEN}OK#{Colors::RESET}"
        when 'collectstatic'
          "#{Colors::CYAN}You have requested to collect static files.#{Colors::RESET}\n" \
          "#{rand(50..200)} static files copied to '/static/'."
        when 'test'
          "#{Colors::YELLOW}Creating test database for alias 'default'...#{Colors::RESET}\n" \
          "System check identified no issues (0 silenced).\n" \
          "#{Colors::GREEN}Ran #{rand(10..100)} tests in #{rand(1..30).round(3)}s#{Colors::RESET}\n" \
          "#{Colors::GREEN}OK#{Colors::RESET}"
        else
          "#{Colors::CYAN}Executing management command: #{command}#{Colors::RESET}"
        end
      end

      def generate_security_log
        level = LOG_LEVELS[:warning]
        
        warnings = [
          "Forbidden (CSRF token missing or incorrect.): #{url_pattern}",
          "Forbidden (Origin checking failed - https://evil.com does not match any trusted origins.)",
          "You're using the staticfiles app without having set the STATIC_ROOT setting.",
          "Invalid HTTP_HOST header: '192.168.1.1'. You may need to add '192.168.1.1' to ALLOWED_HOSTS.",
          "UserWarning: A {% csrf_token %} was used in a template, but the context did not provide the value."
        ]
        
        "#{Colors::YELLOW}[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}]#{Colors::RESET} " \
        "#{level[:color]}#{level[:django_label]}#{Colors::RESET} " \
        "#{warnings.sample}"
      end

      def generate_traceback
        view = app_and_view
        
        "Traceback (most recent call last):\n" \
        "  File \"/usr/local/lib/python3.9/site-packages/django/core/handlers/exception.py\", line 47, in inner\n" \
        "    response = get_response(request)\n" \
        "  File \"/usr/local/lib/python3.9/site-packages/django/core/handlers/base.py\", line 181, in _get_response\n" \
        "    response = wrapped_callback(request, *callback_args, **callback_kwargs)\n" \
        "  File \"/app/#{view.gsub('.', '/')}.py\", line #{rand(10..200)}, in #{view.split('.').last}\n" \
        "    #{generate_error_line}"
      end

      def generate_django_traceback
        [
          "  File \"/usr/local/lib/python3.9/site-packages/django/db/models/query.py\", line #{rand(400..500)}, in get",
          "    raise self.model.DoesNotExist(",
          "  File \"/app/shop/models.py\", line #{rand(10..100)}, in get_absolute_url",
          "    return reverse('shop:product_detail', kwargs={'pk': self.pk})"
        ].map { |line| "#{Colors::GRAY}#{line}#{Colors::RESET}" }
      end

      def generate_error_line
        [
          "user = User.objects.get(pk=user_id)",
          "product.category.name",
          "return render(request, 'shop/product_list.html', context)",
          "serializer.is_valid(raise_exception=True)",
          "order.items.all().delete()"
        ].sample
      end

      def generate_query_args
        case rand(3)
        when 0 then "()"
        when 1 then "(#{rand(1..100)},)"
        else "('#{%w[active pending completed].sample}', '#{Time.now}')"
        end
      end
    end
  end
end