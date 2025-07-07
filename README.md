# imbusyyall

## Fake Server Logs Generator 💻

Generate colorized, realistic-looking server logs so people who walk by you think you're very busy and won't interrupt you! 🤫

![imbusyyall demo](https://private-user-images.githubusercontent.com/13905902/462181363-34fc81d2-47b6-47af-b9f3-4b185dd5c7d1.gif?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NTE1NzA4OTEsIm5iZiI6MTc1MTU3MDU5MSwicGF0aCI6Ii8xMzkwNTkwMi80NjIxODEzNjMtMzRmYzgxZDItNDdiNi00N2FmLWI5ZjMtNGIxODVkZDVjN2QxLmdpZj9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNTA3MDMlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjUwNzAzVDE5MjMxMVomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTcxYjAxYjBhMGJhZjFjZjcxMTVkOTUyZmUzNTkwM2UwODRhOWM3MmUzOThkN2U5ZWU4Mjc1MGY4OTNjMzViNjAmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0In0.b23fk4bFObs0V2Uqhwd3v20PryRJnIN6lKzkVEOF8Xk)

## Credits / Inspiration / Motivation

Inspired by:
- [flog](https://github.com/mingrammer/flog/)
- [Benji playing Halo in Mission Impossible](https://www.youtube.com/watch?v=jg_PXNZrBds)

## Installation

### Manual Installation

Simply download the script and make it executable:

```bash
git clone https://github.com/yourusername/imbusyyall.git
cd imbusyyall
chmod +x imbusyyall.rb
```
### Using Homebrew

```bash
brew tap iggredible/imbusyyall
brew install imbusyyall
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
