export function extractJson<T>(content: string | null | undefined): T {
  if (!content || content.trim().length === 0) {
    throw new Error('AI returned empty or null content.');
  }

  // 1. Clean markdown and artifacts
  let input = content.replace(/```json/g, '').replace(/```/g, '').trim();

  // 2. String-Aware JSON Block Extraction
  const start = input.indexOf('{');
  if (start !== -1) {
    let depth = 0;
    let inString = false;
    let escaped = false;
    let end = -1;

    for (let i = start; i < input.length; i++) {
      const char = input[i];
      if (escaped) {
        escaped = false;
        continue;
      }
      if (char === '\\') {
        escaped = true;
        continue;
      }
      if (char === '"') {
        inString = !inString;
        continue;
      }
      if (!inString) {
        if (char === '{') depth++;
        else if (char === '}') depth--;

        if (depth === 0) {
          end = i;
          break;
        }
      }
    }
    if (end !== -1) {
      input = input.substring(start, end + 1);
    }
  }

  // 3. State-machine to fix literal newlines in strings
  let buffer = '';
  let inString = false;
  let escaped = false;

  for (let i = 0; i < input.length; i++) {
    const char = input[i];
    if (inString) {
      if (escaped) {
        buffer += char;
        escaped = false;
      } else if (char === '\\') {
        buffer += char;
        escaped = true;
      } else if (char === '"') {
        buffer += char;
        inString = false;
      } else if (char === '\n') {
        buffer += '\\n';
      } else if (char === '\r') {
        buffer += '\\r';
      } else {
        buffer += char;
      }
    } else {
      if (char === '"') inString = true;
      buffer += char;
    }
  }
  input = buffer;

  // 4. Handle Dart/Coder hallucinations (raw strings)
  input = input.replace(/r"""([\s\S]*?)"""/g, (match, p1) => JSON.stringify(p1));
  input = input.replace(/r"([\s\S]*?)"/g, (match, p1) => JSON.stringify(p1));
  input = input.replace(/"""([\s\S]*?)"""/g, (match, p1) => JSON.stringify(p1));

  // 5. Remove trailing commas
  input = input.replace(/,\s*([\]}])/g, '$1');

  // 6. Final safety: If the JSON is truncated, try to close it
  if (!input.endsWith('}')) {
    if (input.split('"').length % 2 === 0) input += '"';
    const openBraces = (input.match(/{/g) || []).length;
    const closeBraces = (input.match(/}/g) || []).length;
    const openBrackets = (input.match(/\[/g) || []).length;
    const closeBrackets = (input.match(/\]/g) || []).length;
    for (let i = 0; i < (openBrackets - closeBrackets); i++) input += ']';
    for (let i = 0; i < (openBraces - closeBraces); i++) input += '}';
  }

  try {
    return JSON.parse(input) as T;
  } catch (e: any) {
    // 7. Heuristic fallback for Discovery Agent
    // If the model output a plain question instead of JSON, we can try to wrap it.
    if (content.includes('?') && content.length < 500) {
      console.log('[AI_UTILS] 💡 Applying heuristic recovery for plain-text question.');
      const recovery = {
        understandingSummary: "The user is clarifying their requirements.",
        currentQuestion: content.trim(),
        discoveredRequirements: [],
        missingInformation: [],
        confidence: 0.5,
        isDiscoveryComplete: false
      };
      return recovery as unknown as T;
    }

    console.error('[AI_UTILS] ❌ Extraction Error:', e.message);
    console.error('[AI_UTILS] 📄 Raw Content:', content);
    console.error('[AI_UTILS] 🔧 Processed Content:', input);
    throw new Error(`AI failed to provide a structured JSON response: ${e.message}`);
  }
}
