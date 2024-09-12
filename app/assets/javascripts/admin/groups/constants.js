import { __ } from '~/locale';

export const FILTERED_SEARCH_NAMESPACE = 'admin-groups';
export const FILTERED_SEARCH_TERM_KEY = 'name';

export const SORT_OPTION_NAME = {
  text: __('Name'),
  value: 'name',
};

export const SORT_OPTION_CREATED_DATE = {
  text: __('Created date'),
  value: 'created',
};

export const SORT_OPTION_UPDATED_DATE = {
  text: __('Updated date'),
  value: 'latest_activity',
};

export const SORT_OPTION_REPOSITORY_SIZE = {
  text: __('Repository size'),
  value: 'storage_size',
};

export const SORT_OPTIONS = [
  SORT_OPTION_NAME,
  SORT_OPTION_CREATED_DATE,
  SORT_OPTION_UPDATED_DATE,
  SORT_OPTION_REPOSITORY_SIZE,
];

export const SORT_DIRECTION_ASC = 'asc';
export const SORT_DIRECTION_DESC = 'desc';
