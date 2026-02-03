#!/usr/bin/env node
/**
 * ci-runner MCP server
 * - Runs fixed CI entrypoint (scripts/ci/run_ci.sh) and returns exit code + tail of logs
 */

const { spawnSync } = require("child_process");
const path = require("path");

const { Server } = require("@modelcontextprotocol/sdk/server/index.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { CallToolRequestSchema, ListToolsRequestSchema } = require("@modelcontextprotocol/sdk/types.js");

function root() {
  const r = spawnSync("git", ["rev-parse", "--show-toplevel"], { encoding: "utf8" });
  if (r.status === 0) return (r.stdout || "").trim();
  return process.cwd();
}

class CiRunner {
  constructor() {
    this.server = new Server({ name: "ci-runner", version: "0.1.0" }, { capabilities: { tools: {} } });
    this.repoRoot = root();
    this.register();
  }

  register() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: "run_ci",
          description: "Run CI entrypoint (scripts/ci/run_ci.sh --mode ci)",
          inputSchema: {
            type: "object",
            properties: {
              mode: { type: "string", enum: ["ci", "test-only"], default: "ci" },
            },
          },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (req) => {
      const name = req.params.name;
      const args = req.params.arguments || {};
      if (name !== "run_ci") {
        return { content: [{ type: "text", text: `Unknown tool: ${name}` }] };
      }
      const mode = String(args.mode || "ci");
      const script = path.join(this.repoRoot, "scripts/ci/run_ci.sh");
      const r = spawnSync("bash", [script, "--mode", mode], { cwd: this.repoRoot, encoding: "utf8" });
      const combined = (r.stdout || "") + (r.stderr || "");
      const tail = combined.split(/\r?\n/).slice(-200).join("\n");
      const payload = { exitCode: r.status, tail };
      return { content: [{ type: "text", text: JSON.stringify(payload, null, 2) }] };
    });
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

new CiRunner().start().catch((err) => {
  console.error(err);
  process.exit(1);
});
