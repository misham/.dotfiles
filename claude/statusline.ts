#!/usr/bin/env bun
// Rich multi-line statusline for Claude Code
// Reads JSON from stdin, outputs colored multi-line status

import * as fs from "fs";
import * as os from "os";
import * as path from "path";
import * as https from "https";
import * as readline from "readline";

// --- ANSI Colors ---
const BLUE = "\x1b[38;2;0;153;255m";
const ORANGE = "\x1b[38;2;255;176;85m";
const GREEN = "\x1b[38;2;0;160;0m";
const CYAN = "\x1b[38;2;46;149;153m";
const RED = "\x1b[38;2;255;85;85m";
const YELLOW = "\x1b[38;2;230;200;0m";
const DIM = "\x1b[2m";
const RESET = "\x1b[0m";

// --- Types ---
interface StdinData {
  model?: { id?: string; display_name?: string };
  context_window?: {
    context_window_size?: number;
    current_usage?: {
      input_tokens?: number;
      cache_creation_input_tokens?: number;
      cache_read_input_tokens?: number;
    };
  };
  transcript_path?: string;
  cwd?: string;
}

interface UsageApiResponse {
  five_hour?: { utilization?: number; resets_at?: string };
  seven_day?: { utilization?: number; resets_at?: string };
}

interface UsageData {
  fiveHour: number | null;
  sevenDay: number | null;
  fiveHourResetAt: string | null;
  sevenDayResetAt: string | null;
  apiUnavailable?: boolean;
}

interface CacheFile {
  data: UsageData;
  timestamp: number;
}

interface AgentEntry {
  id: string;
  type: string;
  description?: string;
  status: "running" | "completed";
  startTime: Date;
  endTime?: Date;
}

// --- Constants ---
const HOME = os.homedir();
const CACHE_PATH = "/tmp/claude-statusline-usage-cache.json";
const CREDENTIALS_PATH = path.join(HOME, ".claude", ".credentials.json");
const SETTINGS_PATH = path.join(HOME, ".claude", "settings.json");
const CACHE_TTL_MS = 60_000;
const CACHE_FAILURE_TTL_MS = 15_000;
const INTERNAL_TOOLS = new Set(["Task", "TodoWrite", "AskUserQuestion", "TodoRead", "TaskCreate", "TaskUpdate", "TaskList", "TaskGet", "EnterPlanMode", "ExitPlanMode"]);

