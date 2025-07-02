# frozen_string_literal: true

require 'securerandom'
require_relative '../lib/utils'

module DataSources
  module Rfc3164
    # RFC3164 Facilities
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

    # RFC3164 Severities
    SEVERITIES = {
      0 => 'emerg',    # Emergency: system is unusable
      1 => 'alert',    # Alert: action must be taken immediately
      2 => 'crit',     # Critical: critical conditions
      3 => 'err',      # Error: error conditions
      4 => 'warning',  # Warning: warning conditions
      5 => 'notice',   # Notice: normal but significant condition
      6 => 'info',     # Informational: informational messages
      7 => 'debug'     # Debug: debug-level messages
    }

    # Severity colors for terminal output
    SEVERITY_COLORS = {
      'emerg' => Colors::BRIGHT_RED,
      'alert' => Colors::BRIGHT_RED,
      'crit' => Colors::RED,
      'err' => Colors::RED,
      'warning' => Colors::YELLOW,
      'notice' => Colors::CYAN,
      'info' => Colors::GREEN,
      'debug' => Colors::GRAY
    }

    # Common process names for different facilities
    PROCESS_NAMES = {
      'kern' => ['kernel', 'vmunix'],
      'user' => ['login', 'su', 'sudo', 'sshd'],
      'mail' => ['postfix/smtp', 'postfix/qmgr', 'postfix/cleanup', 'sendmail', 'dovecot'],
      'daemon' => ['systemd', 'init', 'chronyd', 'NetworkManager'],
      'auth' => ['sshd', 'sudo', 'login', 'passwd', 'su'],
      'syslog' => ['rsyslogd', 'syslog-ng'],
      'lpr' => ['lpd', 'cupsd'],
      'news' => ['innd', 'nnrpd'],
      'uucp' => ['uucico', 'uuxqt'],
      'cron' => ['CRON', 'crond', 'anacron'],
      'authpriv' => ['sshd', 'sudo', 'su'],
      'ftp' => ['vsftpd', 'proftpd', 'pure-ftpd'],
      'local0' => ['nginx', 'apache2', 'httpd'],
      'local1' => ['haproxy', 'keepalived'],
      'local2' => ['postgresql', 'mysql', 'mariadb'],
      'local3' => ['redis', 'memcached'],
      'local4' => ['docker', 'containerd', 'kubelet'],
      'local5' => ['elasticsearch', 'logstash', 'kibana'],
      'local6' => ['rabbitmq', 'kafka'],
      'local7' => ['app', 'custom', 'myapp']
    }

    # Sample log messages by facility
    MESSAGES = {
      'kern' => [
        'Out of memory: Kill process %d (%s) score %d or sacrifice child',
        'TCP: request_sock_TCP: Possible SYN flooding on port %d. Sending cookies.',
        'EXT4-fs (%s): mounted filesystem with ordered data mode. Opts: %s',
        'Firewall: *DROP* IN=%s OUT= MAC=%s SRC=%s DST=%s',
        'CPU%d: Core temperature above threshold, cpu clock throttled',
        'USB disconnect, device number %d',
        'IPv6: ADDRCONF(NETDEV_UP): %s: link is not ready'
      ],
      'user' => [
        'session opened for user %s by %s(uid=%d)',
        'session closed for user %s',
        'FAILED LOGIN (%d) on %s FOR %s, Authentication failure',
        'password changed for %s',
        'new user: name=%s, UID=%d, GID=%d, home=%s',
        'user %s logged in from %s'
      ],
      'mail' => [
        'from=<%s>, size=%d, nrcpt=%d (queue active)',
        'to=<%s>, relay=%s[%s]:%d, delay=%s, delays=%s, dsn=%s, status=sent',
        'connect from %s[%s]',
        'disconnect from %s[%s] ehlo=%d mail=%d rcpt=%d data=%d quit=%d',
        'warning: %s: SASL authentication failed',
        'reject: RCPT from %s[%s]: 550 5.1.1 <%s>: Recipient address rejected',
        'statistics: max connection rate %d/%ds for (smtp:%s) at %s'
      ],
      'daemon' => [
        'Started %s',
        'Stopped %s',
        'Reloading %s configuration',
        '%s: Main process exited, code=exited, status=%d/SUCCESS',
        'Device %s appeared',
        'Reached target %s',
        'Failed to start %s'
      ],
      'auth' => [
        'Accepted publickey for %s from %s port %d ssh2: %s',
        'Failed password for %s from %s port %d ssh2',
        'Invalid user %s from %s port %d',
        'pam_unix(sshd:session): session opened for user %s by (uid=%d)',
        'pam_unix(sudo:session): session opened for user %s by %s(uid=%d)',
        'authentication failure; logname=%s uid=%d euid=%d tty=%s ruser=%s rhost=%s user=%s',
        'Server listening on %s port %d'
      ],
      'cron' => [
        '(%s) CMD (%s)',
        '(%s) RELOAD (/etc/cron.d/%s)',
        'pam_unix(crond:session): session opened for user %s by (uid=%d)',
        'pam_unix(crond:session): session closed for user %s',
        '(%s) ERROR (failed to open PAM security session)',
        '(%s) INFO (Job execution of "%s" started)',
        '(%s) INFO (Job execution of "%s" completed)'
      ],
      'ftp' => [
        'CONNECT: Client "%s"',
        'OK LOGIN: Client "%s", anon password "%s"',
        'FAIL LOGIN: Client "%s"',
        'OK UPLOAD: Client "%s", "%s", %d bytes, %s KB/sec',
        'OK DOWNLOAD: Client "%s", "%s", %d bytes, %s KB/sec',
        'OK DELETE: Client "%s", "%s"',
        'FAIL DOWNLOAD: Client "%s", "%s", %s'
      ],
      'local0' => [
        '%s [%s] "%s %s %s" %d %d "%s" "%s"',
        'server %s, request: "%s %s", upstream: "%s", host: "%s"',
        'connect() failed (%d: %s) while connecting to upstream',
        'SSL_do_handshake() failed (SSL: error:%s) while SSL handshaking',
        '*%d open() "%s" failed (%d: %s)',
        'client %s closed keepalive connection',
        'accept4() failed (%d: %s)'
      ],
      'local1' => [
        'backend %s has no server available!',
        'Health check for server %s/%s succeeded',
        'Health check for server %s/%s failed',
        'Server %s/%s is UP',
        'Server %s/%s is DOWN',
        'Proxy %s started',
        'Connect from %s:%d to %s:%d (%s/%s)'
      ],
      'local2' => [
        'connection received: host=%s port=%d',
        'connection authorized: user=%s database=%s',
        'disconnection: session time: %s user=%s database=%s host=%s',
        'ERROR: %s at character %d',
        'FATAL: %s',
        'WARNING: %s',
        'LOG: checkpoint starting: %s'
      ],
      'local3' => [
        'Accepted %s:%d',
        'Client %s:%d connected',
        'Background saving started by pid %d',
        'DB saved on disk',
        'Connection closed by client %s:%d',
        'Synchronization with replica %s:%d succeeded',
        '# WARNING: %s'
      ],
      'local4' => [
        'Container %s Started',
        'Container %s Stopped',
        'Image %s Pulled',
        'Volume %s Created',
        'Network %s Connected',
        'Health check for container %s failed',
        'API listen on %s'
      ]
    }

    # Common hostnames
    HOSTNAMES = [
      'web01', 'web02', 'app01', 'app02', 'db01', 'db02',
      'mail01', 'proxy01', 'cache01', 'log01', 'monitor01',
      'backup01', 'dev01', 'staging01', 'prod01', 'prod02'
    ]

    class << self
      def generate_log_entry
        facility_num = FACILITIES.keys.sample
        facility_name = FACILITIES[facility_num]
        severity_num = weighted_severity
        severity_name = SEVERITIES[severity_num]

        # Calculate priority (facility * 8 + severity)
        priority = facility_num * 8 + severity_num

        # Generate timestamp (RFC3164 uses Mmm dd hh:mm:ss format)
        timestamp = Time.now.strftime('%b %e %H:%M:%S').gsub('  ', ' ')

        # Get hostname
        hostname = HOSTNAMES.sample

        # Get process name and PID
        process_names = PROCESS_NAMES[facility_name] || ['process']
        process = process_names.sample
        pid = rand(100..65535)

        # Get appropriate message
        messages = MESSAGES[facility_name] || MESSAGES['daemon']
        message_template = messages.sample
        message = fill_message_template(message_template, facility_name)

        # Apply color to severity
        severity_color = SEVERITY_COLORS[severity_name]

        # Format: <priority>timestamp hostname process[pid]: message
        # Using traditional syslog format with colors for readability
        "#{Colors::GRAY}<#{priority}>#{Colors::RESET}#{timestamp} #{Colors::CYAN}#{hostname}#{Colors::RESET} #{Colors::YELLOW}#{process}[#{pid}]#{Colors::RESET}: #{severity_color}#{message}#{Colors::RESET}"
      end

      private

      def weighted_severity
        # Weight towards info/notice with occasional warnings and rare errors
        weights = {
          0 => 0.001, # emerg
          1 => 0.001, # alert
          2 => 0.008, # crit
          3 => 0.04,  # err
          4 => 0.15,  # warning
          5 => 0.30,  # notice
          6 => 0.40,  # info
          7 => 0.10   # debug
        }

        rand_val = rand
        cumulative = 0

        weights.each do |severity, weight|
          cumulative += weight
          return severity if rand_val <= cumulative
        end

        6 # default to info
      end

      def fill_message_template(template, facility)
        # Return template as-is if it has no format specifiers
        return template unless template.include?('%')

        begin
          replacements = case facility
        when 'kern'
          case template
          when /Kill process/
            [rand(1000..65535), %w[chrome firefox node ruby python java].sample, rand(100..999)]
          when /SYN flooding/
            [%w[80 443 22 3306 5432 6379].sample]
          when /mounted filesystem/
            ["/dev/sda#{rand(1..9)}", %w[errors=remount-ro relatime noatime].sample]
          when /Firewall/
            ["eth#{rand(0..3)}", generate_mac, LogUtils.ip_address, LogUtils.ip_address]
          when /Core temperature/
            [rand(0..7)]
          when /USB disconnect/
            [rand(1..20)]
          when /IPv6/
            ["eth#{rand(0..3)}"]
          else
            []
          end
        when 'user', 'auth'
          case template
          when /pam_unix\(sshd:session\)/
            [%w[root admin deploy jenkins gitlab runner postgres mysql].sample, rand(0..1000)]
          when /pam_unix\(sudo:session\)/
            [%w[root admin deploy jenkins gitlab runner postgres mysql].sample,
             %w[root sudo cron].sample, rand(0..1000)]
          when /session opened for user (?!.*by \()/
            [%w[root admin deploy jenkins gitlab runner postgres mysql].sample, LogUtils.ip_address]
          when /FAILED LOGIN/
            [rand(1..5), %w[tty1 pts/0 pts/1 ssh].sample, %w[admin test user guest root].sample]
          when /password changed/
            [%w[admin user1 deploy jenkins].sample]
          when /new user/
            ["user#{rand(100..999)}", rand(1000..9999), rand(1000..9999), "/home/user#{rand(100..999)}"]
          when /logged in from/
            [%w[admin deploy jenkins root].sample, LogUtils.ip_address]
          when /Accepted publickey/
            [%w[git deploy admin root].sample, LogUtils.ip_address, rand(1024..65535), "RSA SHA256:#{SecureRandom.hex(16)}"]
          when /Failed password/
            [%w[admin root test guest invalid].sample, LogUtils.ip_address, rand(1024..65535)]
          when /Invalid user/
            [%w[admin test user guest oracle mysql].sample, LogUtils.ip_address, rand(1024..65535)]
          when /authentication failure/
            [%w[root admin].sample, rand(0..1000), rand(0..1000), %w[ssh pts/0 pts/1].sample,
             %w[root admin].sample, LogUtils.ip_address, %w[root admin deploy].sample]
          when /Server listening/
            [%w[0.0.0.0 :: 127.0.0.1].sample, %w[22 80 443 3306].sample]
          else
            []
          end
        when 'mail'
          case template
          when /from=<.*size=/
            ["user#{rand(100..999)}@example.com", rand(1000..1000000), rand(1..5)]
          when /to=<.*relay=/
            ["recipient#{rand(100..999)}@example.com", "mail.example.com", LogUtils.ip_address,
             25, "#{rand(0..5)}.#{rand(0..999)}",
             "#{rand(0..2)}.#{rand(0..999)}/#{rand(0..2)}.#{rand(0..999)}/#{rand(0..2)}.#{rand(0..999)}/#{rand(0..2)}.#{rand(0..999)}",
             "2.0.0", "sent (250 2.0.0 OK)"]
          when /connect from/
            ["unknown", LogUtils.ip_address]
          when /disconnect from/
            ["unknown", LogUtils.ip_address, rand(0..2), rand(0..2), rand(0..2), rand(0..2), rand(0..2)]
          when /SASL authentication/
            ["unknown[#{LogUtils.ip_address}]"]
          when /Recipient address rejected/
            ["unknown", LogUtils.ip_address, "invalid@example.com"]
          when /max connection rate/
            [rand(10..100), 60, LogUtils.ip_address, Time.now.strftime('%b %e %H:%M:%S')]
          else
            []
          end
        when 'cron'
          case template
          when /CMD \(/
            [%w[root backup postgres mysql www-data].sample,
             ['/usr/bin/backup.sh', '/opt/scripts/cleanup.sh', '/usr/local/bin/monitor.py',
              'cd /var/www && php artisan schedule:run', '/usr/bin/certbot renew --quiet'].sample]
          when /RELOAD/
            [%w[root].sample, %w[daily weekly monthly].sample]
          when /session opened.*user|session closed/
            [%w[root backup postgres].sample, 0]
          when /ERROR|INFO.*Job/
            [%w[root backup www-data].sample, %w[backup daily-report db-cleanup cache-clear].sample]
          else
            []
          end
        when 'local0' # nginx/apache style
          case template
          when /%s \[%s\]/
            [LogUtils.ip_address, Time.now.strftime('%d/%b/%Y:%H:%M:%S +0000'),
             %w[GET POST PUT DELETE PATCH].sample,
             ['/api/users', '/api/products', '/index.html', '/assets/main.css', '/favicon.ico'].sample,
             'HTTP/1.1', [200, 301, 302, 404, 500].sample, rand(100..50000),
             %w[- http://example.com/].sample,
             'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36']
          else
            []
          end
        else
          # Generic replacements
          template.scan(/%[sd]/).size.times.map do
            rand < 0.5 ? rand(1..1000) : %w[active inactive running stopped failed].sample
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
          "#{facility} message (format error)"
        end
      end

      def generate_mac
        6.times.map { '%02x' % rand(256) }.join(':')
      end
    end
  end
end
