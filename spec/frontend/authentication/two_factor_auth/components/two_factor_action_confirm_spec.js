import { GlFormGroup, GlModal } from '@gitlab/ui';
import { mountExtended, shallowMountExtended } from 'helpers/vue_test_utils_helper';
import TwoFactorActionConfirm from '~/authentication/two_factor_auth/components/two_factor_action_confirm.vue';
import PasswordInput from '~/authentication/password/components/password_input.vue';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';

jest.mock('~/lib/utils/csrf', () => ({ token: 'mock-csrf-token' }));

const defaultProps = {
  message: 'my message',
  path: '/my/path',
  passwordRequired: true,
  title: 'My title',
};

describe('TwoFactorActionConfirm', () => {
  let wrapper;

  const createComponent = (options = {}, mount = shallowMountExtended) => {
    wrapper = mount(TwoFactorActionConfirm, {
      propsData: {
        ...defaultProps,
        ...options,
      },
      directives: {
        GlTooltip: createMockDirective('gl-tooltip'),
      },
    });
  };

  const findButton = () => wrapper.findByTestId('2fa-action-button');
  const findModal = () => wrapper.findComponent(GlModal);
  const findForm = () => wrapper.find('form');
  const findPasswordInput = () => wrapper.findComponent(PasswordInput);
  const findFormGroup = () => wrapper.findComponent(GlFormGroup);

  beforeEach(() => {
    createComponent();
  });

  describe('Initial button', () => {
    describe('when textual button', () => {
      it('renders default text', () => {
        expect(findButton().text()).toBe('Delete');
      });

      it('renders custom text', () => {
        const buttonText = 'Custom text';
        createComponent({ buttonText });

        expect(findButton().text()).toBe(buttonText);
      });

      it('renders default `danger` variant', () => {
        expect(findButton().props('variant')).toBe('danger');
      });

      it('renders custom variant', () => {
        const variant = 'confirm';
        createComponent({ variant });

        expect(findButton().props('variant')).toBe(variant);
      });

      it('renders custom classes', () => {
        const classes = 'hello world';
        createComponent({ classes });

        expect(findButton().attributes('class')).toBe(classes);
      });

      it('renders the modal when button is clicked', async () => {
        createComponent({}, mountExtended);
        expect(findModal().props('visible')).toBe(false);

        await findButton().trigger('click');

        expect(findModal().props('visible')).toBe(true);
      });
    });

    describe('when icon button', () => {
      const icon = 'remove';

      beforeEach(() => {
        createComponent({ icon });
      });

      it('renders icon', () => {
        expect(findButton().props('icon')).toBe(icon);
      });

      it('renders default tooltip', () => {
        const button = findButton();
        const tooltip = getBinding(button.element, 'gl-tooltip');

        expect(button.attributes('title')).toBe('Delete');
        expect(tooltip).toBeDefined();
      });

      it('renders custom tooltip', () => {
        const buttonText = 'Custom text';
        createComponent({ icon, buttonText });

        const button = findButton();
        const tooltip = getBinding(button.element, 'gl-tooltip');

        expect(button.attributes('title')).toBe(buttonText);
        expect(tooltip).toBeDefined();
      });

      it('renders default `danger` variant', () => {
        expect(findButton().props('variant')).toBe('danger');
      });

      it('renders custom variant', () => {
        const variant = 'confirm';
        createComponent({ icon, variant });

        expect(findButton().props('variant')).toBe(variant);
      });

      it('renders custom classes', () => {
        const classes = 'hello world';
        createComponent({ icon, classes });

        expect(findButton().attributes('class')).toBe(classes);
      });

      it('renders the modal when button is clicked', async () => {
        createComponent({ icon: 'remove' }, mountExtended);
        expect(findModal().props('visible')).toBe(false);

        await findButton().trigger('click');

        expect(findModal().props('visible')).toBe(true);
      });
    });
  });

  describe('Modal', () => {
    it('renders a title', () => {
      expect(findModal().props('title')).toBe(defaultProps.title);
    });

    it('renders in small size', () => {
      expect(findModal().props('size')).toBe('sm');
    });

    it('renders a primary action button with default text and variant', () => {
      expect(findModal().props('actionPrimary').text).toBe('Delete');
      expect(findModal().props('actionPrimary').attributes.variant).toBe('danger');
    });

    it('renders a primary action button with custom text and no variant', () => {
      const buttonText = 'My text';
      createComponent({ buttonText, variant: 'default' });

      expect(findModal().props('actionPrimary').text).toBe(buttonText);
      expect(findModal().props('actionPrimary').attributes).toBeUndefined();
    });

    it('renders a cancel action button with default text', () => {
      expect(findModal().props('actionCancel').text).toBe('Cancel');
    });

    it('renders a message', () => {
      expect(findModal().text()).toBe(defaultProps.message);
    });
  });

  describe('Form', () => {
    it('contains action attribute', () => {
      expect(findForm().attributes('action')).toBe(defaultProps.path);
    });

    it('renders a default hidden `_method` input', () => {
      expect(findForm().find('input[type="hidden"][name="_method"]').attributes('value')).toBe(
        'delete',
      );
    });

    it('renders a custom hidden `_method` input', () => {
      const method = 'post';
      createComponent({ method });

      expect(findForm().find('input[type="hidden"][name="_method"]').attributes('value')).toBe(
        method,
      );
    });

    it('renders hidden CSRF input', () => {
      expect(
        findForm().find('input[type="hidden"][name="authenticity_token"]').attributes('value'),
      ).toBe('mock-csrf-token');
    });
  });

  describe('when password is required', () => {
    it('renders a password input field', () => {
      expect(findFormGroup().attributes('label')).toBe('Current password');
      expect(findPasswordInput().exists()).toBe(true);
    });

    it('does not submit the form without password', () => {
      const submitSpy = jest.spyOn(findForm().element, 'submit');
      const preventDefault = jest.fn();
      findForm().element.current_password = { value: '' };
      findModal().vm.$emit('primary', { preventDefault });

      expect(preventDefault).toHaveBeenCalled();
      expect(submitSpy).not.toHaveBeenCalled();
    });

    it('submits the form with password', () => {
      const submitSpy = jest.spyOn(findForm().element, 'submit');
      const preventDefault = jest.fn();
      findForm().element.current_password = { value: '123' };
      findModal().vm.$emit('primary', { preventDefault });

      expect(preventDefault).toHaveBeenCalled();
      expect(submitSpy).toHaveBeenCalled();
    });
  });

  describe('when password is not required', () => {
    beforeEach(() => {
      createComponent({ passwordRequired: false });
    });

    it('does not render password input field', () => {
      createComponent({ passwordRequired: false });

      expect(findPasswordInput().exists()).toBe(false);
    });

    it('submits the form without password', () => {
      const submitSpy = jest.spyOn(findForm().element, 'submit');
      const preventDefault = jest.fn();
      findModal().vm.$emit('primary', { preventDefault });

      expect(preventDefault).toHaveBeenCalled();
      expect(submitSpy).toHaveBeenCalled();
    });
  });
});
