// @ts-check
import { escape } from 'lodash';

/**
 * Very limited implementation of sprintf supporting only named parameters.
 * @template {string} T
 * @param {T} input - (translated) text with parameters (e.g. '%{num_users} users use us')
 * @param {Record<string, string|number>} [parameters] - object mapping parameter names to values (e.g. { num_users: 5 })
 * @param {boolean} [escapeParameters=true] - whether parameter values should be escaped (see https://lodash.com/docs/4.17.15#escape)
 * @returns {T} the text with parameters replaces (e.g. '5 users use us')
 * @see https://ruby-doc.org/core-2.3.3/Kernel.html#method-i-sprintf
 * @see https://gitlab.com/gitlab-org/gitlab-foss/issues/37992
 */
export default function sprintf(input, parameters, escapeParameters = true) {
  /** @type {string} */
  let output = input;

  output = output.replace(/%+/g, '%');

  if (parameters) {
    const mappedParameters = new Map(Object.entries(parameters));

    mappedParameters.forEach((key, parameterName) => {
      const parameterValue = /** @type {string} */ (mappedParameters.get(parameterName));
      const escapedParameterValue = escapeParameters ? escape(parameterValue) : parameterValue;
      // Pass the param value as a function to ignore special replacement patterns like $` and $'.
      // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/replace#syntax
      output = output.replace(new RegExp(`%{${parameterName}}`, 'g'), () => escapedParameterValue);
    });
  }

  return /** @type{T} */ (output);
}
