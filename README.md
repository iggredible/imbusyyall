# imbusyyall - Multi-Framework Log Generator

Generate colorized, realistic-looking server logs for various frameworks and platforms for testing, demonstrations, or development environments.

![Sample output screenshot](https://via.placeholder.com/800x400.png?text=Multi-Framework+Log+Output)

## Features

- 🌈 **Colorized output** matching real server logs for each framework
- 🔄 **Multiple data sources** supporting Rails, Node.js, Django, and Apache
- 🔍 **Realistic log patterns** with proper timing and formatting
- ⚙️ **Framework-specific features** (ActiveJob, Celery, Apache modules, etc.)
- ⏱ **Simulated performance metrics** with realistic timing
- 🧩 **Cache operations** and database interactions
- ❌ **Error states and exceptions** with proper stack traces
- 🏃‍♂️ **Adjustable output speed** for presentations or testing
- ♾️ **Infinite mode** for continuous log generation
- 🎯 **Modular architecture** for easy extension

## Supported Frameworks

| Framework | Data Source | Description |
|-----------|-------------|-------------|
| **Rails** | `rails` | Ruby on Rails server logs with ActiveRecord, ActiveJob, and Sidekiq |
| **Node.js** | `node` | Express.js server logs with MongoDB, Redis, and various middleware |
| **Django** | `django` | Django web framework logs with ORM queries, Celery, and management commands |
| **Apache** | `apache` | Apache web server logs in Common and Combined Log Format |

## Installation

Simply download the script and make it executable:

```bash
git clone https://github.com/yourusername/imbusyyall.git
cd imbusyyall
chmod +x imbusyyall.rb
```

## Requirements

- Ruby 2.5 or higher
- No external dependencies (uses only Ruby standard library)

## Usage

### Basic Usage

Generate 1000 Rails log lines (default behavior):

```bash
./imbusyyall.rb
```

### Data Source Selection

Choose your framework with the `-d` option:

```bash
# Rails logs (default)
./imbusyyall.rb -d rails

# Node.js/Express logs
./imbusyyall.rb -d node

# Django logs
./imbusyyall.rb -d django

# Apache logs
./imbusyyall.rb -d apache
```

### Specify Number of Lines

Generate a specific number of log lines:

```bash
./imbusyyall.rb -l 500 -d node
# or legacy format
./imbusyyall.rb 500
```

### Infinite Mode

Generate logs indefinitely (until manually stopped with Ctrl+C):

```bash
./imbusyyall.rb -l INFINITY -d django
# or
./imbusyyall.rb INFINITY
```

### Control Output Speed

Adjust the pause between log entries (in seconds):

```bash
# Fast generation (1ms between entries)
./imbusyyall.rb -s 0.001 -d apache

# Moderate speed (default - 50ms)
./imbusyyall.rb -s 0.05

# Slow, presentation-friendly speed (1 second)
./imbusyyall.rb -s 1 -d rails
```

### Save Output to File

Save the colorized output to a file:

```bash
./imbusyyall.rb -d node > node_logs.log
```

To view the file with colors preserved:

```bash
less -R node_logs.log
```

## Command Line Options

| Option | Description |
|--------|-------------|
| `-l, --lines LINES` | Number of log lines to generate. Use "INFINITY" for endless logs |
| `-s, --sleep SECONDS` | Sleep time between log entries (in seconds, default: 0.05) |
| `-d, --data-source SOURCE` | Data source to use: rails, node, django, apache (default: rails) |
| `-h, --help` | Display help information |

## Sample Output

### Rails Logs
```
Started GET "/recipes" for 192.168.1.123 at 2024-06-27 14:35:22.456
Processing by RecipesController#index as HTML
  Parameters: {"page":"2","sort":"rating"}
  SELECT * FROM recipes WHERE status = ?  [0.9ms]
  Cache hit views/recipes/123-20240615063022 (0.2ms)
  Rendered recipes/index.html.slim (Duration: 23.5ms | Allocations: 3421)
Completed 200 OK in 78.4ms (Views: 32.1ms | ActiveRecord: 12.3ms | Allocations: 28764)

[ActiveJob] [a7f82c3b9d34] Performed RecipeNotificationWorker in 342.1ms
```

### Node.js Logs
```
[2024-06-27 14:35:22] GET /api/users 200 45ms - 192.168.1.100 "Mozilla/5.0..."
[INFO] Database connection established
[ERROR] TypeError: Cannot read property 'id' of undefined
    at UserController.getProfile (/app/src/controllers/user.controller.js:42:15)
[MongoDB] users.find({ email: 'user@example.com' }) +12ms
```

### Django Logs
```
[27/Jun/2024 14:35:22] "GET /api/v1/users/ HTTP/1.1" 200 4521
[2024-06-27 14:35:22] django.db.backends (23.456) SELECT "auth_user"."id" FROM "auth_user"; args=()
[ERROR] django.request Internal Server Error: /api/products/
DoesNotExist: User matching query does not exist.
[celery.worker] Task accounts.tasks.send_welcome_email[abc123] succeeded in 1.2s
```

### Apache Logs
```
192.168.1.100 - - [27/Jun/2024:14:35:22 -0500] "GET /index.html HTTP/1.1" 200 2326 "https://www.google.com/" "Mozilla/5.0..."
[27/Jun/2024:14:35:23 -0500] [error] [pid 1234] [client 192.168.1.101] File does not exist: /var/www/html/favicon.ico
[27/Jun/2024:14:35:24 -0500] [ssl:info] [pid 1235] SSL handshake successful
```

## Architecture

The application follows a modular, plugin-based architecture:

```
imbusyyall.rb              # Main entry point
├── lib/
│   └── utils.rb           # Shared utilities (Colors, LogUtils)
└── data/
    ├── rails.rb           # Rails log patterns and generation
    ├── node.rb            # Node.js/Express log patterns
    ├── django.rb          # Django log patterns
    └── apache.rb          # Apache log patterns
```

### Key Components

- **Main Script** (`imbusyyall.rb`): Command-line interface and orchestration
- **Utilities** (`lib/utils.rb`): Shared color codes and utility functions
- **Data Providers** (`data/*.rb`): Framework-specific log generation logic
- **LogGenerator**: Delegates to appropriate data provider based on selection

### Adding New Data Sources

To add support for a new framework:

1. Create a new file in `data/` (e.g., `data/nginx.rb`)
2. Implement the required interface:
   ```ruby
   module DataSources
     module Nginx
       class << self
         def generate_log_entry
           # Return array of log lines
         end
       end
     end
   end
   ```
3. Add the data source to `load_data_source()` in `imbusyyall.rb`

## Framework-Specific Features

### Rails
- ActiveRecord query logs with timing
- ActiveJob and Sidekiq background jobs
- Cache operations (hit/miss)
- Exception handling with backtraces
- Asset pipeline logs

### Node.js
- Express.js HTTP request logs
- Database operations (MongoDB, PostgreSQL, Redis)
- Error handling with stack traces
- Debug and process logs
- Middleware execution logs

### Django
- Django ORM query logs with execution time
- Celery task logs
- Management command output
- Template rendering logs
- Security warnings

### Apache
- Common Log Format and Combined Log Format
- Error logs with different severity levels
- SSL/TLS logs
- Module-specific logs (mod_rewrite, mod_ssl, etc.)
- Virtual host logs

## License

MIT

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Changelog

### v2.0.0
- Added support for multiple frameworks (Node.js, Django, Apache)
- Refactored to modular architecture
- Added data source selection with `-d` option
- Improved color schemes for each framework
- Enhanced realistic log patterns

### v1.0.0
- Initial Rails-only version
- Basic log generation with colorization
- Infinite mode support
- Adjustable timing

## Credits

Inspired by [flog](https://github.com/mingrammer/flog/).