// --- Helpers ---
function formatTokens(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}m`;
  if (n >= 1_000) return `${Math.round(n / 1_000)}k`;
  return n.toString();
}

function colorForContext(pct: number): string {
  if (pct >= 75) return RED;
  if (pct >= 40) return YELLOW;
  return GREEN;
}

function colorForUsage(pct: number): string {
  if (pct >= 90) return RED;
  if (pct >= 70) return YELLOW;
  if (pct >= 50) return ORANGE;
  return GREEN;
}

function buildBar(pct: number, colorFn: (p: number) => string): string {
  const width = 10;
  const filled = Math.round((pct / 100) * width);
  const empty = width - filled;
  const color = colorFn(pct);
  return `${color}${"●".repeat(filled)}${"○".repeat(empty)}${RESET}`;
}

function formatDuration(ms: number): string {
  const mins = Math.floor(ms / 60_000);
  if (mins < 60) return `${mins}m`;
  const hours = Math.floor(mins / 60);
  const remainMins = mins % 60;
  return remainMins > 0 ? `${hours}h ${remainMins}m` : `${hours}h`;
}

function formatAgentDuration(startTime: Date, endTime?: Date): string {
  const end = endTime ?? new Date();
  const diffMs = end.getTime() - startTime.getTime();
  const secs = Math.floor(diffMs / 1000);
  if (secs < 60) return `${secs}s`;
  const mins = Math.floor(secs / 60);
  const remainSecs = secs % 60;
  if (mins < 60) return remainSecs > 0 ? `${mins}m ${remainSecs}s` : `${mins}m`;
  const hours = Math.floor(mins / 60);
  const remainMins = mins % 60;
  return remainMins > 0 ? `${hours}h ${remainMins}m` : `${hours}h`;
}

function formatResetTime(isoStr: string | null): string {
  if (!isoStr) return "N/A";
  const date = new Date(isoStr);
  if (isNaN(date.getTime())) return "N/A";
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  const month = months[date.getMonth()];
  const day = date.getDate();
  let hours = date.getHours();
  const ampm = hours >= 12 ? "PM" : "AM";
  hours = hours % 12 || 12;
  const mins = date.getMinutes().toString().padStart(2, "0");
  return `${month} ${day} ${hours.toString().padStart(2, "0")}:${mins} ${ampm}`;
}

// --- Usage API ---
function readCache(): UsageData | null {
  try {
    if (!fs.existsSync(CACHE_PATH)) return null;
    const content = fs.readFileSync(CACHE_PATH, "utf8");
    const cache: CacheFile = JSON.parse(content);
    const ttl = cache.data.apiUnavailable ? CACHE_FAILURE_TTL_MS : CACHE_TTL_MS;
    if (Date.now() - cache.timestamp >= ttl) return null;
    return cache.data;
  } catch {
    return null;
  }
}

function writeCache(data: UsageData): void {
  try {
    fs.writeFileSync(CACHE_PATH, JSON.stringify({ data, timestamp: Date.now() }), "utf8");
  } catch {
    // ignore
  }
}

function getAccessToken(): { accessToken: string; subscriptionType: string } | null {
  // Try credentials file first
  try {
    if (fs.existsSync(CREDENTIALS_PATH)) {
      const content = fs.readFileSync(CREDENTIALS_PATH, "utf8");
      const data = JSON.parse(content);
      const oauth = data?.claudeAiOauth;
      if (oauth?.accessToken) {
        if (oauth.expiresAt != null && oauth.expiresAt <= Date.now()) return null;
        return { accessToken: oauth.accessToken, subscriptionType: oauth.subscriptionType ?? "" };
      }
    }
  } catch {
    // fall through to keychain
  }

  // Fallback: macOS Keychain
  try {
    const result = Bun.spawnSync(["security", "find-generic-password", "-s", "Claude Code-credentials", "-w"]);
    if (result.exitCode === 0) {
      const creds = JSON.parse(result.stdout.toString());
      const oauth = creds?.claudeAiOauth;
      if (oauth?.accessToken) {
        return { accessToken: oauth.accessToken, subscriptionType: oauth.subscriptionType ?? "" };
      }
    }
  } catch {
    // no credentials available
  }

  return null;
}

function fetchUsageApi(accessToken: string): Promise<UsageApiResponse | null> {
  return new Promise((resolve) => {
    const req = https.request(
      {
        hostname: "api.anthropic.com",
        path: "/api/oauth/usage",
        method: "GET",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "anthropic-beta": "oauth-2025-04-20",
          "User-Agent": "claude-statusline/1.0",
        },
        timeout: 5000,
      },
      (res) => {
        let data = "";
        res.on("data", (chunk: Buffer) => (data += chunk.toString()));
        res.on("end", () => {
          if (res.statusCode !== 200) { resolve(null); return; }
          try { resolve(JSON.parse(data)); } catch { resolve(null); }
        });
      }
    );
    req.on("error", () => resolve(null));
    req.on("timeout", () => { req.destroy(); resolve(null); });
    req.end();
  });
}

async function getUsageData(): Promise<UsageData | null> {
  const cached = readCache();
  if (cached) return cached;

  const creds = getAccessToken();
  if (!creds) return null;

  // Skip for API users
  const subType = creds.subscriptionType.toLowerCase();
  if (!subType || subType.includes("api")) return null;

  const response = await fetchUsageApi(creds.accessToken);
  if (!response) {
    const failure: UsageData = {
      fiveHour: null, sevenDay: null,
      fiveHourResetAt: null, sevenDayResetAt: null,
      apiUnavailable: true,
    };
    writeCache(failure);
    return failure;
  }

  const clamp = (v: number | undefined): number | null => {
    if (v == null || !Number.isFinite(v)) return null;
    return Math.round(Math.max(0, Math.min(100, v)));
  };

  const result: UsageData = {
    fiveHour: clamp(response.five_hour?.utilization),
    sevenDay: clamp(response.seven_day?.utilization),
    fiveHourResetAt: response.five_hour?.resets_at ?? null,
    sevenDayResetAt: response.seven_day?.resets_at ?? null,
  };
  writeCache(result);
  return result;
}

// --- Transcript parsing ---
interface TranscriptResult {
  toolCounts: Map<string, number>;
  agents: AgentEntry[];
  sessionStart?: Date;
}

async function parseTranscript(transcriptPath: string): Promise<TranscriptResult> {
  const result: TranscriptResult = { toolCounts: new Map(), agents: [] };
  if (!transcriptPath || !fs.existsSync(transcriptPath)) return result;

  try {
    const stream = fs.createReadStream(transcriptPath);
    const rl = readline.createInterface({ input: stream, crlfDelay: Infinity });
    const agentMap = new Map<string, AgentEntry>();

    for await (const line of rl) {
      if (!line.trim()) continue;
      try {
        const entry = JSON.parse(line);
        const timestamp = entry.timestamp ? new Date(entry.timestamp) : new Date();
        if (!result.sessionStart && entry.timestamp) result.sessionStart = timestamp;

        const content = entry.message?.content;
        if (!content || !Array.isArray(content)) continue;

        for (const block of content) {
          if (block.type === "tool_use" && block.id && block.name) {
            if (block.name === "Task") {
              agentMap.set(block.id, {
                id: block.id,
                type: block.input?.subagent_type ?? "unknown",
                description: block.input?.description,
                status: "running",
                startTime: timestamp,
              });
            } else if (!INTERNAL_TOOLS.has(block.name)) {
              result.toolCounts.set(block.name, (result.toolCounts.get(block.name) ?? 0) + 1);
            }
          }

          if (block.type === "tool_result" && block.tool_use_id) {
            const agent = agentMap.get(block.tool_use_id);
            if (agent) {
              agent.status = "completed";
              agent.endTime = timestamp;
            }
          }
        }
      } catch {
        // skip malformed lines
      }
    }

    result.agents = Array.from(agentMap.values()).slice(-10);
  } catch {
    // return partial results
  }

  return result;
}

// --- Main ---
async function main() {
  try {
    // Read stdin
    const chunks: Buffer[] = [];
    for await (const chunk of Bun.stdin.stream()) {
      chunks.push(Buffer.from(chunk));
    }
    const input: StdinData = JSON.parse(Buffer.concat(chunks).toString());

    const lines: string[] = [];

    // === Line 1: Model | tokens / total | % bar | thinking | duration ===
    const modelName = input.model?.display_name ?? "Unknown";
    const contextSize = input.context_window?.context_window_size ?? 0;
    const usage = input.context_window?.current_usage;
    const inputTokens = usage?.input_tokens ?? 0;
    const cacheCreation = usage?.cache_creation_input_tokens ?? 0;
    const cacheRead = usage?.cache_read_input_tokens ?? 0;
    const currentTokens = inputTokens + cacheCreation + cacheRead;
    const usedPct = contextSize > 0 ? Math.round((currentTokens / contextSize) * 100) : 0;

    const currentDisplay = formatTokens(currentTokens);
    const totalDisplay = formatTokens(contextSize);
    const contextBar = buildBar(usedPct, colorForContext);
    const contextColor = colorForContext(usedPct);

    // Thinking mode
    let thinkingStatus = `${DIM}Off${RESET}`;
    try {
      const settings = JSON.parse(fs.readFileSync(SETTINGS_PATH, "utf8"));
      if (settings.alwaysThinkingEnabled) thinkingStatus = `${ORANGE}On${RESET}`;
    } catch { /* ignore */ }

    // Parse transcript (needed for duration and tools/agents)
    const transcript = await parseTranscript(input.transcript_path ?? "");

    // Session duration
    let durationPart = "";
    if (transcript.sessionStart) {
      const elapsed = Date.now() - transcript.sessionStart.getTime();
      durationPart = ` ${DIM}|${RESET} ${DIM}\u23F1\uFE0F  ${formatDuration(elapsed)}${RESET}`;
    }

    lines.push(
      `${BLUE}${modelName}${RESET} ${DIM}|${RESET} ` +
      `${ORANGE}${currentDisplay}${RESET} ${DIM}/${RESET} ${ORANGE}${totalDisplay}${RESET} ${DIM}|${RESET} ` +
      `${contextColor}${usedPct}%${RESET} ${contextBar} ${DIM}|${RESET} ` +
      `thinking: ${thinkingStatus}${durationPart}`
    );

    // === Lines 2-3: Usage bars + Reset times ===
    const usageData = await getUsageData();
    if (usageData && !usageData.apiUnavailable && (usageData.fiveHour !== null || usageData.sevenDay !== null)) {
      const fiveHourPct = usageData.fiveHour ?? 0;
      const sevenDayPct = usageData.sevenDay ?? 0;
      const fiveHourBar = buildBar(fiveHourPct, colorForUsage);
      const sevenDayBar = buildBar(sevenDayPct, colorForUsage);

      lines.push(
        `${DIM}Current (5h):${RESET} ${fiveHourBar} ${CYAN}${fiveHourPct}%${RESET} ${DIM}|${RESET} ` +
        `${DIM}Weekly (7d):${RESET} ${sevenDayBar} ${CYAN}${sevenDayPct}%${RESET}`
      );

      lines.push(
        `${DIM}Resets:${RESET} ${CYAN}${formatResetTime(usageData.fiveHourResetAt)}${RESET} ${DIM}|${RESET} ` +
        `${DIM}Weekly:${RESET} ${CYAN}${formatResetTime(usageData.sevenDayResetAt)}${RESET}`
      );
    }

    // === Line 4: Tool counts ===
    if (transcript.toolCounts.size > 0) {
      const sorted = Array.from(transcript.toolCounts.entries()).sort((a, b) => b[1] - a[1]);
      const toolParts = sorted.map(([name, count]) => `${GREEN}\u2713${RESET} ${name} x${count}`);
      lines.push(toolParts.join(` ${DIM}|${RESET} `));
    }

    // === Lines 5+: Agent activity ===
    for (const agent of transcript.agents) {
      const icon = agent.status === "running" ? `${CYAN}\u25D0${RESET}` : `${GREEN}\u2713${RESET}`;
      const dur = formatAgentDuration(agent.startTime, agent.endTime);
      const desc = agent.description ? `: ${agent.description}` : "";
      lines.push(`${icon} ${CYAN}${agent.type}${RESET}${desc} ${DIM}(${dur})${RESET}`);
    }

    process.stdout.write(lines.join("\n"));
  } catch (err) {
    // Always output something
    process.stdout.write("Claude");
  }
}

main();
