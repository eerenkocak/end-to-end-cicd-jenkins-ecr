const assert = require('assert');
const app = require('./server');

console.log("Running CI unit tests...");
assert.strictEqual(typeof app, 'function', 'App must be a valid Express instance');
console.log("Unit tests passed!");
process.exit(0);
