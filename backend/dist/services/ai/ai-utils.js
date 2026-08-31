export function extractJson(content) {
    try {
        return JSON.parse(content);
    }
    catch (parseError) {
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            try {
                return JSON.parse(jsonMatch[0]);
            }
            catch (innerError) {
                throw new Error('AI returned invalid JSON structure.');
            }
        }
        throw new Error('AI failed to provide a structured JSON response.');
    }
}
