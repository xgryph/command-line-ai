#!/bin/bash

# Set the history file path to a hidden file in the home directory
HISTORY_FILE="$HOME/.conversation_history.txt"

# Function to initialize or clear the history
clear_history() {
  echo "[]" > "$HISTORY_FILE"
  echo "Conversation history cleared."
}

# Check for the --clear-history argument
if [ "$1" == "--clear-history" ]; then
  clear_history
  exit 0
fi

# Check if API key is set as an environment variable
if [ -z "$OPENAI_API_KEY" ]; then
  echo "Error: OPENAI_API_KEY is not set. Please set it as an environment variable." >&2
  exit 1
fi

# Read the prompt from the command line argument
if [ -z "$1" ]; then
  echo "Error: No prompt provided. Usage: ./ai.sh \"Your prompt here\" or ./ai.sh --clear-history" >&2
  exit 1
fi

PROMPT="$*"

# Initialize history file if it doesn't exist
if [ ! -f "$HISTORY_FILE" ]; then
  echo "[]" > "$HISTORY_FILE"
fi

# Add the new prompt to the conversation history
CONVERSATION_HISTORY=$(jq --arg prompt "$PROMPT" '. += [{"role": "user", "content": $prompt}]' "$HISTORY_FILE")

# Create a temporary file for the JSON payload
TEMP_JSON=$(mktemp)

# Construct the JSON payload with the system prompt and conversation history
jq -n --arg system_content "You are a helpful assistant for command-line users. Your responses should be clear, concise, and suitable for running on a macOS or Linux terminal. The must be to the point and do not guess too much about what the user wants. Minimise any formatting as the result will be pretty to the command line." \
  '{
    model: "gpt-4o-mini",
    messages: [{role: "system", content: $system_content}]
  }' > "$TEMP_JSON"

# Append the conversation history to the messages array
jq --argjson history "$CONVERSATION_HISTORY" '.messages += $history' "$TEMP_JSON" > "${TEMP_JSON}.tmp" && mv "${TEMP_JSON}.tmp" "$TEMP_JSON"

# Make the API call and extract the response content
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d @"$TEMP_JSON" \
  https://api.openai.com/v1/chat/completions)

# Remove the temporary JSON file
rm "$TEMP_JSON"

# Check if the curl command succeeded
if [ $? -ne 0 ]; then
  echo "Error: Failed to reach OpenAI API." >&2
  exit 1
fi

# Extract and format the response using jq
PARSED_RESPONSE=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

# Check if jq succeeded and if we got a valid response
if [ -z "$PARSED_RESPONSE" ]; then
  echo "Error: Failed to parse the API response." >&2
  echo "Full API response: $RESPONSE" >&2
  exit 1
fi

# Append the assistant's response to the conversation history
CONVERSATION_HISTORY=$(echo "$CONVERSATION_HISTORY" | jq --arg response "$PARSED_RESPONSE" '. += [{"role": "assistant", "content": $response}]')

# Update the history file without including the system prompt
echo "$CONVERSATION_HISTORY" > "$HISTORY_FILE"

# Get the number of columns in the terminal window, default to 80 if not available
WIDTH=$(tput cols 2>/dev/null || echo 80)

# Add some color to the assistant's response (yellow text)
echo -e "---------------------- Ai ----------------------"
echo "$PARSED_RESPONSE" | fold -s -w $WIDTH
echo -e "------------------------------------------------"