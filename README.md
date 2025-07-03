# imbusyyall - Rails Log Generator

Generate colorized, realistic-looking Rails server logs for testing, demonstrations, or development environments.

*Inspired by [flog](https://github.com/mingrammer/flog/)*

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

```console
Options:
  -l, --lines NUMBER       number of log lines to generate (default: 1000)
                           use "INFINITY" for endless logs
  -s, --sleep SECONDS      delay between log entries (default: 0.05)
                           examples: 0.001, 0.5, 1
  -d, --data-source NAME   data source to use (default: rails)
                           available sources: rails, node, django, apache
```

```console
# Generate 1000 lines of Rails logs to stdout
$ ./imbusyyall.rb

# Generate 500 lines of logs with a 1 second delay between each line
$ ./imbusyyall.rb -l 500 -s 1

# Generate logs infinitely with minimal delay (1ms)
$ ./imbusyyall.rb -l INFINITY -s 0.001

# Generate Node.js logs
$ ./imbusyyall.rb -d node -l 2000

# Generate Django logs with slow output for demos
$ ./imbusyyall.rb -d django -s 1

# Generate Apache logs infinitely
$ ./imbusyyall.rb -d apache -l INFINITY

# Save colorized output to a file
$ ./imbusyyall.rb -l 2000 > rails.log

# View saved logs with colors preserved
$ less -R rails.log
```

## Sample Output

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

## Contributing

Want to add support for more server logs?

To add a new log format:
1. Check out `data/sample.rb` for inspiration and structure
2. Create a new data source file in the `data/` directory
3. Implement a public `generate_log_entry` method
4. Add your data source to the main script
5. Submit a PR!

What server logs do you often work with that's not in here already?

## License

MIT
