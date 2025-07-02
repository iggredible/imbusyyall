# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Rfc5424
    # RFC5424 Facilities (same as RFC3164)
    FACILITIES = {
      0 => 'kern',     # kernel messages
      1 => 'user',     # user-level messages
      2 => 'mail',     # mail system
      3 => 'daemon',   # system daemons
      4 => 'auth',     # security/authorization messages
      5 => 'syslog',   # messages generated internally by syslogd
      6 => 'lpr',      # line printer subsystem
      7 => 'news',     # network news subsystem
      8 => 'uucp',     # UUCP subsystem
      9 => 'cron',     # clock daemon
      10 => 'authpriv', # security/authorization messages (private)
      11 => 'ftp',     # FTP daemon
      16 => 'local0',  # local use 0
      17 => 'local1',  # local use 1
      18 => 'local2',  # local use 2
      19 => 'local3',  # local use 3
      20 => 'local4',  # local use 4
      21 => 'local5',  # local use 5
      22 => 'local6',  # local use 6
      23 => 'local7'   # local use 7
    }

    # RFC5424 Severities
    SEVERITIES = {
      0 => 'Emergency',     # system is unusable
      1 => 'Alert',        # action must be taken immediately
      2 => 'Critical',     # critical conditions
      3 => 'Error',        # error conditions
      4 => 'Warning',      # warning conditions
      5 => 'Notice',       # normal but significant condition
      6 => 'Informational', # informational messages
      7 => 'Debug'         # debug-level messages
    }

    # Severity colors for terminal output
    SEVERITY_COLORS = {
      'Emergency' => Colors::BRIGHT_RED,
      'Alert' => Colors::BRIGHT_RED,
      'Critical' => Colors::RED,
      'Error' => Colors::RED,
      'Warning' => Colors::YELLOW,
      'Notice' => Colors::CYAN,
      'Informational' => Colors::GREEN,
      'Debug' => Colors::GRAY
    }

    # Common application names for different facilities
    APP_NAMES = {
      'kern' => ['kernel', 'vmunix', 'linux'],
      'user' => ['login', 'su', 'sudo', 'sshd', 'systemd-logind'],
      'mail' => ['postfix', 'sendmail', 'dovecot', 'exim', 'smtp'],
      'daemon' => ['systemd', 'init', 'chronyd', 'NetworkManager', 'dbus'],
      'auth' => ['sshd', 'sudo', 'login', 'passwd', 'su', 'pam'],
      'syslog' => ['rsyslogd', 'syslog-ng', 'journald'],
      'lpr' => ['lpd', 'cupsd', 'cups-browsed'],
      'news' => ['innd', 'nnrpd', 'leafnode'],
      'uucp' => ['uucico', 'uuxqt'],
      'cron' => ['cron', 'crond', 'anacron', 'systemd-timer'],
      'authpriv' => ['sshd', 'sudo', 'su', 'polkitd'],
      'ftp' => ['vsftpd', 'proftpd', 'pure-ftpd', 'ftpd'],
      'local0' => ['nginx', 'apache2', 'httpd', 'caddy'],
      'local1' => ['haproxy', 'keepalived', 'varnish', 'traefik'],
      'local2' => ['postgresql', 'mysql', 'mariadb', 'mongodb'],
      'local3' => ['redis', 'memcached', 'cassandra', 'etcd'],
      'local4' => ['docker', 'containerd', 'kubelet', 'podman'],
      'local5' => ['elasticsearch', 'logstash', 'kibana', 'beats'],
      'local6' => ['rabbitmq', 'kafka', 'nats', 'mosquitto'],
      'local7' => ['app', 'custom', 'myapp', 'api-server']
    }

    # Sample structured data elements
    STRUCTURED_DATA = {
      'timeQuality' => {
        'tzKnown' => ['0', '1'],
        'isSynced' => ['0', '1'],
        'syncAccuracy' => -> { rand(100..999999).to_s }
      },
      'origin' => {
        'ip' => -> { LogUtils.ip_address },
        'enterpriseId' => ['32473', '8072', '2021', '13335'],
        'software' => ['rsyslogd', 'syslog-ng', 'systemd-journald', 'custom-logger'],
        'swVersion' => ['8.2102.0', '3.35.1', '249.11', '1.0.0']
      },
      'meta' => {
        'sequenceId' => -> { rand(1..999999).to_s },
        'sysUpTime' => -> { rand(100..999999).to_s },
        'language' => ['en-US', 'en-GB', 'de-DE', 'fr-FR']
      },
      'exampleSDID@32473' => {
        'iut' => ['3', '4', '5'],
        'eventSource' => ['Application', 'System', 'Security'],
        'eventID' => -> { rand(1000..9999).to_s }
      }
    }

    # Sample messages by facility (more modern/structured format)
    MESSAGES = {
      'kern' => [
        'Out of memory: Killed process %d (%s) total-vm:%dkB, anon-rss:%dkB, file-rss:%dkB',
        'TCP: Possible SYN flooding on port %d. Sending cookies. Check SNMP counters.',
        'EXT4-fs (%s): mounted filesystem with ordered data mode. Opts: %s. Quota mode: %s.',
        'netfilter: nf_conntrack: table full, dropping packet from %s to %s',
        'CPU%d: Package temperature above threshold, cpu clock throttled (total events = %d)',
        'xhci_hcd %s: USB %s device detected on port %d',
        'IPv6: ADDRCONF(NETDEV_CHANGE): %s: link becomes ready'
      ],
      'user' => [
        'New session %d of user %s started for service %s',
        'Session %d logged out. Waiting for processes to exit.',
        'Failed to authenticate user %s from %s: %s',
        'User %s changed password successfully',
        'Created new user %s (UID: %d, GID: %d, Home: %s)',
        'User %s logged in successfully from %s using %s authentication'
      ],
      'mail' => [
        'Message %s from <%s> accepted for delivery',
        'Delivered message %s to <%s> via %s[%s] (status=%s)',
        'Connection from %s[%s] established (TLS: %s)',
        'Connection from %s[%s] lost (duration=%ss, messages=%d)',
        'SASL authentication failed for user %s from %s[%s]: %s',
        'Rejected message from %s[%s] to <%s>: %s',
        'Queue manager: started delivery of %s (size=%d bytes)'
      ],
      'daemon' => [
        'Started %s - %s',
        'Stopped %s - %s (Result: %s)',
        'Reloading %s configuration files',
        'Unit %s entered failed state with result %s',
        'Detected new device: %s (%s)',
        'Reached target %s - %s',
        'Dependency failed for %s - %s'
      ],
      'auth' => [
        'Accepted publickey for %s from %s port %d ssh2: %s %s',
        'Failed password for %s from %s port %d ssh2',
        'Invalid user %s from %s port %d',
        'Session opened for user %s (uid=%d) by process %d',
        'Session closed for user %s',
        'Authentication failure for user %s from %s (reason: %s)',
        'Server listening on %s port %d protocol %s'
      ],
      'cron' => [
        'Job "%s" started for user %s (PID: %d)',
        'Job "%s" completed for user %s (exit code: %d, duration: %ds)',
        'Reloaded configuration from %s',
        'Skipping job "%s" for user %s (system load too high)',
        'Error executing job "%s" for user %s: %s',
        'Next execution of "%s" scheduled for %s',
        'Removed job "%s" for user %s'
      ],
      'local0' => [ # web servers
        '%s "%s %s %s" %d %d "%s" "%s" rt=%s uct="%s" uht="%s" urt="%s"',
        'SSL handshake failed for %s:%d (error: %s)',
        'Backend connection failed to %s:%d (error: %s)',
        'Rate limit exceeded for client %s (limit: %d req/s)',
        'Configuration reloaded successfully (workers: %d)',
        'Worker process %d exited with code %d',
        'Upstream %s marked as down after %d failed attempts'
      ],
      'local2' => [ # databases
        'Connection authenticated: user=%s database=%s client=%s:%d ssl=%s',
        'Query completed: duration=%sms user=%s database=%s query="%s"',
        'Checkpoint completed: wrote %d buffers (%s); sync time=%ss, total time=%ss',
        'Replication lag detected: %s behind primary',
        'Index created: %s.%s (size: %s, time: %ss)',
        'Vacuum completed on %s.%s: removed %d dead tuples',
        'Connection pool exhausted for database %s (max_connections=%d)'
      ],
      'local4' => [ # containers
        'Container %s started (image: %s, id: %s)',
        'Container %s stopped (exit_code: %d, runtime: %s)',
        'Image %s pulled successfully (size: %s, layers: %d)',
        'Volume %s mounted to container %s at %s',
        'Network %s connected to container %s (ip: %s)',
        'Health check failed for container %s (consecutive_failures: %d)',
        'Resource limit exceeded for container %s (type: %s, limit: %s)'
      ]
    }

    # Common hostnames
    HOSTNAMES = [
      'prod-web-01', 'prod-web-02', 'prod-app-01', 'prod-app-02',
      'prod-db-01', 'prod-db-02', 'prod-cache-01', 'prod-queue-01',
      'staging-web-01', 'staging-app-01', 'staging-db-01',
      'dev-all-01', 'monitoring-01', 'logging-01', 'backup-01'
    ]

    class << self
      def generate_log_entry
        facility_num = FACILITIES.keys.sample
        facility_name = FACILITIES[facility_num]
        severity_num = weighted_severity
        severity_name = SEVERITIES[severity_num]

        # Calculate priority (facility * 8 + severity)
        priority = facility_num * 8 + severity_num

        # RFC5424 timestamp with microseconds and timezone
        timestamp = Time.now.strftime('%Y-%m-%dT%H:%M:%S.%6N%:z')

        # Get hostname
        hostname = HOSTNAMES.sample

        # Get app name and process ID
        app_names = APP_NAMES[facility_name] || ['app']
        app_name = app_names.sample
        proc_id = rand(100..65535).to_s

        # Generate message ID
        msg_id = generate_msg_id(facility_name)

        # Generate structured data
        structured_data = generate_structured_data

        # Get appropriate message
        messages = MESSAGES[facility_name] || MESSAGES['daemon']
        message_template = messages.sample
        message = fill_message_template(message_template, facility_name)

        # Apply color
        severity_color = SEVERITY_COLORS[severity_name]

        # RFC5424 format: <priority>version timestamp hostname app-name procid msgid structured-data msg
        # Adding colors for readability
        "#{Colors::GRAY}<#{priority}>1#{Colors::RESET} #{Colors::BLUE}#{timestamp}#{Colors::RESET} #{Colors::CYAN}#{hostname}#{Colors::RESET} #{Colors::YELLOW}#{app_name}#{Colors::RESET} #{Colors::GRAY}#{proc_id}#{Colors::RESET} #{Colors::MAGENTA}#{msg_id}#{Colors::RESET} #{Colors::GRAY}#{structured_data}#{Colors::RESET} #{severity_color}#{message}#{Colors::RESET}"
      end

      private

      def weighted_severity
        # Weight towards info/notice with occasional warnings and rare errors
        weights = {
          0 => 0.001, # Emergency
          1 => 0.001, # Alert
          2 => 0.008, # Critical
          3 => 0.04,  # Error
          4 => 0.15,  # Warning
          5 => 0.30,  # Notice
          6 => 0.40,  # Informational
          7 => 0.10   # Debug
        }

        rand_val = rand
        cumulative = 0

        weights.each do |severity, weight|
          cumulative += weight
          return severity if rand_val <= cumulative
        end

        6 # default to informational
      end

      def generate_msg_id(facility)
        case facility
        when 'kern'
          %w[KERNEL_OOM KERNEL_TCP KERNEL_FS KERNEL_NET KERNEL_CPU KERNEL_USB].sample
        when 'auth', 'authpriv'
          %w[AUTH_SUCCESS AUTH_FAILURE SESSION_OPEN SESSION_CLOSE AUTH_KEY].sample
        when 'mail'
          %w[MAIL_ACCEPT MAIL_DELIVER MAIL_CONNECT MAIL_REJECT MAIL_QUEUE].sample
        when 'cron'
          %w[CRON_START CRON_FINISH CRON_ERROR CRON_RELOAD CRON_SKIP].sample
        when 'local0'
          %w[HTTP_ACCESS HTTP_ERROR SSL_ERROR BACKEND_ERROR CONFIG_RELOAD].sample
        when 'local2'
          %w[DB_CONNECT DB_QUERY DB_CHECKPOINT DB_VACUUM DB_REPLICATION].sample
        when 'local4'
          %w[CONTAINER_START CONTAINER_STOP IMAGE_PULL VOLUME_MOUNT HEALTH_CHECK].sample
        else
          %w[ID001 ID002 ID003 ID004 ID005].sample
        end
      end

      def generate_structured_data
        return '-' if rand < 0.3 # 30% chance of no structured data

        num_elements = rand(1..3)
        elements = []

        num_elements.times do
          sd_name = STRUCTURED_DATA.keys.sample
          params = STRUCTURED_DATA[sd_name]
          
          param_pairs = params.map do |key, value|
            val = value.is_a?(Array) ? value.sample : value.call
            "#{key}=\"#{val}\""
          end.join(' ')

          elements << "[#{sd_name} #{param_pairs}]"
        end

        elements.join
      end

      def fill_message_template(template, facility)
        # Return template as-is if it has no format specifiers
        return template unless template.include?('%')

        begin
          replacements = case facility
          when 'kern'
            case template
            when /Out of memory/
              [rand(1000..65535), %w[chrome firefox node ruby python java mysqld postgres].sample, 
               rand(100000..9999999), rand(50000..5000000), rand(10000..1000000)]
            when /SYN flooding/
              [%w[80 443 22 3306 5432 6379 8080 9000].sample]
            when /mounted filesystem/
              ["/dev/nvme#{rand(0..3)}n#{rand(1..2)}p#{rand(1..5)}", 
               %w[errors=remount-ro relatime noatime discard].sample(2).join(','),
               %w[none writeback strict].sample]
            when /netfilter/
              [LogUtils.ip_address, LogUtils.ip_address]
            when /Package temperature/
              [rand(0..7), rand(100..9999)]
            when /USB.*device/
              ["0000:00:14.#{rand(0..3)}", %w[2.0 3.0 3.1 3.2].sample, rand(1..12)]
            when /IPv6.*NETDEV_CHANGE/
              ["enp#{rand(0..3)}s#{rand(0..9)}"]
            else
              []
            end
          when 'user'
            case template
            when /New session.*started/
              [rand(1000..9999), %w[root admin deploy jenkins gitlab k8s prometheus].sample,
               %w[ssh gdm-password systemd-user cron].sample]
            when /Session.*logged out/
              [rand(1000..9999)]
            when /Failed to authenticate/
              [%w[admin test user guest invalid root].sample, LogUtils.ip_address,
               %w[invalid_password account_locked two_factor_required].sample]
            when /changed password/
              [%w[admin user1 deploy jenkins developer].sample]
            when /Created new user/
              ["user#{rand(1000..9999)}", rand(1000..9999), rand(1000..9999), 
               "/home/user#{rand(1000..9999)}"]
            when /logged in successfully/
              [%w[admin deploy jenkins root developer].sample, LogUtils.ip_address,
               %w[password publickey kerberos oauth2].sample]
            else
              []
            end
          when 'mail'
            case template
            when /Message.*accepted/
              [SecureRandom.uuid[0..11].upcase, "sender#{rand(100..999)}@example.com"]
            when /Delivered message/
              [SecureRandom.uuid[0..11].upcase, "recipient#{rand(100..999)}@example.com",
               %w[smtp lmtp local virtual].sample, LogUtils.ip_address, "sent (250 OK)"]
            when /Connection.*established/
              [%w[mail.gmail.com mail.outlook.com smtp.sendgrid.net].sample, 
               LogUtils.ip_address, %w[TLSv1.2 TLSv1.3 none].sample]
            when /Connection.*lost/
              [%w[unknown mail.example.com].sample, LogUtils.ip_address,
               "#{rand(1..300)}.#{rand(0..999)}", rand(0..50)]
            when /SASL authentication failed/
              ["user#{rand(100..999)}", %w[unknown mail.example.com].sample, 
               LogUtils.ip_address, %w[invalid_credentials mechanism_unavailable].sample]
            when /Rejected message/
              [%w[unknown spammer.example.com].sample, LogUtils.ip_address,
               "spam#{rand(100..999)}@example.com", 
               %w[spam_detected invalid_recipient relay_denied virus_found].sample]
            when /Queue manager/
              [SecureRandom.uuid[0..11].upcase, rand(1000..1000000)]
            else
              []
            end
          when 'cron'
            case template
            when /Job.*started.*PID/
              [%w[backup db-maintenance log-rotation cache-clear report-generate].sample,
               %w[root backup www-data postgres mysql].sample, rand(1000..65535)]
            when /Job.*completed.*exit code/
              [%w[backup db-maintenance log-rotation cache-clear report-generate].sample,
               %w[root backup www-data postgres mysql].sample, [0, 0, 0, 1, 2].sample, rand(1..3600)]
            when /Reloaded configuration/
              ['/etc/cron.d/app-tasks']
            when /Skipping job/
              [%w[heavy-report full-backup analyze-logs].sample, %w[root backup].sample]
            when /Error executing/
              [%w[backup sync-data generate-report].sample, %w[root www-data].sample,
               %w[permission_denied file_not_found network_timeout].sample]
            when /scheduled for/
              [%w[daily-backup weekly-report monthly-cleanup].sample,
               (Time.now + rand(3600..86400)).strftime('%Y-%m-%d %H:%M:%S %Z')]
            when /Removed job/
              [%w[old-task deprecated-job temp-script].sample, %w[root admin].sample]
            else
              []
            end
          when 'local0' # Modern web server logs
            case template
            when /rt=.*uct=/
              [LogUtils.ip_address, %w[GET POST PUT DELETE PATCH HEAD OPTIONS].sample,
               ['/api/v2/users', '/api/v2/products', '/api/v2/orders', '/health', 
                '/metrics', '/graphql', '/api/v2/auth/login', '/api/v2/search'].sample,
               'HTTP/2.0', [200, 201, 204, 301, 302, 400, 401, 403, 404, 429, 500, 502, 503].sample,
               rand(100..500000), %w[- https://app.example.com/dashboard].sample,
               'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
               "#{rand(0..5)}.#{rand(0..999)}", "#{rand(0..2)}.#{rand(0..999)}",
               "#{rand(0..2)}.#{rand(0..999)}", "#{rand(0..3)}.#{rand(0..999)}"]
            when /SSL handshake failed/
              [LogUtils.ip_address, rand(1024..65535), 
               %w[protocol_version cipher_mismatch certificate_unknown certificate_expired].sample]
            when /Backend connection failed/
              ["backend-#{rand(1..5)}.internal", [8080, 3000, 5000, 9000].sample,
               %w[connection_refused timeout no_route_to_host].sample]
            when /Rate limit/
              [LogUtils.ip_address, [10, 100, 1000].sample]
            when /Configuration reloaded/
              [rand(2..16)]
            when /Worker process.*exited/
              [rand(1000..65535), [0, 1, 139, 255].sample]
            when /Upstream.*marked/
              ["api-backend-#{rand(1..5)}", rand(3..10)]
            else
              []
            end
          when 'local2' # Modern database logs
            case template
            when /Connection authenticated/
              [%w[app_user read_user admin_user analytics_user].sample,
               %w[production staging analytics reporting].sample,
               LogUtils.ip_address, rand(1024..65535), %w[on off required].sample]
            when /Query completed/
              ["#{rand(0..999)}.#{rand(0..999)}", %w[app_user read_user].sample,
               %w[production analytics].sample,
               ['SELECT * FROM users WHERE status = $1', 
                'INSERT INTO orders (user_id, total) VALUES ($1, $2)',
                'UPDATE products SET stock = stock - $1 WHERE id = $2',
                'DELETE FROM sessions WHERE expires_at < NOW()'].sample]
            when /Checkpoint completed/
              [rand(1000..50000), "#{rand(1..999)}MB", "#{rand(0..30)}.#{rand(0..999)}",
               "#{rand(1..60)}.#{rand(0..999)}"]
            when /Replication lag/
              ["#{rand(1..300)}s"]
            when /Index created/
              [%w[public app analytics].sample, %w[users_email_idx orders_created_idx products_sku_idx].sample,
               "#{rand(1..999)}MB", "#{rand(1..300)}.#{rand(0..999)}"]
            when /Vacuum completed/
              [%w[public app].sample, %w[users orders products sessions].sample, rand(1000..1000000)]
            when /Connection pool/
              [%w[production analytics].sample, [100, 200, 500].sample]
            else
              []
            end
          when 'local4' # Container logs
            case template
            when /Container.*started.*image/
              ["app-#{SecureRandom.hex(6)}", 
               %w[myapp/api:v2.1.0 nginx:1.21-alpine postgres:14.2 redis:7-alpine].sample,
               SecureRandom.hex(32)[0..11]]
            when /Container.*stopped.*exit_code/
              ["app-#{SecureRandom.hex(6)}", [0, 0, 0, 1, 137, 143].sample,
               "#{rand(1..48)}h#{rand(0..59)}m#{rand(0..59)}s"]
            when /Image.*pulled.*layers/
              [%w[myapp/api:v2.1.0 node:18-alpine python:3.11-slim ubuntu:22.04].sample,
               "#{rand(10..500)}MB", rand(3..20)]
            when /Volume.*mounted/
              ["data-#{SecureRandom.hex(6)}", "app-#{SecureRandom.hex(6)}",
               %w[/data /var/lib/mysql /var/lib/postgresql /app/uploads].sample]
            when /Network.*connected.*ip/
              [%w[frontend backend database internal].sample, "app-#{SecureRandom.hex(6)}",
               "172.#{rand(16..31)}.#{rand(0..255)}.#{rand(2..254)}"]
            when /Health check failed/
              ["app-#{SecureRandom.hex(6)}", rand(1..10)]
            when /Resource limit/
              ["app-#{SecureRandom.hex(6)}", %w[memory cpu disk_io].sample,
               %w[512Mi 1Gi 2Gi 100m 500m 1000m].sample]
            else
              []
            end
          else
            # Generic replacements
            template.scan(/%[sd]/).size.times.map do
              rand < 0.5 ? rand(1..1000).to_s : %w[active inactive running stopped failed].sample
            end
          end

          # Apply replacements if any exist
          if replacements && !replacements.empty?
            template % replacements
          else
            template
          end
        rescue ArgumentError => e
          # If template formatting fails, return a generic message
          "#{facility} process event occurred"
        end
      end
    end
  end
end