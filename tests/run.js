// Runs every fixture in tests/fixtures/*.json against core/sisula.js.
// Usage: node tests/run.js
//
// A fixture is { name, template, bindings, expected }. `bindings` is a JSON value; it is
// serialised before being handed to sisulate(), exactly as a host would.
const fs = require('fs');
const path = require('path');
const sisulate = require('../core/sisula.js');

const dir = path.join(__dirname, 'fixtures');
let passed = 0;
let failed = 0;

for (const file of fs.readdirSync(dir).filter(f => f.endsWith('.json')).sort()) {
    const cases = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'));
    for (const c of cases) {
        const actual = sisulate(c.template, JSON.stringify(c.bindings));
        if (actual === c.expected) {
            passed++;
        } else {
            failed++;
            console.log(`FAIL ${file}: ${c.name}`);
            console.log('  expected: ' + JSON.stringify(c.expected));
            console.log('  actual:   ' + JSON.stringify(actual));
        }
    }
}

console.log(`${passed} passed, ${failed} failed`);
process.exit(failed ? 1 : 0);
