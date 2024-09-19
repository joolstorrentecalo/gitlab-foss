# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Database::LoadBalancing::Session do
  using RSpec::Parameterized::TableSyntax

  after do
    described_class.clear_session
  end

  describe '.current' do
    it 'returns the current session' do
      expect(described_class.current).to be_an_instance_of(described_class)
    end
  end

  describe '.clear_session' do
    it 'clears the current session' do
      described_class.current
      described_class.clear_session

      expect(RequestStore[described_class::CACHE_KEY]).to be_nil
    end
  end

  describe '.without_sticky_writes' do
    it 'ignores sticky write events sent by a connection proxy' do
      described_class.without_sticky_writes do
        described_class.current.write!(:main)
      end

      session = described_class.current

      expect(session.using_primary?(:main)).to eq(false)
    end

    it 'still is aware of write that happened' do
      described_class.without_sticky_writes do
        described_class.current.write!(:main)
      end

      session = described_class.current

      expect(session.performed_write?(:main)).to be true
    end
  end

  describe '#use_primary?' do
    where(:set_db, :check_db, :result) do
      nil   | :main | true
      :main | :main | true
      :main | :ci   | false
    end

    with_them do
      it 'checks primary usage correctly when use_primary! is called' do
        instance = described_class.new

        instance.use_primary!(set_db)

        expect(instance.use_primary?(check_db)).to eq(result)
      end

      it 'checks primary usage correctly when write! is called' do
        instance = described_class.new

        instance.write!(set_db)

        expect(instance.use_primary?(check_db)).to eq(result)
      end
    end

    it 'returns false when a secondary should be used' do
      expect(described_class.new.use_primary?(:main)).to eq(false)
    end
  end

  describe '#use_primary' do
    let(:instance) { described_class.new }

    context 'when primary was used before' do
      before do
        instance.write!(:main)
      end

      it 'restores state after use' do
        expect { |blk| instance.use_primary(&blk) }.to yield_with_no_args

        expect(instance.use_primary?(:main)).to eq(true)
      end
    end

    context 'when primary was not used' do
      it 'restores state after use' do
        expect { |blk| instance.use_primary(&blk) }.to yield_with_no_args

        expect(instance.use_primary?(:main)).to eq(false)
      end
    end

    context 'when checking use_primary? in block' do
      it 'uses primary during block' do
        expect do |blk|
          instance.use_primary do
            expect(instance.use_primary?(:main)).to eq(true)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control
      end
    end

    context 'when write was performed' do
      where(:write_db, :result) do
        :main | true
        # true is expected since write! was not specific
        nil   | true
        # false is used only if the write! was specific to a another connection
        :ci   | false
      end

      with_them do
        it 'continues using primary when write was performed' do
          instance.use_primary do
            instance.write!(write_db)
          end

          expect(instance.use_primary?(:main)).to eq(result)
        end
      end
    end
  end

  describe '#performed_write?' do
    it 'returns true if a write was performed' do
      instance = described_class.new

      instance.write!(:main)

      expect(instance.performed_write?).to eq(false)
      expect(instance.performed_write?(:main)).to eq(true)
    end
  end

  describe '#ignore_writes' do
    it 'ignores write events' do
      instance = described_class.new

      instance.ignore_writes { instance.write!(:main) }

      expect(instance.using_primary?(:main)).to eq false
      expect(instance.performed_write?(:main)).to eq true
    end

    it 'does not prevent using primary if an exception is raised' do
      instance = described_class.new

      begin
        instance.ignore_writes { raise ArgumentError }
      rescue ArgumentError
        nil
      end
      instance.write!(:main)

      expect(instance.using_primary?(:main)).to eq(true)
    end
  end

  describe '#use_replicas_for_read_queries' do
    let(:instance) { described_class.new }

    it 'sets the flag inside the block' do
      expect do |blk|
        instance.use_replicas_for_read_queries do
          expect(instance.use_replicas_for_read_queries?).to eq(true)

          # call yield probe
          blk.to_proc.call
        end
      end.to yield_control

      expect(instance.use_replicas_for_read_queries?).to eq(false)
    end

    it 'restores state after use' do
      expect do |blk|
        instance.use_replicas_for_read_queries do
          instance.use_replicas_for_read_queries do
            expect(instance.use_replicas_for_read_queries?).to eq(true)

            # call yield probe
            blk.to_proc.call
          end

          expect(instance.use_replicas_for_read_queries?).to eq(true)
        end
      end.to yield_control

      expect(instance.use_replicas_for_read_queries?).to eq(false)
    end

    context 'when primary was used before' do
      before do
        instance.use_primary!
      end

      it 'sets the flag inside the block' do
        expect do |blk|
          instance.use_replicas_for_read_queries do
            expect(instance.use_replicas_for_read_queries?).to eq(true)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control

        expect(instance.use_replicas_for_read_queries?).to eq(false)
      end
    end

    context 'when a write query is performed before' do
      before do
        instance.write!(:main)
      end

      it 'sets the flag inside the block' do
        expect do |blk|
          instance.use_replicas_for_read_queries do
            expect(instance.use_replicas_for_read_queries?).to eq(true)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control

        expect(instance.use_replicas_for_read_queries?).to eq(false)
      end
    end
  end

  describe '#fallback_to_replicas_for_ambiguous_queries' do
    let(:instance) { described_class.new }

    it 'sets the flag inside the block' do
      expect do |blk|
        instance.fallback_to_replicas_for_ambiguous_queries do
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)

          # call yield probe
          blk.to_proc.call
        end
      end.to yield_control

      expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
    end

    it 'restores state after use' do
      expect do |blk|
        instance.fallback_to_replicas_for_ambiguous_queries do
          instance.fallback_to_replicas_for_ambiguous_queries do
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)

            # call yield probe
            blk.to_proc.call
          end

          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)
        end
      end.to yield_control

      expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
    end

    context 'when primary was used before' do
      before do
        instance.use_primary!
      end

      it 'uses primary during block' do
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)

        expect do |blk|
          instance.fallback_to_replicas_for_ambiguous_queries do
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end
    end

    context 'when primary was used before for specific db' do
      before do
        instance.use_primary!(:main)
      end

      it 'only uses primary of specified db during block' do
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)

        expect do |blk|
          instance.fallback_to_replicas_for_ambiguous_queries do
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end
    end

    context 'when a write was performed before' do
      before do
        instance.write!(:main)
      end

      it 'only uses primary of specified db during block' do
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)

        expect do |blk|
          instance.fallback_to_replicas_for_ambiguous_queries do
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

            # call yield probe
            blk.to_proc.call
          end
        end.to yield_control

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end
    end

    context 'when primary was used inside the block' do
      it 'uses primary aterward' do
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)

        instance.fallback_to_replicas_for_ambiguous_queries do
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

          instance.use_primary!

          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
        end

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end

      it 'restores state after use' do
        instance.fallback_to_replicas_for_ambiguous_queries do
          instance.fallback_to_replicas_for_ambiguous_queries do
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

            instance.use_primary!

            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
          end

          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
        end

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end
    end

    context 'when primary of specific db was used inside the block' do
      it 'uses primary aterward' do
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)

        instance.fallback_to_replicas_for_ambiguous_queries do
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

          instance.use_primary!(:main)

          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)
        end

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end

      it 'restores state after use' do
        instance.fallback_to_replicas_for_ambiguous_queries do
          instance.fallback_to_replicas_for_ambiguous_queries do
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

            instance.use_primary!(:main)

            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)
          end

          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)
        end

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end
    end

    context 'when a write was performed inside the block' do
      it 'uses primary afterward' do
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)

        instance.fallback_to_replicas_for_ambiguous_queries do
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

          instance.write!(:main)

          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)
        end

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end

      it 'restores state after use' do
        instance.fallback_to_replicas_for_ambiguous_queries do
          instance.fallback_to_replicas_for_ambiguous_queries do
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(true)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)

            instance.write!(:main)

            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
            expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)
          end

          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
          expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(true)
        end

        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:main)).to eq(false)
        expect(instance.fallback_to_replicas_for_ambiguous_queries?(:ci)).to eq(false)
      end
    end
  end
end
