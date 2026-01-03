# The Handyman Principle

> Context is a scarce resource. Treat it with organizational discipline.

Source: [The Handyman Principle: Why Your AI Forgets Everything](https://vexjoy.com/posts/the-handyman-principle-why-your-ai-forgets-everything/)

## The Problem

AI assistants forget instructions, hallucinate solutions, and lose track of progress. The root cause: **inefficient context management**—stuffing massive, unorganized prompts into AI interactions.

## The Metaphor

Just as you wouldn't hand a handyman repair manuals for every appliance in your home when they're fixing your dishwasher, you shouldn't overload an AI with irrelevant information.

> "Context is too noisy. He might start fixing the dishwasher using the blender instructions."

## Three-Part Solution

### 1. Agents (Job Descriptions)

Rather than one massive instruction file, use **specialized agents** that handle their domain. Each agent carries only the instructions relevant to its task—TypeScript, Go, Kubernetes, security review, etc.

**Plugin application**: Create focused agents with narrow, deep expertise rather than generalist agents that try to do everything.

### 2. Skills (Real Tools)

The distinction between a prompt and a skill:

> "A Skill is a program. A deterministic tool attached to a markdown file."

Good skills connect AI to **actual tools**—validators, linters, scripts, git workflows. Let the AI orchestrate rather than guess.

**Plugin application**: Skills should invoke real scripts, run actual commands, and produce verifiable outputs. Don't just describe what to do—do it.

### 3. Plans (External Memory)

Don't rely on internal AI memory. Use **files to track progress**.

> "You don't make it remember the past. You make it read the current status from the clipboard."

This approach survives context-window limitations and session restarts.

**Plugin application**: Workflows should externalize state to files (handoffs, todos, checkpoints) rather than assuming context persists.

## Core Insight

The solution isn't complexity—it's **organizational discipline** treating context as scarce rather than unlimited.
