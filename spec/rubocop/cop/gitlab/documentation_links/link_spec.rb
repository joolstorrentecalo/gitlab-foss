# frozen_string_literal: true

require 'rubocop_spec_helper'
require_relative '../../../../../rubocop/cop/gitlab/documentation_links/link'

RSpec.describe RuboCop::Cop::Gitlab::DocumentationLinks::Link, feature_category: :navigation do
  using RSpec::Parameterized::TableSyntax

  context 'when no argument is passed' do
    it 'does not register any offenses' do
      expect_no_offenses("help_page_path")
    end
  end

  context 'when the path is valid' do
    before do
      allow(File).to receive(:exist?).and_return(true)
    end

    where(:code) do
      [
        "help_page_path('/this/file/exists.md')",
        "help_page_url('/this/file/exists.md')"
      ]
    end

    with_them do
      it 'does not register any offenses' do
        expect_no_offenses(code)
      end
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
            "help_page_path('/this/file/exists.md#primary-heading')",
            "help_page_path('/this/file/exists.md#this-anchor-exists')",
            "help_page_path('/this/file/exists.md#this-anchor-exists-1')",
            "help_page_path('/this/file/exists.md', anchor: 'this-anchor-exists')",
            "help_page_path('/this/file/exists.md', anchor: 'this-anchor-exists-1')",
            "help_page_path('/this/file/exists.md', anchor: 'my-custom-id')",
            "help_page_url('/this/file/exists.md#primary-heading')"
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
            "help_page_path('/this/file/exists.md#this-anchor-does-not-exist')",
            "help_page_path('/this/file/exists.md', anchor: 'this-anchor-does-not-exist')",
            "help_page_url('/this/file/exists.md#this-anchor-does-not-exist')"
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
          expect_offense(<<~'RUBY', code: "help_page_path('/this/file/exists.md', anchor: anchor_variable)")
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
    end

    where(:code) do
      [
        "help_page_path('/this/file/does/not/exist.md')",
        "help_page_path('/this/file/does/not/exist.md#some-anchor')",
        "help_page_path('/this/file/does/not/exist.md', anchor: 'some-anchor')",
        "help_page_url('/this/file/does/not/exist.md')"
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

    context 'when the path does not include the .md file extension' do
      where(:path, :correction) do
        '/this/path/lacks/md/extension' | '/this/path/lacks/md/extension.md'
        '/this/path/lacks/md/extension.html' | '/this/path/lacks/md/extension.md'
        '/this/path/lacks/md/extension#anchor' | '/this/path/lacks/md/extension.md#anchor'
        '/this/path/lacks/md/extension.html#anchor' | '/this/path/lacks/md/extension.md#anchor'
      end

      with_them do
        it 'registers an offense and corrects' do
          expect_offense(<<~'RUBY', code: "help_page_path('#{path}')")
            %{code}
            ^{code} Add .md extension to the link: [...]
          RUBY

          expect_correction("help_page_path('#{correction}')\n")
        end
      end
    end
  end
end
