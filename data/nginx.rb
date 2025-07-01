# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Nginx
    # HTTP methods
    HTTP_METHODS = %w[GET POST PUT DELETE PATCH HEAD OPTIONS]
    
    # Common paths and endpoints
    PATHS = [
      '/',
      '/index.html',
      '/api/v1/users',
      '/api/v1/users/123',
      '/api/v1/products',
      '/api/v1/products/search?q=laptop',
      '/api/v1/orders',
      '/api/v1/auth/login',
      '/api/v1/auth/logout',
      '/api/v1/auth/refresh',
      '/admin',
      '/admin/dashboard',
      '/admin/users',
      '/admin/reports',
      '/static/css/main.css',
      '/static/js/app.js',
      '/static/js/vendor.js',
      '/images/logo.png',
      '/images/banner.jpg',
      '/images/products/item-1234.jpg',
      '/favicon.ico',
      '/robots.txt',
      '/sitemap.xml',
      '/health',
      '/metrics',
      '/.well-known/acme-challenge/abc123',
      '/wp-admin',
      '/wp-login.php',
      '/xmlrpc.php',
      '/.git/config',
      '/.env',
      '/backup.sql',
      '/test.php',
      '/phpinfo.php'
    ]
    
    # HTTP status codes with weights
    STATUS_CODES = {
      200 => 0.60,  # OK - most common
      201 => 0.02,  # Created
      204 => 0.02,  # No Content
      301 => 0.03,  # Moved Permanently
      302 => 0.03,  # Found
      304 => 0.08,  # Not Modified
      400 => 0.02,  # Bad Request
      401 => 0.02,  # Unauthorized
      403 => 0.02,  # Forbidden
      404 => 0.10,  # Not Found - second most common
      405 => 0.01,  # Method Not Allowed
      422 => 0.01,  # Unprocessable Entity
      429 => 0.01,  # Too Many Requests
      500 => 0.02,  # Internal Server Error
      502 => 0.005, # Bad Gateway
      503 => 0.005, # Service Unavailable
      504 => 0.01   # Gateway Timeout
    }
    
    # Status code colors
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
      429 => Colors::BRIGHT_YELLOW,
      500 => Colors::RED,
      502 => Colors::RED,
      503 => Colors::RED,
      504 => Colors::RED
    }
    
    # User agents
    USER_AGENTS = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15',
      'Mozilla/5.0 (iPhone; CPU iPhone OS 14_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1',
      'Mozilla/5.0 (Android 11; Mobile; rv:89.0) Gecko/89.0 Firefox/89.0',
      'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
      'Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)',
      'curl/7.68.0',
      'PostmanRuntime/7.28.0',
      'python-requests/2.25.1',
      'axios/0.21.1',
      'Go-http-client/1.1',
      '-' # Empty user agent
    ]
    
    # Referrers
    REFERRERS = [
      '-',
      'https://www.google.com/',
      'https://www.google.com/search?q=example+product',
      'https://www.bing.com/',
      'https://www.facebook.com/',
      'https://t.co/abc123',
      'https://www.reddit.com/r/programming',
      'https://example.com/',
      'https://example.com/products',
      'https://example.com/blog/article-123',
      'http://localhost:3000/',
      'https://analytics.example.com/dashboard'
    ]
    
    # Error log levels
    ERROR_LEVELS = {
      'debug' => { weight: 0.05, color: Colors::GRAY },
      'info' => { weight: 0.15, color: Colors::GREEN },
      'notice' => { weight: 0.10, color: Colors::CYAN },
      'warn' => { weight: 0.30, color: Colors::YELLOW },
      'error' => { weight: 0.30, color: Colors::RED },
      'crit' => { weight: 0.08, color: Colors::BRIGHT_RED },
      'alert' => { weight: 0.015, color: Colors::BRIGHT_RED },
      'emerg' => { weight: 0.005, color: Colors::BRIGHT_MAGENTA }
    }
    
    # Error messages by level
    ERROR_MESSAGES = {
      'debug' => [
        'accept4() failed (24: Too many open files)',
        'epoll_wait() reported that client prematurely closed connection',
        'malloc: %d bytes aligned to %d',
        'posix_memalign: %d:%d @%p',
        'http script var: "%s"'
      ],
      'info' => [
        'client %s closed keepalive connection',
        'client timed out (110: Connection timed out) while waiting for request',
        '*%d client prematurely closed connection',
        'Using %d worker processes',
        'signal process started'
      ],
      'notice' => [
        'signal 15 (SIGTERM) received, exiting',
        'exiting',
        'exit',
        'reconfiguring',
        'reopening logs'
      ],
      'warn' => [
        '*%d client sent invalid method while reading client request line',
        'client sent plain HTTP request to HTTPS port while reading client request line',
        '*%d no live upstreams while connecting to upstream',
        'upstream server temporarily disabled while reading response header from upstream',
        'conflicting server name "%s" on %s:%d, ignored'
      ],
      'error' => [
        '*%d open() "%s" failed (2: No such file or directory)',
        '*%d connect() failed (111: Connection refused) while connecting to upstream',
        '*%d upstream timed out (110: Connection timed out) while reading response header from upstream',
        '*%d recv() failed (104: Connection reset by peer) while reading response header from upstream',
        '*%d directory index of "%s" is forbidden',
        '*%d SSL_do_handshake() failed (SSL: error:%08lX:%s:%s:%s) while SSL handshaking',
        '*%d access forbidden by rule'
      ],
      'crit' => [
        '*%d SSL_write() failed (SSL: error:%08lX:%s:%s:%s) while sending response to client',
        'accept4() failed (24: Too many open files)',
        '*%d socket() failed (24: Too many open files) while connecting to upstream',
        'SSL_CTX_use_PrivateKey_file("%s") failed',
        'open() "%s" failed (24: Too many open files)'
      ],
      'alert' => [
        'could not open error log file: open() "%s" failed',
        'unable to set up signal handler',
        'socketpair() failed while spawning "%s"'
      ],
      'emerg' => [
        'bind() to %s:%d failed (98: Address already in use)',
        'still could not bind()',
        'open() "%s" failed (13: Permission denied)',
        'BIO_new_file("%s") failed',
        'configuration file %s test failed'
      ]
    }
    
    # Upstream servers
    UPSTREAMS = [
      'backend_app',
      'api_servers',
      'static_servers',
      'websocket_backend',
      'auth_service',
      'payment_gateway',
      'search_cluster'
    ]
    
    # Virtual hosts
    VHOSTS = [
      'example.com',
      'www.example.com',
      'api.example.com',
      'admin.example.com',
      'static.example.com',
      'blog.example.com',
      'shop.example.com'
    ]
    
    class << self
      def generate_log_entry
        # 80% access logs, 20% error logs
        if rand < 0.8
          generate_access_log
        else
          generate_error_log
        end
      end
      
      private
      
      def generate_access_log
        ip = LogUtils.ip_address
        timestamp = Time.now.strftime('%d/%b/%Y:%H:%M:%S +0000')
        method = HTTP_METHODS.sample
        path = PATHS.sample
        protocol = 'HTTP/1.1'
        status = weighted_status_code
        bytes = status == 304 ? 0 : rand(100..100000)
        referrer = REFERRERS.sample
        user_agent = USER_AGENTS.sample
        request_time = (rand * 2).round(3) # 0-2 seconds
        upstream_time = status >= 500 ? '-' : (rand * 1.5).round(3)
        
        # Apply colors
        status_color = STATUS_CODE_COLORS[status] || Colors::RESET
        method_color = case method
                      when 'GET' then Colors::GREEN
                      when 'POST' then Colors::YELLOW
                      when 'PUT', 'PATCH' then Colors::BLUE
                      when 'DELETE' then Colors::RED
                      else Colors::CYAN
                      end
        
        # Nginx combined log format with additional fields
        # IP - - [timestamp] "METHOD /path HTTP/1.1" status bytes "referrer" "user-agent" request_time upstream_time
        "#{Colors::CYAN}#{ip}#{Colors::RESET} - - [#{timestamp}] \"#{method_color}#{method}#{Colors::RESET} #{path} #{protocol}\" #{status_color}#{status}#{Colors::RESET} #{bytes} \"#{referrer}\" \"#{user_agent}\" #{Colors::GRAY}#{request_time} #{upstream_time}#{Colors::RESET}"
      end
      
      def generate_error_log
        timestamp = Time.now.strftime('%Y/%m/%d %H:%M:%S')
        level, level_info = weighted_error_level
        pid = rand(1000..65535)
        tid = rand(100..999)
        cid = rand(1000..9999)
        
        # Get appropriate message for the level
        messages = ERROR_MESSAGES[level]
        message_template = messages.sample
        
        # Fill in message template
        message = case message_template
                  when /%d/
                    # Replace %d with numbers
                    message_template.gsub('%d', rand(1..9999).to_s)
                  when /%s/
                    # Replace %s with appropriate strings
                    case message_template
                    when /open\(\).*failed/
                      message_template.gsub('%s', "/var/www/html#{PATHS.sample}")
                    when /conflicting server name/
                      message_template.gsub('%s', [VHOSTS.sample, '0.0.0.0', rand(80..443).to_s])
                    when /directory index of/
                      message_template.gsub('%s', "/var/www/html#{PATHS.select { |p| p.end_with?('/') }.sample}")
                    when /SSL_CTX_use_PrivateKey_file/
                      message_template.gsub('%s', '/etc/nginx/ssl/cert.key')
                    when /configuration file.*test failed/
                      message_template.gsub('%s', '/etc/nginx/nginx.conf')
                    when /bind\(\) to/
                      message_template.gsub('%s', '0.0.0.0').gsub('%d', %w[80 443 8080].sample)
                    when /could not open error log/
                      message_template.gsub('%s', '/var/log/nginx/error.log')
                    when /spawning/
                      message_template.gsub('%s', 'worker process')
                    when /BIO_new_file/
                      message_template.gsub('%s', '/etc/nginx/ssl/cert.crt')
                    when /http script var/
                      message_template.gsub('%s', %w[$remote_addr $http_host $request_uri].sample)
                    else
                      message_template
                    end
                  when /%08lX/
                    # SSL error format
                    message_template.gsub('%08lX', sprintf('%08X', rand(0x10000000..0xFFFFFFFF)))
                                   .gsub('%s', ['error', 'SSL routines', 'ssl3_read_bytes', 'sslv3 alert certificate expired'])
                  else
                    message_template
                  end
        
        # Add connection info for client-related errors
        client_info = if message.include?('client') || message.include?('*')
                       ", client: #{LogUtils.ip_address}, server: #{VHOSTS.sample}, request: \"#{HTTP_METHODS.sample} #{PATHS.sample} HTTP/1.1\""
                     elsif message.include?('upstream')
                       ", client: #{LogUtils.ip_address}, server: #{VHOSTS.sample}, request: \"#{HTTP_METHODS.sample} #{PATHS.sample} HTTP/1.1\", upstream: \"http://#{UPSTREAMS.sample}\", host: \"#{VHOSTS.sample}\""
                     else
                       ''
                     end
        
        # Apply color to level
        level_color = level_info[:color]
        
        # Nginx error log format
        # YYYY/MM/DD HH:MM:SS [level] PID#TID: *CID message
        "#{timestamp} [#{level_color}#{level}#{Colors::RESET}] #{pid}##{tid}: #{Colors::YELLOW}*#{cid}#{Colors::RESET} #{message}#{client_info}"
      end
      
      def weighted_status_code
        rand_val = rand
        cumulative = 0
        
        STATUS_CODES.each do |code, weight|
          cumulative += weight
          return code if rand_val <= cumulative
        end
        
        200 # fallback
      end
      
      def weighted_error_level
        rand_val = rand
        cumulative = 0
        
        ERROR_LEVELS.each do |level, info|
          cumulative += info[:weight]
          return [level, info] if rand_val <= cumulative
        end
        
        ['error', ERROR_LEVELS['error']] # fallback
      end
    end
  end
end