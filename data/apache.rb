# frozen_string_literal: true

require_relative '../lib/utils'

module DataSources
  module Apache
    # Common web resources and paths
    RESOURCES = [
      '/',
      '/index.html',
      '/about.html',
      '/contact.html',
      '/products.html',
      '/services.html',
      '/blog/',
      '/blog/2024/01/web-development-trends',
      '/blog/2024/02/security-best-practices',
      '/api/v1/users',
      '/api/v1/products',
      '/api/v1/orders',
      '/admin/',
      '/admin/login',
      '/admin/dashboard',
      '/assets/css/main.css',
      '/assets/js/app.js',
      '/assets/js/jquery.min.js',
      '/assets/images/logo.png',
      '/assets/images/hero-banner.jpg',
      '/assets/fonts/roboto.woff2',
      '/favicon.ico',
      '/robots.txt',
      '/sitemap.xml',
      '/wp-admin/',
      '/wp-login.php',
      '/phpmyadmin/',
      '/downloads/whitepaper.pdf',
      '/search',
      '/newsletter/signup',
      '/user/profile',
      '/user/settings',
      '/checkout',
      '/payment/success',
      '/404.html',
      '/500.html'
    ]

    # HTTP methods with realistic distribution
    HTTP_METHODS = {
      'GET' => 85,     # 85% GET requests
      'POST' => 10,    # 10% POST requests
      'HEAD' => 3,     # 3% HEAD requests
      'PUT' => 1,      # 1% PUT requests
      'DELETE' => 1    # 1% DELETE requests
    }

    # HTTP status codes with colors and realistic distribution
    STATUS_CODES = {
      200 => { weight: 70, color: Colors::GREEN, message: 'OK' },
      304 => { weight: 10, color: Colors::CYAN, message: 'Not Modified' },
      404 => { weight: 8, color: Colors::YELLOW, message: 'Not Found' },
      301 => { weight: 3, color: Colors::CYAN, message: 'Moved Permanently' },
      302 => { weight: 2, color: Colors::CYAN, message: 'Found' },
      403 => { weight: 2, color: Colors::YELLOW, message: 'Forbidden' },
      500 => { weight: 2, color: Colors::RED, message: 'Internal Server Error' },
      400 => { weight: 1, color: Colors::YELLOW, message: 'Bad Request' },
      401 => { weight: 1, color: Colors::YELLOW, message: 'Unauthorized' },
      503 => { weight: 1, color: Colors::RED, message: 'Service Unavailable' }
    }

    # Common User Agents
    USER_AGENTS = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:89.0) Gecko/20100101 Firefox/89.0',
      'Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Edge/91.0.864.59',
      'Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1',
      'Mozilla/5.0 (Android 11; Mobile; rv:89.0) Gecko/89.0 Firefox/89.0',
      'Googlebot/2.1 (+http://www.google.com/bot.html)',
      'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)',
      'Twitterbot/1.0',
      'LinkedInBot/1.0 (compatible; Mozilla/5.0; +http://www.linkedin.com/)',
      'curl/7.68.0',
      'Wget/1.20.3 (linux-gnu)'
    ]

    # Common referrers
    REFERRERS = [
      '-', # Direct access (no referrer)
      'https://www.google.com/',
      'https://www.google.com/search?q=web+development',
      'https://www.bing.com/search?q=apache+server',
      'https://github.com/',
      'https://stackoverflow.com/',
      'https://www.reddit.com/',
      'https://twitter.com/',
      'https://www.facebook.com/',
      'https://www.linkedin.com/',
      'https://news.ycombinator.com/',
      'https://dev.to/',
      'https://medium.com/'
    ]

    # Apache error log types and messages
    ERROR_TYPES = {
      'emerg' => { color: Colors::BRIGHT_RED, label: '[emerg]' },
      'alert' => { color: Colors::BRIGHT_RED, label: '[alert]' },
      'crit' => { color: Colors::RED, label: '[crit]' },
      'error' => { color: Colors::RED, label: '[error]' },
      'warn' => { color: Colors::YELLOW, label: '[warn]' },
      'notice' => { color: Colors::CYAN, label: '[notice]' },
      'info' => { color: Colors::BLUE, label: '[info]' },
      'debug' => { color: Colors::GRAY, label: '[debug]' }
    }

    ERROR_MESSAGES = [
      'server reached MaxRequestWorkers setting, consider raising the MaxRequestWorkers setting',
      'child process 12345 still did not exit, sending a SIGTERM',
      'caught SIGTERM, shutting down',
      'httpd (pid 1234) already running',
      'mod_ssl: SSL handshake failed (server example.com:443, client 192.168.1.100)',
      'File does not exist: /var/www/html/favicon.ico',
      'script not found or unable to stat: /var/www/cgi-bin/test.cgi',
      'Invalid command \'LoadModule\', perhaps misspelled or defined by a module not included in the server configuration',
      'Permission denied: could not open error log file /var/log/apache2/error.log',
      'DocumentRoot [/var/www/html] does not exist'
    ]

    # Apache modules
    MODULES = [
      'mod_rewrite',
      'mod_ssl',
      'mod_headers',
      'mod_deflate',
      'mod_expires',
      'mod_security2',
      'mod_evasive',
      'mod_status',
      'mod_info',
      'mod_php'
    ]

    class << self
      def resource
        RESOURCES.sample
      end

      def http_method
        # Weighted random selection based on realistic distribution
        total = HTTP_METHODS.values.sum
        random = rand(total)
        
        cumulative = 0
        HTTP_METHODS.each do |method, weight|
          cumulative += weight
          return method if random < cumulative
        end
        
        'GET' # fallback
      end

      def status_code
        # Weighted random selection based on realistic distribution
        total = STATUS_CODES.values.sum { |v| v[:weight] }
        random = rand(total)
        
        cumulative = 0
        STATUS_CODES.each do |code, data|
          cumulative += data[:weight]
          return code if random < cumulative
        end
        
        200 # fallback
      end

      def status_color(code)
        STATUS_CODES[code]&.dig(:color) || Colors::RED
      end

      def status_message(code)
        STATUS_CODES[code]&.dig(:message) || 'Unknown'
      end

      def user_agent
        USER_AGENTS.sample
      end

      def referrer
        REFERRERS.sample
      end

      def response_size
        # Realistic file sizes based on resource type
        case resource
        when /\.(css|js)$/
          rand(5000..50000)
        when /\.(png|jpg|jpeg|gif)$/
          rand(10000..500000)
        when /\.(pdf|zip)$/
          rand(100000..5000000)
        when /\.(ico)$/
          rand(1000..5000)
        when /\.(html|php)$/
          rand(2000..20000)
        else
          rand(1000..10000)
        end
      end

      def error_type
        ERROR_TYPES.keys.sample
      end

      def error_message
        ERROR_MESSAGES.sample
      end

      def apache_module
        MODULES.sample
      end

      def generate_log_entry
        case rand(100)
        when 0..85
          # Access logs (85%)
          [generate_access_log]
        when 86..95
          # Error logs (10%)
          [generate_error_log]
        else
          # SSL/Module logs (5%)
          [generate_ssl_or_module_log]
        end
      end

      private

      def generate_access_log
        # Common Log Format: host ident authuser timestamp "request" status size
        # Combined Log Format adds: "referer" "user-agent"
        
        ip = LogUtils.ip_address
        ident = '-' # Usually not used
        authuser = rand < 0.05 ? "user#{rand(100)}" : '-' # 5% chance of authenticated user
        timestamp = generate_apache_timestamp
        method = http_method
        path = resource
        protocol = 'HTTP/1.1'
        status = status_code
        size = response_size
        referer = referrer
        user_agent = self.user_agent
        
        # Color the different parts
        status_color = status_color(status)
        method_color = case method
                       when 'GET' then Colors::GREEN
                       when 'POST' then Colors::BLUE
                       when 'PUT', 'PATCH' then Colors::YELLOW
                       when 'DELETE' then Colors::RED
                       else Colors::GRAY
                       end
        
        "#{Colors::CYAN}#{ip}#{Colors::RESET} #{ident} #{authuser} " \
        "#{Colors::GRAY}[#{timestamp}]#{Colors::RESET} " \
        "\"#{method_color}#{method}#{Colors::RESET} #{path} #{protocol}\" " \
        "#{status_color}#{status}#{Colors::RESET} #{size} " \
        "\"#{Colors::MAGENTA}#{referer}#{Colors::RESET}\" " \
        "\"#{Colors::GRAY}#{user_agent}#{Colors::RESET}\""
      end

      def generate_error_log
        # Apache Error Log Format: [timestamp] [level] [pid] [client IP] message
        
        timestamp = generate_apache_timestamp
        level_key = error_type
        level_data = ERROR_TYPES[level_key]
        pid = rand(1000..9999)
        client_ip = LogUtils.ip_address
        message = error_message
        
        "#{Colors::GRAY}[#{timestamp}]#{Colors::RESET} " \
        "#{level_data[:color]}#{level_data[:label]}#{Colors::RESET} " \
        "#{Colors::GRAY}[pid #{pid}]#{Colors::RESET} " \
        "#{Colors::CYAN}[client #{client_ip}]#{Colors::RESET} " \
        "#{message}"
      end

      def generate_ssl_or_module_log
        case rand(3)
        when 0
          generate_ssl_log
        when 1
          generate_module_log
        else
          generate_startup_log
        end
      end

      def generate_ssl_log
        timestamp = generate_apache_timestamp
        client_ip = LogUtils.ip_address
        
        ssl_messages = [
          "SSL handshake successful",
          "SSL handshake failed: certificate verify failed",
          "SSL connection established",
          "SSL renegotiation failed",
          "SSL certificate expired"
        ]
        
        "#{Colors::GRAY}[#{timestamp}]#{Colors::RESET} " \
        "#{Colors::YELLOW}[ssl:info]#{Colors::RESET} " \
        "#{Colors::GRAY}[pid #{rand(1000..9999)}]#{Colors::RESET} " \
        "#{Colors::CYAN}[client #{client_ip}:#{rand(30000..65000)}]#{Colors::RESET} " \
        "#{ssl_messages.sample}"
      end

      def generate_module_log
        timestamp = generate_apache_timestamp
        module_name = apache_module
        
        module_messages = [
          "#{module_name} loaded successfully",
          "#{module_name} configuration updated",
          "#{module_name} blocked suspicious request",
          "#{module_name} cache hit for #{resource}",
          "#{module_name} processing request"
        ]
        
        "#{Colors::GRAY}[#{timestamp}]#{Colors::RESET} " \
        "#{Colors::BLUE}[#{module_name}:info]#{Colors::RESET} " \
        "#{Colors::GRAY}[pid #{rand(1000..9999)}]#{Colors::RESET} " \
        "#{module_messages.sample}"
      end

      def generate_startup_log
        timestamp = generate_apache_timestamp
        
        startup_messages = [
          "Apache/2.4.41 (Ubuntu) configured -- resuming normal operations",
          "Server built: 2021-06-10T08:01:13",
          "Command line: '/usr/sbin/apache2 -D FOREGROUND'",
          "mpm_prefork: module loaded",
          "Loaded DSO modules:",
          "Apache configured with worker MPM"
        ]
        
        "#{Colors::GRAY}[#{timestamp}]#{Colors::RESET} " \
        "#{Colors::GREEN}[mpm_prefork:notice]#{Colors::RESET} " \
        "#{Colors::GRAY}[pid #{rand(1000..9999)}]#{Colors::RESET} " \
        "#{startup_messages.sample}"
      end

      def generate_apache_timestamp
        # Apache timestamp format: [day/month/year:hour:minute:second timezone]
        time = Time.now - rand(86400) # Random time within last 24 hours
        time.strftime('%d/%b/%Y:%H:%M:%S %z')
      end
    end
  end
end