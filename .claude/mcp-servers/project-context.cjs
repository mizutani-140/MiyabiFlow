#!/usr/bin/env node
/**
 * project-context MCP server
 * - Provides lightweight, structured context about the repository
 *
 * NOTE:
 * - Intended for local development. Do not expose to untrusted inputs.
 */

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { CallToolRequestSchema, ListToolsRequestSchema } = require("@modelcontextprotocol/sdk/types.js");

function safeReadJson(p) {
  try {
    return JSON.parse(fs.readFileSync(p, "utf8"));
  } catch {
    return null;
  }
}

function exists(p) {
  try { fs.accessSync(p); return true; } catch { return false; }
}

function repoRoot() {
  try {
    return execSync("git rev-parse --show-toplevel", { encoding: "utf8" }).trim();
  } catch {
    return process.cwd();
  }
}

function listDirTree(root, depth, includeHidden) {
  const ignore = new Set([".git", "node_modules", ".worktrees", ".ai", "dist", "build", "target"]);
  function walk(dir, d) {
    if (d > depth) return [];
    let entries = [];
    for (const name of fs.readdirSync(dir)) {
      if (!includeHidden && name.startsWith(".")) continue;
      if (ignore.has(name)) continue;
      const full = path.join(dir, name);
      const rel = path.relative(root, full);
      let stat;
      try { stat = fs.statSync(full); } catch { continue; }
      if (stat.isDirectory()) {
        entries.push(rel + "/");
        entries = entries.concat(walk(full, d + 1));
      } else {
        entries.push(rel);
      }
    }
    return entries;
  }
  return walk(root, 1);
}

function detectTooling(root) {
  const tooling = {
    detected: [],
    make: exists(path.join(root, "Makefile")),
    node: exists(path.join(root, "package.json")),
    python: exists(path.join(root, "pyproject.toml")) || exists(path.join(root, "requirements.txt")),
    go: exists(path.join(root, "go.mod")),
    rust: exists(path.join(root, "Cargo.toml")),
  };

  if (tooling.make) tooling.detected.push("make");
  if (tooling.node) tooling.detected.push("node");
  if (tooling.python) tooling.detected.push("python");
  if (tooling.go) tooling.detected.push("go");
  if (tooling.rust) tooling.detected.push("rust");

  const pkg = tooling.node ? safeReadJson(path.join(root, "package.json")) : null;
  const scripts = (pkg && pkg.scripts) ? pkg.scripts : {};
  tooling.nodeScripts = Object.keys(scripts || {});

  return tooling;
}

function detectCiEntrypoints(root, tooling) {
  const entries = [];
  if (exists(path.join(root, "scripts/ci/run_ci.sh"))) entries.push("bash scripts/ci/run_ci.sh --mode ci");
  if (tooling.make) entries.push("make ci (if target exists)");
  if (tooling.node) entries.push("npm test / npm run lint (if present)");
  if (tooling.python) entries.push("pytest / ruff / mypy (if installed)");
  return entries;
}

class ProjectContextServer {
  constructor() {
    this.server = new Server(
      { name: "project-context", version: "0.1.0" },
      { capabilities: { tools: {} } }
    );
    this.root = repoRoot();
    this.register();
  }

  register() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: "project_summary",
          description: "Summarize repository tooling and CI entrypoints",
          inputSchema: { type: "object", properties: {} },
        },
        {
          name: "repo_tree",
          description: "List repository tree (lightweight) up to depth",
          inputSchema: {
            type: "object",
            properties: {
              depth: { type: "number", default: 3 },
              includeHidden: { type: "boolean", default: false },
            },
          },
        },
        {
          name: "ci_entrypoints",
          description: "Return recommended CI/test commands for this repo",
          inputSchema: { type: "object", properties: {} },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (req) => {
      const name = req.params.name;
      const args = req.params.arguments || {};
      if (name === "project_summary") {
        const tooling = detectTooling(this.root);
        const ci = detectCiEntrypoints(this.root, tooling);
        const out = {
          root: this.root,
          tooling,
          ci_entrypoints: ci,
        };
        return { content: [{ type: "text", text: JSON.stringify(out, null, 2) }] };
      }

      if (name === "repo_tree") {
        const depth = Number(args.depth || 3);
        const includeHidden = Boolean(args.includeHidden || false);
        const entries = listDirTree(this.root, depth, includeHidden);
        return { content: [{ type: "text", text: entries.join("\n") }] };
      }

      if (name === "ci_entrypoints") {
        const tooling = detectTooling(this.root);
        const ci = detectCiEntrypoints(this.root, tooling);
        return { content: [{ type: "text", text: ci.join("\n") }] };
      }

      return { content: [{ type: "text", text: `Unknown tool: ${name}` }] };
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

new ProjectContextServer().start().catch((err) => {
  console.error(err);
  process.exit(1);
});
