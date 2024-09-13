# AI Shell Script

This shell script provides a command-line interface to interact with OpenAI's GPT models, allowing users to have conversations and get AI-generated responses directly in their terminal.

## Features

- Interact with OpenAI's GPT models through the command line
- Maintain conversation history across multiple interactions
- Clear conversation history when needed

## Prerequisites

- Bash shell
- `curl` for making HTTP requests
- `jq` for JSON parsing
- An OpenAI API key

## Installation

1. Clone this repository or download the script file.
2. Make the script executable:
   ```
   chmod +x ai.sh
   ```
3. Set up your OpenAI API key as an environment variable:
   ```
   export OPENAI_API_KEY='your-api-key-here'
   ```
   For permanent setup, add this line to your `~/.bashrc` or `~/.zshrc` file.
4. You may want to copy the script into your path:
   ```
   sudo cp ai.sh /usr/local/bin/ai
   ```

## Usage

### Basic usage
```
./ai.sh "Your prompt or question here"
```

### Clear conversation history
```
./ai.sh --clear-history
```

## Configuration

The script uses the following configuration:

- Model: GPT-4o-mini (can be changed in the script)
- History file: `~/.conversation_history.txt`

You can modify these settings by editing the script.

## Troubleshooting

If you encounter any issues:

1. Ensure your OpenAI API key is correctly set.
2. Check that you have the latest versions of `curl` and `jq` installed.
3. Verify that the `~/.conversation_history.txt` is writable

## Contributing

Contributions, issues, and feature requests are welcome.

## License

[MIT](https://choosealicense.com/licenses/mit/)
