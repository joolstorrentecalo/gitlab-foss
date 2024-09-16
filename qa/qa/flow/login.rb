# frozen_string_literal: true

module QA
  module Flow
    module Login
      extend self

      def while_signed_in(as: nil, address: :gitlab, admin: false)
        sign_in(as: as, address: address, admin: admin)

        result = yield

        Page::Main::Menu.perform(&:sign_out)
        result
      end

      def while_signed_in_as_admin(address: :gitlab, &block)
        while_signed_in(address: address, admin: true, &block)
      end

      def sign_in(as: nil, address: :gitlab, skip_page_validation: false, admin: false)
        Page::Main::Login.perform do |login|
          login.redirect_to_login_page(address)

          if admin
            login.sign_in_using_admin_credentials
          else
            login.sign_in_using_credentials(user: as, skip_page_validation: skip_page_validation)
          end
        end
      end

      def sign_in_as_admin(address: :gitlab)
        sign_in(as: Runtime::User.admin, address: address, admin: true)
      end

      def sign_in_unless_signed_in(user: nil, address: :gitlab)
        if user
          sign_in(as: user, address: address) unless signed_in_as?(user)
        else
          sign_in(address: address) unless signed_in?
        end
      end

      private

      def signed_in?
        Page::Main::Menu.perform(&:signed_in?)
      end

      def signed_in_as?(user)
        Page::Main::Menu.perform { |menu| menu.signed_in_as_user?(user) }
      end

      def verify_session
        return if signed_in?

        sign_in(address: :gitlab)
      end
    end
  end
end

# Wrap methods that require authentication with session verification
[:while_signed_in, :while_signed_in_as_admin, :sign_in_unless_signed_in].each do |method|
  original_method = QA::Flow::Login.method(method)
  QA::Flow::Login.define_singleton_method(method) do |*args, &block|
    result = original_method.call(*args, &block)
    verify_session
    result
  end
end

QA::Flow::Login.prepend_mod_with('Flow::Login', namespace: QA)
