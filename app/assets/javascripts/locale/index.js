// @ts-check
import sprintf from './sprintf';
import { locale, gettext, ngettext, pgettext } from './locale';

const GITLAB_FALLBACK_LANGUAGE = 'en';

const languageCode = () =>
  document.querySelector('html')?.getAttribute('lang') || GITLAB_FALLBACK_LANGUAGE;

/**
 * Filters navigator languages by the set GitLab language.
 *
 * This allows us to decide better what a user wants as a locale, for using with the Intl browser APIs.
 * If they have set their GitLab to a language, it will check whether `navigator.languages` contains matching ones.
 * This function always adds `en` as a fallback in order to have date renders if all fails before it.
 *
 * - Example one: GitLab language is `en` and browser languages are:
 *   `['en-GB', 'en-US']`. This function returns `['en-GB', 'en-US', 'en']` as
 *   the preferred locales, the Intl APIs would try to format first as British English,
 *   if that isn't available US or any English.
 * - Example two: GitLab language is `en` and browser languages are:
 *   `['de-DE', 'de']`. This function returns `['en']`, so the Intl APIs would prefer English
 *   formatting in order to not have German dates mixed with English GitLab UI texts.
 *   If the user wants for example British English formatting (24h, etc),
 *   they could set their browser languages to `['de-DE', 'de', 'en-GB']`.
 * - Example three: GitLab language is `de` and browser languages are `['en-US', 'en']`.
 *   This function returns `['de', 'en']`, aligning German dates with the chosen translation of GitLab.
 *
 * @returns {string[]}
 */
export const getPreferredLocales = () => {
  const gitlabLanguage = languageCode();
  // The GitLab language may or may not contain a country code,
  // so we create the short version as well, e.g. de-AT => de
  const lang = gitlabLanguage.substring(0, 2);
  const locales = navigator.languages.filter((l) => l.startsWith(lang));
  if (!locales.includes(gitlabLanguage)) {
    locales.push(gitlabLanguage);
  }
  if (!locales.includes(lang)) {
    locales.push(lang);
  }
  if (!locales.includes(GITLAB_FALLBACK_LANGUAGE)) {
    locales.push(GITLAB_FALLBACK_LANGUAGE);
  }
  return locales;
};

/**
 * Creates an instance of Intl.DateTimeFormat for the current locale.
 * @param {Intl.DateTimeFormatOptions} [formatOptions] - for available options, please see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/DateTimeFormat
 * @returns {Intl.DateTimeFormat}
 */
const createDateTimeFormat = (formatOptions) =>
  Intl.DateTimeFormat(getPreferredLocales(), formatOptions);

/**
 * Formats a number as a string using `toLocaleString`.
 * @param {number} value - number to be converted
 * @param {Intl.NumberFormatOptions} [options] - options to be passed to
 * `toLocaleString`.
 * @param {string|string[]} [langCode] - If set, forces a different
 * language code from the one currently in the document.
 * @see https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/NumberFormat/NumberFormat
 *
 * @returns If value is a number, the formatted value as a string
 */
function formatNumber(value, options = {}, langCode = languageCode()) {
  if (typeof value !== 'number' && typeof value !== 'bigint') {
    return value;
  }
  return value.toLocaleString(langCode, options);
}

export { languageCode };
export { gettext as __ };
export { ngettext as n__ };
export { pgettext as s__ };
export { sprintf };
export { createDateTimeFormat };
export { formatNumber };
export default locale;
