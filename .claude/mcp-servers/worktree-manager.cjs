#!/usr/bin/env node
/**
 * worktree-manager MCP server
 * - Wraps safe git worktree operations
 */

const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { CallToolRequestSchema, ListToolsRequestSchema } = require("@modelcontextprotocol/sdk/types.js");

function run(cmd) {
  return execSync(cmd, { encoding: "utf8" });
}

function root() {
  try { return run("git rev-parse --show-toplevel").trim(); } catch { return process.cwd(); }
}

function okBranch(s) {
  return /^[A-Za-z0-9._\/-]{1,120}$/.test(s);
}

function okPathRel(s) {
  // no absolute, no traversal
  if (!s) return false;
  if (path.isAbsolute(s)) return false;
  if (s.includes("..")) return false;
  return true;
}

class WorktreeManager {
  constructor() {
    this.server = new Server(
      { name: "worktree-manager", version: "0.1.0" },
      { capabilities: { tools: {} } }
    );
    this.repoRoot = root();
    this.register();
  }

  register() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: "list_worktrees",
          description: "List git worktrees (porcelain)",
          inputSchema: { type: "object", properties: {} },
        },
        {
          name: "create_worktree",
          description: "Create a worktree under a relative path",
          inputSchema: {
            type: "object",
            properties: {
              path: { type: "string", description: "Relative path (e.g., .worktrees/task-001)" },
              branch: { type: "string", description: "Branch name to create/use" },
              base: { type: "string", description: "Base ref (default HEAD)" },
            },
            required: ["path", "branch"],
          },
        },
        {
          name: "remove_worktree",
          description: "Remove a worktree by path (force)",
          inputSchema: {
            type: "object",
            properties: { path: { type: "string" } },
            required: ["path"],
          },
        },
        {
          name: "prune_worktrees",
          description: "Run git worktree prune",
          inputSchema: { type: "object", properties: {} },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (req) => {
      const name = req.params.name;
      const args = req.params.arguments || {};
      try {
        if (name === "list_worktrees") {
          const out = run("git worktree list --porcelain");
          return { content: [{ type: "text", text: out }] };
        }
        if (name === "create_worktree") {
          const p = String(args.path || "");
          const branch = String(args.branch || "");
          const base = String(args.base || "HEAD");
          if (!okPathRel(p)) throw new Error("invalid path");
          if (!okBranch(branch)) throw new Error("invalid branch");
          const abs = path.join(this.repoRoot, p);
          fs.mkdirSync(path.dirname(abs), { recursive: true });
          const cmd = `git worktree add -b ${branch} ${p} ${base}`;
          const out = run(cmd);
          return { content: [{ type: "text", text: out || "OK" }] };
        }
        if (name === "remove_worktree") {
          const p = String(args.path || "");
          if (!okPathRel(p)) throw new Error("invalid path");
          const out = run(`git worktree remove --force ${p}`);
          return { content: [{ type: "text", text: out || "OK" }] };
        }
        if (name === "prune_worktrees") {
          const out = run("git worktree prune");
          return { content: [{ type: "text", text: out || "OK" }] };
        }
      } catch (e) {
        return { content: [{ type: "text", text: String(e && e.stack ? e.stack : e) }] };
      }
      return { content: [{ type: "text", text: `Unknown tool: ${name}` }] };
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

new WorktreeManager().start().catch((err) => {
  console.error(err);
  process.exit(1);
});
