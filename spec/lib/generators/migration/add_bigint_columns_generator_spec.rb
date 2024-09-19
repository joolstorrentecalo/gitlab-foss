# frozen_string_literal: true

require 'spec_helper'
require 'rails/generators/testing/assertions'

if ::Gitlab.next_rails?
  require 'rails/generators/testing/behavior'
else
  require 'rails/generators/testing/behaviour'
end

RSpec.describe Migration::AddBigintColumnsGenerator, feature_category: :database do
  include Rails::Generators::Testing::Behaviour
  include Rails::Generators::Testing::Assertions
  include FileUtils

  tests described_class
  destination File.expand_path('tmp', __dir__)

  before do
    prepare_destination
    allow(Gitlab).to receive(:version_info).and_return(Gitlab::VersionInfo.new(16, 6))

    allow_next_instance_of(described_class) do |generator|
      allow(generator).to receive(:migration_number_in_past).and_return(version)
    end

    run_generator [table_name, "--columns=id, created_by_id", '--migration_number=20230704233431']
  end

  after do
    rm_rf(destination_root)
  end

  let(:connection) { ApplicationRecord.connection }
  let(:table_name) { 'users' }
  let(:version) { 20230704233430 }
  let(:expected_initialization_file) { load_expected_file('expected_bigint_initialization_migration.txt') }

  it 'generates new migration to create bigint columns' do
    assert_file("db/migrate/#{version}_initialize_conversion_of_#{table_name}_to_bigint.rb") do
      |bigint_initialization_file|
      # Regex is used to match the dynamically generated 'milestone' in the migration
      expect(bigint_initialization_file).to eq(expected_initialization_file)
    end
  end

  private

  def load_expected_file(file_name)
    File.read(File.expand_path(file_name, __dir__))
  end
end
