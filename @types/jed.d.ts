declare module 'jed' {
  export default class Jed {
    constructor(translations: Record<string, string>);
    gettext: any;
    ngettext: any;
    pgettext: any;
  }
}
