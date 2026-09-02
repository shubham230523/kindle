export function extractJson<T>(content: string | null | undefined): T {
  if (!content || content.trim().length === 0) {
    throw new Error('AI returned empty or null content. This usually happens if the model reaches its token limit or fails to follow the response format.');
  }

  const trimmedContent = content.trim();

  // 1. Try parsing the whole content first
  try {
    const parsed = JSON.parse(trimmedContent);
    if (parsed !== null && typeof parsed === 'object') {
      return parsed as T;
    }
  } catch (e) {
    // Continue
  }

  // 2. Try to find JSON inside markdown code blocks
  const codeBlockMatch = content.match(/```(?:json)?\s*([\s\S]*?)\s*```/);
  if (codeBlockMatch) {
    try {
      const parsed = JSON.parse(codeBlockMatch[1].trim());
      if (parsed !== null && typeof parsed === 'object') {
        return parsed as T;
      }
    } catch (e) {
      // Continue
    }
  }

  // 3. Recursive brace matching
  // We look for all '{' and try to find a matching '}' that forms a valid JSON object.
  const firstBraceIndex = content.indexOf('{');
  if (firstBraceIndex !== -1) {
    for (let i = content.length - 1; i > firstBraceIndex; i--) {
      if (content[i] === '}') {
        const potentialJson = content.substring(firstBraceIndex, i + 1);
        try {
          const parsed = JSON.parse(potentialJson);
          if (parsed !== null && typeof parsed === 'object') {
            return parsed as T;
          }
        } catch (e) {
          // Continue searching for a different closing brace
        }
      }
    }
  }

  // 4. Sanitize and try one last time (handle common issues like unescaped newlines in strings)
  // This is a bit risky but can save some responses.
  if (firstBraceIndex !== -1) {
    const lastBraceIndex = content.lastIndexOf('}');
    if (lastBraceIndex > firstBraceIndex) {
      let sanitized = content.substring(firstBraceIndex, lastBraceIndex + 1);
      // Replace unescaped newlines inside quotes
      sanitized = sanitized.replace(/"([^"]*)"/g, (match, p1) => {
        return '"' + p1.replace(/\n/g, '\\n').replace(/\r/g, '\\r') + '"';
      });
      try {
        const parsed = JSON.parse(sanitized);
        if (parsed !== null && typeof parsed === 'object') {
          return parsed as T;
        }
      } catch (e) {
        // Final failure
      }
    }
  }

  throw new Error('AI failed to provide a structured JSON response.');
}
