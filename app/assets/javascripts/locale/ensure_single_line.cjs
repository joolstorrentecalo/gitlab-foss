const SPLIT_REGEX = /\s*[\r\n]+\s*/;

/**
 * Strips newlines from strings and replaces them with a single space.
 * @template {string} T
 * @param {T} str
 * @returns {T}
 * @example
 * ensureSingleLine('foo  \n  bar') // 'foo bar'
 */
function ensureSingleLine(str) {
  // This guard makes the function significantly faster
  if (str.includes('\n') || str.includes('\r')) {
    return /** @type {T} */(str
      .split(SPLIT_REGEX)
      .filter((s) => s !== '')
      .join(' '));
  }
  return /** @type {T} */ (str);
};

module.exports = ensureSingleLine;