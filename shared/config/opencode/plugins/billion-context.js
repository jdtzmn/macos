// billion-context's native OpenCode plugin. OpenCode 2.x can't load the bare package
// name (billion-context#3976), so re-export its plugin entry from the bun global install
// managed by shared/npm-cli-packages.nix. Don't run `bili plugin install opencode`: it
// rewrites this config with machine-specific paths.
import { homedir } from "node:os";
import { join } from "node:path";
import { pathToFileURL } from "node:url";

const globalDir = process.env.BUN_INSTALL_GLOBAL_DIR || join(homedir(), ".bun/install/global");
const entry = join(globalDir, "node_modules/billion-context/dist/agent/opencode-native.js");
const mod = await import(pathToFileURL(entry).href);

export default mod.default;
