import { mount, WrapperArray } from '@vue/test-utils';
import Vue from 'vue';
import locale from '~/locale';
import Translate from '~/vue_shared/translate';
import Component from './translate_spec.vue';

/**
 * Huh. It seems like that findAll behave differently in the Vue Utils for Vue2 and Vue3.
 *
 * The Vue2 Version is not iterable and exposes the actual elements under .wrappers.
 *
 * Wonder if we should do it like this and where to put it and whether there are more instances of
 *
 * findAll
 */
if (!WrapperArray.prototype[Symbol.iterator]) {
  WrapperArray.prototype[Symbol.iterator] = function iterator() {
    let index = -1;
    const elements = this.wrappers;
    return {
      next() {
        index += 1;
        return { done: index >= elements.length, value: elements[index] };
      },
    };
  };
}

Vue.use(Translate);

describe('Vue translate filter', () => {
  let oldDomain;
  let oldData;

  beforeAll(() => {
    oldDomain = locale.textdomain();
    oldData = locale.options.locale_data;

    locale.textdomain('app');
    locale.options.locale_data = {
      app: {
        '': {
          domain: 'app',
          lang: 'vo',
          plural_forms: 'nplurals=2; plural=(n != 1);',
        },
        singular: ['singular_translated'],
        plural: ['plural_singular translation', 'plural_multiple translation'],
        '%d day': ['%d singular translated', '%d plural translated'],
        'Context|Foobar': ['Context|Foobar translated'],
        'multiline string': ['multiline string translated'],
        'multiline plural': ['multiline string singular', 'multiline string plural'],
        'Context| multiline string': ['multiline string with context'],
      },
    };
  });

  afterAll(() => {
    locale.textdomain(oldDomain);
    locale.options.locale_data = oldData;
  });

  it('works properly', async () => {
    const wrapper = await mount(Component);

    // vue3 vs vue2
    const spans = wrapper.findAll('span');

    // Just to ensure that the rendering actually worked;
    expect(spans.length).toBe(10);

    for (const span of spans) {
      expect(span.text().trim()).toBe(span.attributes()['data-expected']);
    }
  });
});
