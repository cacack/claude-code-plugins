# Example Plugin

This is an example plugin demonstrating the basic structure of a Claude Code plugin.

## Contents

- **Commands**: Custom slash commands (in `/commands`)
  - `/hello` - A simple greeting command

- **Agents**: Custom agent definitions (in `/agents`)
  - `example-agent` - A demonstration agent

## Usage

After installing this plugin, you can:
- Run `/hello` to test the custom command
- Invoke the example agent to see how agents work

## Structure

```
example-plugin/
├── plugin.json       # Plugin metadata and configuration
├── commands/         # Custom slash commands
│   └── hello.md
├── agents/           # Custom agent definitions
│   └── example-agent.md
└── README.md         # This file
```
