<script>
import Tracking from '~/tracking';
import setSelectedBoardItemsMutation from '~/boards/graphql/client/set_selected_board_items.mutation.graphql';
import unsetSelectedBoardItemsMutation from '~/boards/graphql/client/unset_selected_board_items.mutation.graphql';
import selectedBoardItemsQuery from '~/boards/graphql/client/selected_board_items.query.graphql';
import setActiveBoardItemMutation from 'ee_else_ce/boards/graphql/client/set_active_board_item.mutation.graphql';
import activeBoardItemQuery from 'ee_else_ce/boards/graphql/client/active_board_item.query.graphql';
import BoardCardInner from './board_card_inner.vue';

export default {
  name: 'BoardCard',
  components: {
    BoardCardInner,
  },
  mixins: [Tracking.mixin()],
  inject: ['disabled', 'isIssueBoard'],
  props: {
    list: {
      type: Object,
      default: () => ({}),
      required: false,
    },
    item: {
      type: Object,
      default: () => ({}),
      required: false,
    },
    index: {
      type: Number,
      default: 0,
      required: false,
    },
    showWorkItemTypeIcon: {
      type: Boolean,
      default: false,
      required: false,
    },
    canAdmin: {
      type: Boolean,
      required: false,
      default: true,
    },
    columnIndex: {
      type: Number,
      required: false,
      default: 0,
    },
    rowIndex: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  apollo: {
    // eslint-disable-next-line @gitlab/vue-no-undef-apollo-properties
    activeBoardItem: {
      query: activeBoardItemQuery,
      variables() {
        return {
          isIssue: this.isIssueBoard,
        };
      },
    },
    // eslint-disable-next-line @gitlab/vue-no-undef-apollo-properties
    selectedBoardItems: {
      query: selectedBoardItemsQuery,
    },
  },
  computed: {
    activeItemId() {
      return this.activeBoardItem?.id;
    },
    isActive() {
      return this.item.id === this.activeItemId;
    },
    multiSelectVisible() {
      return !this.activeItemId && this.selectedBoardItems?.includes(this.item.id);
    },
    isDisabled() {
      return this.disabled || !this.item.id || this.item.isLoading || !this.canAdmin;
    },
    isDraggable() {
      return !this.isDisabled;
    },
    itemColor() {
      return this.item.color;
    },
    cardStyle() {
      return this.itemColor ? { borderLeftColor: this.itemColor } : '';
    },
    formattedItem() {
      return {
        ...this.item,
        assignees: this.item.assignees?.nodes || [],
        labels: this.item.labels?.nodes || [],
      };
    },
  },
  methods: {
    toggleIssue(e) {
      // Don't do anything if this happened on a no trigger element
      if (e.target.closest('.js-no-trigger')) return;

      const isMultiSelect = e.ctrlKey || e.metaKey;
      if (isMultiSelect && gon?.features?.boardMultiSelect) {
        this.toggleBoardItemMultiSelection(this.item);
      } else {
        e.currentTarget.focus();
        this.toggleItem();
        this.track('click_card', { label: 'right_sidebar' });
      }
    },
    async toggleItem() {
      await this.$apollo.mutate({
        mutation: unsetSelectedBoardItemsMutation,
      });
      this.$apollo.mutate({
        mutation: setActiveBoardItemMutation,
        variables: {
          boardItem: this.isActive ? null : this.item,
          listId: this.list.id,
          isIssue: this.isActive ? undefined : this.isIssueBoard,
        },
      });
    },
    async toggleBoardItemMultiSelection(item) {
      if (this.activeItemId) {
        await this.$apollo.mutate({
          mutation: setSelectedBoardItemsMutation,
          variables: {
            itemId: this.activeItemId,
          },
        });
        await this.$apollo.mutate({
          mutation: setActiveBoardItemMutation,
          variables: { boardItem: null, listId: null },
        });
      }
      this.$apollo.mutate({
        mutation: setSelectedBoardItemsMutation,
        variables: {
          itemId: item.id,
        },
      });
    },
    changeFocusInColumn(currentCard, i) {
      // Building a list using data-col-index instead of just traversing the ul is necessary for swimlanes
      const columnCards = [
        ...document.querySelectorAll(`li.board-card[data-col-index="${this.columnIndex}"]`),
      ];
      const currentIndex = columnCards.indexOf(currentCard);
      if (currentIndex + i < 0 || currentIndex + i > columnCards.length - 1) {
        return;
      }
      columnCards[currentIndex + i].focus();
    },
    focusNext(e) {
      this.changeFocusInColumn(e.target, 1);
    },
    focusPrev(e) {
      this.changeFocusInColumn(e.target, -1);
    },
    changeFocusInRow(currentList, i) {
      // Find next in line list/cell with cards. If none, don't move.
      let listSelector = 'board-list';
      // Account for swimlanes using different structure. Swimlanes traverse within their lane.
      if (currentList.classList.contains('board-cell')) {
        listSelector = `board-cell[data-row-index="${this.rowIndex}"]`;
      }
      const lists = [
        ...document.querySelectorAll(`ul.${listSelector}:not(.list-empty):not(.list-collapsed)`),
      ];
      const currentIndex = lists.indexOf(currentList);
      if (currentIndex + i < 0 || currentIndex + i > lists.length - 1) {
        return;
      }
      // Focus the same index if possible, or last card
      const targetCards = lists[currentIndex + i].querySelectorAll('li.board-card');
      if (targetCards.length <= this.index) {
        targetCards[targetCards.length - 1].focus();
      } else {
        targetCards[this.index].focus();
      }
    },
    focusLeft(e) {
      this.changeFocusInRow(e.target.parentElement, -1);
    },
    focusRight(e) {
      this.changeFocusInRow(e.target.parentElement, 1);
    },
  },
};
</script>

<template>
  <li
    :class="[
      {
        'multi-select gl-border-blue-200 gl-bg-blue-50': multiSelectVisible,
        'gl-cursor-grab': isDraggable,
        'is-disabled': isDisabled,
        'is-active gl-bg-blue-50': isActive,
        'gl-cursor-not-allowed gl-bg-gray-10': item.isLoading,
        'gl-border-l-4 gl-pl-4 gl-border-l-solid': itemColor,
        'hover:gl-bg-gray-10 focus:gl-bg-gray-10': !isActive,
      },
    ]"
    :index="index"
    :data-item-id="item.id"
    :data-item-iid="item.iid"
    :data-item-path="item.referencePath"
    :style="cardStyle"
    :aria-label="item.title"
    data-testid="board-card"
    :data-col-index="columnIndex"
    :data-row-index="rowIndex"
    class="board-card gl-border gl-relative gl-mb-3 gl-rounded-base gl-p-4 gl-leading-normal focus:gl-focus"
    role="button"
    tabindex="0"
    @click="toggleIssue"
    @keydown.enter="toggleIssue"
    @keydown.space.prevent="toggleIssue"
    @keydown.left.exact.prevent="focusLeft"
    @keydown.right.exact.prevent="focusRight"
    @keydown.down.exact.prevent="focusNext"
    @keydown.up.exact.prevent="focusPrev"
  >
    <board-card-inner
      :list="list"
      :item="formattedItem"
      :update-filters="true"
      :index="index"
      :show-work-item-type-icon="showWorkItemTypeIcon"
      @setFilters="$emit('setFilters', $event)"
    >
      <slot></slot>
    </board-card-inner>
  </li>
</template>
