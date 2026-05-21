/**
 * Push custom code to FlutterFlow (same API as FlutterFlow: Push to FlutterFlow).
 */
import { createRequire } from 'module';
import path from 'path';
import fs from 'fs';
import crypto from 'crypto';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const projectRoot = path.resolve(__dirname, '..');
const extRoot = path.join(
  process.env.USERPROFILE || '',
  '.cursor',
  'extensions',
  'flutterflow.flutterflow-custom-code-editor-1.2.8',
);
const require = createRequire(path.join(extRoot, 'package.json'));
const AdmZip = require('adm-zip');

const FILES_TO_PUSH = [
  'lib/custom_code/actions/pause_resume_turno.dart',
  'lib/custom_code/actions/stop_turno.dart',
];

function loadApiKey() {
  const settingsPath = path.join(
    process.env.APPDATA || '',
    'Cursor',
    'User',
    'settings.json',
  );
  const settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
  const token = settings['flutterflow.userApiToken'];
  if (!token) {
    throw new Error('flutterflow.userApiToken not set in Cursor User settings');
  }
  return token;
}

function sha256File(filePath) {
  return crypto.createHash('sha256').update(fs.readFileSync(filePath)).digest('hex');
}

function parseActionIndex(indexContent) {
  const map = new Map();
  const re = /export\s+'([^']+)'\s+show\s+(\w+)/g;
  let m;
  while ((m = re.exec(indexContent)) !== null) {
    map.set(m[1], m[2]);
  }
  return map;
}

function buildFileMap() {
  const indexPath = path.join(
    projectRoot,
    'lib/custom_code/actions/index.dart',
  );
  const index = parseActionIndex(fs.readFileSync(indexPath, 'utf8'));
  const fileMap = {};

  for (const [filename, exportName] of index) {
    const full = path.join(projectRoot, 'lib/custom_code/actions', filename);
    const checksum = fs.existsSync(full) ? sha256File(full) : undefined;
    const entry = {
      old_identifier_name: exportName,
      new_identifier_name: exportName,
      type: 'A',
      is_deleted: false,
      current_checksum: checksum,
    };
    if (FILES_TO_PUSH.some((p) => p.endsWith(filename))) {
      // New/changed: no original_checksum → included in push zip
    } else if (checksum) {
      entry.original_checksum = checksum;
    }
    fileMap[filename] = entry;
  }

  const cfPath = path.join(projectRoot, 'lib/flutter_flow/custom_functions.dart');
  const cfHash = sha256File(cfPath);
  fileMap['custom_functions.dart'] = {
    old_identifier_name: 'CustomFunctions',
    new_identifier_name: 'CustomFunctions',
    type: 'F',
    is_deleted: false,
    original_checksum: cfHash,
    current_checksum: cfHash,
  };

  return fileMap;
}

async function push() {
  const metadata = JSON.parse(
    fs.readFileSync(path.join(projectRoot, '.vscode/ff_metadata.json'), 'utf8'),
  );
  const apiKey = process.env.FF_API_TOKEN || loadApiKey();
  const apiUrl = process.env.FF_API_URL || 'https://api.flutterflow.io/v1';
  const projectId = metadata.project_id;
  const branchName = metadata.branch_name || '';

  const zip = new AdmZip();
  for (const rel of FILES_TO_PUSH) {
    const abs = path.join(projectRoot, rel);
    if (!fs.existsSync(abs)) {
      throw new Error(`Missing file: ${rel}`);
    }
    zip.addLocalFile(abs);
    console.log(`Zipping: ${rel}`);
  }

  const pubspec = fs.readFileSync(path.join(projectRoot, 'pubspec.yaml'), 'utf8');
  const fileMap = buildFileMap();
  const functionsMap = {
    functions_to_rename: [],
    functions_to_delete: [],
    functions_to_add: [],
  };

  const body = {
    project_id: projectId,
    zipped_custom_code: zip.toBuffer().toString('base64'),
    uid: crypto.randomUUID(),
    branch_name: branchName,
    serialized_yaml: pubspec,
    file_map: JSON.stringify(fileMap),
    functions_map: JSON.stringify(functionsMap),
  };

  console.log(`POST syncCustomCodeChanges → ${projectId} (branch: "${branchName || 'main'}")`);

  const response = await fetch(`${apiUrl}/syncCustomCodeChanges`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify(body),
  });

  const text = await response.text();
  let json;
  try {
    json = JSON.parse(text);
  } catch {
    throw new Error(`Non-JSON response (${response.status}): ${text.slice(0, 500)}`);
  }

  if (!response.ok) {
    console.error('Push failed:', JSON.stringify(json, null, 2));
    process.exit(1);
  }

  const valueObject =
    typeof json.value === 'string' ? JSON.parse(json.value) : json.value;
  const errors = Object.entries(valueObject || {});
  if (errors.length === 0) {
    console.log('Push completed successfully.');
    return;
  }

  let critical = false;
  for (const [file, warnings] of errors) {
    for (const w of warnings) {
      const msg = w.errorMessage || w;
      const crit = w.isCritical === true;
      console.log(`${file}: [${crit ? 'CRITICAL' : 'warn'}] ${msg}`);
      if (crit) {
        critical = true;
      }
    }
  }

  if (critical) {
    process.exit(1);
  }
  console.log('Push completed with warnings.');
}

push().catch((err) => {
  console.error(err);
  process.exit(1);
});
