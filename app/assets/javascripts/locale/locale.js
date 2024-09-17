// @ts-check
import Jed from 'jed';
import ensureSingleLine from './ensure_single_line.cjs';

/**
 * @template {string} T
 * @typedef {T extends `${string}|${infer Key}` ? Key : T} WithoutContext
 */

/**
 * This file might be imported into a web worker indirectly, the `window` object
 * won't be defined in the web worker context so we need to check if it is defined
 * before we access the `translations` property.
 */
const translations = typeof window !== 'undefined' && window.translations;
const locale = new Jed(translations || {});
if (translations) {
  delete window.translations;
}

/**
 * Translates `text`.
 * @template {string} T
 * @param {T} text - The text to be translated
 * @returns {T} The translated text
 */
const gettext = (text) => locale.gettext(ensureSingleLine(text));

/**
 * Translate the text with a number.
 *
 * If the number is more than 1 it will use the `pluralText` translation.
 * This method allows for contexts, see below re. contexts
 * @template {string} T1
 * @template {string} T2
 * @param {T1} text - Singular text to translate (e.g. '%d day')
 * @param {T2} pluralText - Plural text to translate (e.g. '%d days')
 * @param {number} count - Number to decide which translation to use (e.g. 2)
 * @returns {WithoutContext<T1> | WithoutContext<T2>} Translated text with the number replaced (e.g. '2 days')
 */
const ngettext = (text, pluralText, count) => {
  const translated = locale
    .ngettext(ensureSingleLine(text), ensureSingleLine(pluralText), count)
    .replace(/%d/g, count)
    .split('|');

  return translated[translated.length - 1];
};

/**
 * @template {string} T
 * @overload
 * @param {T} keyOrContext - Context and a key to translation (e.g. 'Context|Text')
 * @returns {WithoutContext<T>} Translated context based text
 */
/**
 * @template {string} T
 * @overload
 * @param {string} keyOrContext - Context to translation
 * @param {T} [key] - Key to translation
 * @returns {WithoutContext<T>} Translated context based text
 */
/**
 * Translate context based text.
 * @param {string} keyOrContext - Context or Context|key to translation
 * @param {string} [key] - Key to translation
 * @returns {string} Translated context based text
 *
 * @example
 * gettext('Context|Text') // 'Text'
 * @example
 * gettext('Context', 'Text') // 'Text'
 */
const pgettext = (keyOrContext, key) => {
  const normalizedKey = ensureSingleLine(key ? `${keyOrContext}|${key}` : keyOrContext);
  const translated = gettext(normalizedKey).split('|');

  return translated[translated.length - 1];
};

export { locale, gettext, ngettext, pgettext };
