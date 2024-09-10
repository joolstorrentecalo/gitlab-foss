# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WorkItems::Widgets::HierarchyService::UpdateService, feature_category: :portfolio_management do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  let_it_be(:work_item) { create(:work_item, project: project) }
  let_it_be(:parent_work_item) { create(:work_item, project: project) }
  let_it_be(:child_work_item) { create(:work_item, :task, project: project) }
  let_it_be(:existing_link) { create(:parent_link, work_item: child_work_item, work_item_parent: work_item) }

  let(:widget) { work_item.widgets.find { |widget| widget.is_a?(WorkItems::Widgets::Hierarchy) } }
  let(:not_found_error) { 'No matching work item found. Make sure that you are adding a valid work item ID.' }

  shared_examples 'raises a WidgetError' do |message|
    it { expect { subject }.to raise_error(described_class::WidgetError, message) }
  end

  shared_examples 'raises a WidgetError with message' do
    let(:message) { not_found_error }

    it { expect { subject }.to raise_error(described_class::WidgetError, message) }
  end

  describe '#update' do
    subject { described_class.new(widget: widget, current_user: user).before_update_in_transaction(params: params) }

    context 'when multiple params are present' do
      it_behaves_like 'raises a WidgetError', 'One and only one of children, parent or remove_child is required' do
        let(:params) { { parent: parent_work_item, children: [child_work_item] } }
      end

      it_behaves_like 'raises a WidgetError', 'One and only one of children, parent or remove_child is required' do
        let(:params) { { parent: parent_work_item, remove_child: child_work_item } }
      end

      it_behaves_like 'raises a WidgetError', 'One and only one of children, parent or remove_child is required' do
        let(:params) { { remove_child: child_work_item, children: [child_work_item] } }
      end
    end

    context 'when invalid params are present' do
      let(:params) { { other_parent: parent_work_item } }

      it_behaves_like 'raises a WidgetError', 'One or more arguments are invalid: other_parent.'
    end

    context 'when relative position params are incomplete' do
      context 'when only adjacent_work_item is present' do
        let(:params) do
          { parent: parent_work_item, adjacent_work_item: child_work_item }
        end

        it_behaves_like 'raises a WidgetError', described_class::INVALID_RELATIVE_POSITION_ERROR
      end

      context 'when only relative_position is present' do
        let(:params) do
          { parent: parent_work_item, relative_position: 'AFTER' }
        end

        it_behaves_like 'raises a WidgetError', described_class::INVALID_RELATIVE_POSITION_ERROR
      end
    end

    context 'when updating children' do
      let_it_be(:child_work_item2) { create(:work_item, :task, project: project) }
      let_it_be(:child_work_item3) { create(:work_item, :task, project: project) }
      let_it_be(:child_work_item4) { create(:work_item, :task, project: project) }

      context 'when user has insufficient permissions to link work items' do
        let(:params) { { children: [child_work_item4] } }

        it_behaves_like 'raises a WidgetError with message' do
          let(:message) { not_found_error }
        end
      end

      context 'when user has sufficient permissions to link work item' do
        before do
          project.add_developer(user)
        end

        context 'with valid children params' do
          let(:params) { { children: [child_work_item2, child_work_item3] } }

          it 'correctly sets work item parent' do
            subject

            expect(work_item.reload.work_item_children)
              .to contain_exactly(child_work_item, child_work_item2, child_work_item3)
          end

          context 'when relative_position and adjacent_work_item are given' do
            context 'with BEFORE value' do
              let(:params) do
                { children: [child_work_item3], relative_position: 'BEFORE', adjacent_work_item: child_work_item }
              end

              it_behaves_like 'raises a WidgetError', described_class::CHILDREN_REORDERING_ERROR
            end

            context 'with AFTER value' do
              let(:params) do
                { children: [child_work_item2], relative_position: 'AFTER', adjacent_work_item: child_work_item }
              end

              it_behaves_like 'raises a WidgetError', described_class::CHILDREN_REORDERING_ERROR
            end
          end
        end

        context 'with remove_child param' do
          let(:params) { { remove_child: [child_work_item] } }

          it 'correctly removes the work item child' do
            expect { subject }.to change { WorkItems::ParentLink.count }.by(-1)

            expect(work_item.reload.work_item_children).to be_empty
          end
        end

        context 'when child is already assigned' do
          let(:params) { { children: [child_work_item] } }

          it_behaves_like 'raises a WidgetError', 'Work item(s) already assigned'
        end

        context 'when child type is invalid' do
          let_it_be(:child_issue) { create(:work_item, project: project) }

          let(:params) { { children: [child_issue] } }

          it_behaves_like 'raises a WidgetError with message' do
            let(:message) do
              "#{child_issue.to_reference} cannot be added: it's not allowed to add this type of parent item"
            end
          end
        end
      end
    end

    context 'when updating parent' do
      let_it_be(:work_item) { create(:work_item, :task, project: project) }

      let(:params) { { parent: parent_work_item } }

      context 'when user has insufficient permissions to link work items' do
        it_behaves_like 'raises a WidgetError with message' do
          let(:message) { not_found_error }
        end
      end

      context 'when user has sufficient permissions to link work item' do
        before do
          project.add_developer(user)
        end

        it 'correctly sets new parent' do
          expect(subject[:status]).to eq(:success)
          expect(work_item.work_item_parent).to eq(parent_work_item)
        end

        context 'when parent is nil' do
          let(:params) { { parent: nil } }

          it 'removes the work item parent if present' do
            work_item.update!(work_item_parent: parent_work_item)

            expect do
              subject
              work_item.reload
            end.to change(work_item, :work_item_parent).from(parent_work_item).to(nil)
          end

          it 'returns success status if parent not present', :aggregate_failures do
            work_item.update!(work_item_parent: nil)

            expect(subject[:status]).to eq(:success)
            expect(work_item.reload.work_item_parent).to be_nil
          end
        end

        context 'when type is invalid' do
          let_it_be(:parent_task) { create(:work_item, :task, project: project) }

          let(:params) { { parent: parent_task } }

          it_behaves_like 'raises a WidgetError with message' do
            let(:message) do
              "#{parent_task.to_reference} cannot be added: it's not allowed to add this type of parent item"
            end
          end
        end

        context 'with positioning arguments' do
          let_it_be_with_reload(:adjacent) { create(:work_item, :task, project: project) }

          let_it_be_with_reload(:adjacent_link) do
            create(:parent_link, work_item: adjacent, work_item_parent: parent_work_item)
          end

          let(:params) { { parent: parent_work_item, adjacent_work_item: adjacent, relative_position: 'AFTER' } }

          it 'correctly sets new parent and position' do
            expect(subject[:status]).to eq(:success)
            expect(work_item.work_item_parent).to eq(parent_work_item)
            expect(work_item.parent_link.relative_position).to be > adjacent_link.relative_position
          end

          context 'when other hierarchy adjacent is provided' do
            let_it_be(:other_hierarchy_adjacent) { create(:parent_link).work_item }

            let(:params) do
              { parent: parent_work_item, adjacent_work_item: other_hierarchy_adjacent, relative_position: 'AFTER' }
            end

            it_behaves_like 'raises a WidgetError', described_class::UNRELATED_ADJACENT_HIERARCHY_ERROR
          end
        end
      end
    end
  end
end
