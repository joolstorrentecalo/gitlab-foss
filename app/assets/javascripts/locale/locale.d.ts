export type WithoutContext<T_1 extends string> = T_1 extends `${string}|${infer Key}` ? Key : T_1;
export const locale: Jed;
export function gettext<T_1 extends string>(text: T_1): T_1;
export function ngettext<T1 extends string, T2 extends string>(text: T1, pluralText: T2, count: number): WithoutContext<T1> | WithoutContext<T2>;
export function pgettext<T extends string>(keyOrContext: T): WithoutContext<T>;
export function pgettext<T extends string>(keyOrContext: string, key?: T | undefined): WithoutContext<T>;
import Jed from 'jed';
//# sourceMappingURL=locale.d.ts.map