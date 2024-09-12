const { defineTemplateBodyVisitor } = require('./utils/eslint_parsing_utils');

module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallows the use of deprecated utility classes',
    },
  },
  create(context) {
    return defineTemplateBodyVisitor(context, {
      VLiteral(node) {
        // Target VLiteral nodes within Vue templates
        const deprecatedClasses = {
          'gl-text-primary': 'gl-text-default',
          'gl-text-secondary': 'gl-text-subtle',
        };

        if (Object.hasOwn(deprecatedClasses, node.value)) {
          context.report({
            node,
            message: 'Deprecated class `{{ deprecatedClass }}`. Migrate to `{{ replacement }}`.',
            data: {
              deprecatedClass: node.value,
              replacement: deprecatedClasses[node.value],
            },
          });
        }
      },
    });
  },
};
