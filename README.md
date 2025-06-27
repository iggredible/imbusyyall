# Rails Fake Log Generator

Generate colorized, realistic-looking Rails server logs for testing, demonstrations, or development environments.

![Sample output screenshot](https://via.placeholder.com/800x400.png?text=Sample+Rails+Log+Output)

## Features

- 🌈 Colorized output matching real Rails server logs
- 🔄 HTTP request simulation with realistic routes
- 🔍 SQL query simulation with proper timing
- ⚙️ Background job processing logs (ActiveJob and Sidekiq)
- ⏱ Simulated performance metrics
- 🧩 Cache hit/miss events
- ❌ Error states and exceptions with backtraces
- 🏃‍♂️ Adjustable output speed
- ♾️ Supports both finite and infinite log generation

## Installation

Simply download the script and make it executable:

```bash
curl -o fake_rails_logs.rb https://raw.githubusercontent.com/yourusername/rails-fake-log-generator/main/fake_rails_logs.rb
chmod +x fake_rails_logs.rb
```

## Requirements

- Ruby 2.5 or higher

## Usage

### Basic Usage

Generate 1000 log lines (default behavior):

```bash
./fake_rails_logs.rb
```

### Specify Number of Lines

Generate a specific number of log lines:

```bash
./fake_rails_logs.rb -l 500
# or
./fake_rails_logs.rb 500
```

### Infinite Mode

Generate logs indefinitely (until manually stopped with Ctrl+C):

```bash
./fake_rails_logs.rb -l INFINITY
# or
./fake_rails_logs.rb INFINITY
```

### Control Output Speed

Adjust the pause between log entries (in seconds):

```bash
# Fast generation (1ms between entries)
./fake_rails_logs.rb -s 0.001

# Moderate speed (default - 10ms)
./fake_rails_logs.rb -s 0.01

# Slow, presentation-friendly speed (1 second)
./fake_rails_logs.rb -s 1
```

### Save Output to File

Save the colorized output to a file:

```bash
./fake_rails_logs.rb > rails_logs.log
```

To view the file with colors preserved:

```bash
less -R rails_logs.log
```

## Options

| Option | Description |
|--------|-------------|
| `-l, --lines LINES` | Number of log lines to generate. Use "INFINITY" for endless logs |
| `-s, --sleep SECONDS` | Sleep time between log entries (in seconds) |
| `-h, --help` | Display help information |

## Sample Output

```
Started GET "/recipes" for 192.168.1.123 at 2024-06-27 14:35:22.456
Processing by RecipesController#index as HTML
  Parameters: {"page":"2","sort":"rating"}
  SELECT * FROM recipes WHERE status = ?  [0.9ms]
  SELECT COUNT(*) FROM recipes WHERE category_id = ?  [1.2ms]
  Cache hit views/recipes/123-20240615063022 (0.2ms)
  Rendered recipes/index.html.slim (Duration: 23.5ms | Allocations: 3421)
Completed 200 OK in 78.4ms (Views: 32.1ms | ActiveRecord: 12.3ms | Allocations: 28764)

Started POST "/orders" for 10.0.0.24 at 2024-06-27 14:35:23.901
Processing by OrdersController#create as JSON
  Parameters: {"order":{"dish_id":245,"quantity":2}}
  INSERT INTO orders  [14.8ms]
  Rendered orders/create.json.jbuilder (Duration: 5.2ms | Allocations: 1542)
Completed 201 Created in 104.3ms (Views: 7.3ms | ActiveRecord: 82.1ms | Allocations: 32145)

[ActiveJob] [a7f82c3b9d34] Performed RecipeNotificationWorker in 342.1ms

Started GET "/ingredients/search" for 172.16.8.112 at 2024-06-27 14:35:27.308
Processing by IngredientsController#search as JSON
  Parameters: {"search":"tomato"}
ActiveRecord::RecordNotFound: Couldn't find Ingredient with 'name'=organic tomato
app/controllers/ingredients_controller.rb:78:in `search'
app/services/search_service.rb:45:in `find_by_name'
```

## Customization

You can easily customize the generated logs by modifying the `FakeData` class in the script. Add your own:

- Controller names
- Action names
- Routes
- Database tables
- SQL queries
- Error messages
- Worker job names

## License

MIT

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
