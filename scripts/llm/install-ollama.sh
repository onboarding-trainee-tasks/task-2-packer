#!/bin/bash
set -e

curl -fsSL https://ollama.com/install.sh | sh
sleep 5
ollama pull tinyllama
echo "Installed models:"
ollama list
