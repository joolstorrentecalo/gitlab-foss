import fuzzaldrinPlus from 'fuzzaldrin-plus';
import { MAX_LIST_SIZE } from '~/issues/list/constants';
import axios from '~/lib/utils/axios_utils';

export class AutocompleteCache {
  constructor() {
    this.cache = {};
    this.sources = new Map();
    this.mutators = new Map();
    this.formatters = new Map();
    this.searchProperties = new Map();
  }

  setUpCache({ url, name, property, mutator, formatter }) {
    this.sources.set(name, url);
    this.mutators.set(name, mutator);
    this.formatters.set(name, formatter);
    this.searchProperties.set(name, property);
  }

  async fetch({ url, cacheName, searchProperty, search, mutator, formatter }) {
    const hasCache = Boolean(this.cache[cacheName]);

    this.setUpCache({ url, name: cacheName, property: searchProperty, mutator, formatter });

    if (!hasCache) {
      await this.updateLocalCache(cacheName);
    }

    return this.retrieveFromLocalCache(cacheName, search);
  }

  async updateLocalCache(name) {
    const url = this.sources.get(name);
    const mutator = this.mutators.get(name);

    return axios.get(url).then(({ data }) => {
      let finalData = data;

      if (mutator) {
        finalData = mutator(finalData);
      }

      this.cache[name] = finalData;
    });
  }

  retrieveFromLocalCache(name, search) {
    const searchProperty = this.searchProperties.get(name);
    const formatter = this.formatters.get(name);
    let result = search
      ? fuzzaldrinPlus.filter(this.cache[name], search, { key: searchProperty })
      : this.cache[name].slice(0, MAX_LIST_SIZE);

    if (formatter) {
      result = formatter(result);
    }

    return result;
  }
}
