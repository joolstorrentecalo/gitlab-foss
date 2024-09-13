# frozen_string_literal: true

require 'rubocop_spec_helper'
require_relative '../../../../rubocop/cop/help_page_path/ensure_valid_links'

RSpec.describe RuboCop::Cop::HelpPagePath::EnsureValidLinks, feature_category: :navigation do
  context 'when the path is valid' do
    before do
      allow(File).to receive(:exist?).and_return(true)
    end

    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY)
        help_page_path('/this/file/exists')
      RUBY
    end

    describe 'anchors' do
      before do
        allow(File).to receive(:read).and_return(<<~MARKDOWN)
          # Primary heading

          Intro

          ## This anchor exists

          Content

          ## This anchor exists

          More content

          ## This one has a custom ID {#my-custom-id}
        MARKDOWN
      end

      context 'when the anchor is valid' do
        where(:code) do
          [
            "help_page_path('/this/file/exists#primary-heading')",
            "help_page_path('/this/file/exists#this-anchor-exists')",
            "help_page_path('/this/file/exists#this-anchor-exists-1')",
            "help_page_path('/this/file/exists', anchor: 'this-anchor-exists')",
            "help_page_path('/this/file/exists', anchor: 'this-anchor-exists-1')",
            "help_page_path('/this/file/exists', anchor: 'my-custom-id')"
          ]
        end

        with_them do
          it 'does not register any offenses' do
            expect_no_offenses(code)
          end
        end
      end

      context 'when the anchor is invalid' do
        where(:code) do
          [
            "help_page_path('/this/file/exists#this-anchor-does-not-exist')",
            "help_page_path('/this/file/exists', anchor: 'this-anchor-does-not-exist')"
          ]
        end

        with_them do
          it 'registers an offense' do
            expect_offense(<<~'RUBY', code: code)
              %{code}
              ^{code} The anchor `#this-anchor-does-not-exist` was not found in [...]
            RUBY
          end
        end
      end

      context 'when the anchor is not a string' do
        it 'registers an offense' do
          expect_offense(<<~'RUBY', code: "help_page_path('/this/file/exists', anchor: anchor_variable)")
            %{code}
            ^{code} `help_page_path`'s `anchor` argument must be passed as a string [...]
          RUBY
        end
      end
    end
  end

  context 'when the path is invalid' do
    before do
      allow(File).to receive(:exists).and_return(false)
      # allow(File).to receive(:absolute_path).and_return('/this/file/does/not/exist')
    end

    where(:code) do
      [
        "help_page_path('/this/file/does/not/exist')",
        "help_page_path('/this/file/does/not/exist#some-anchor')",
        "help_page_path('/this/file/does/not/exist', anchor: 'some-anchor')"
      ]
    end

    with_them do
      it 'registers an offense' do
        expect_offense(<<~'RUBY', code: code)
          %{code}
          ^{code} This file does not exist: [...]
        RUBY
      end
    end

    context 'when the path is not a string' do
      it 'registers an offense' do
        expect_offense(<<~'RUBY', code: "help_page_path(path_variable)")
          %{code}
          ^{code} `help_page_path`'s first argument must be passed as a string [...]
        RUBY
      end
    end
  end
end
