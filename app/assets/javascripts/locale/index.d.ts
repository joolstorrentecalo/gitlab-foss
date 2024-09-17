export function getPreferredLocales(): string[];
export default locale;
export function languageCode(): string;
import { gettext } from './locale';
import { ngettext } from './locale';
import { pgettext } from './locale';
import sprintf from './sprintf';
export function createDateTimeFormat(formatOptions?: Intl.DateTimeFormatOptions | undefined): Intl.DateTimeFormat;
export function formatNumber(value: number, options?: Intl.NumberFormatOptions | undefined, langCode?: string | string[] | undefined): string;
import { locale } from './locale';
export { gettext as __, ngettext as n__, pgettext as s__, sprintf };
//# sourceMappingURL=index.d.ts.map