import { DEFAULT_PER_PAGE } from '~/api';
import { joinPaths } from '~/lib/utils/url_utility';
import axios from '../lib/utils/axios_utils';
import { buildApiUrl } from './api_utils';

const PROJECTS_PATH = '/api/:version/projects.json';
const PROJECT_PATH = '/api/:version/projects/:id';
const PROJECT_MEMBERS_PATH = '/api/:version/projects/:id/members';
const PROJECT_ALL_MEMBERS_PATH = '/api/:version/projects/:id/members/all';
const PROJECT_IMPORT_MEMBERS_PATH = '/api/:version/projects/:id/import_project_members/:project_id';
const PROJECT_REPOSITORY_SIZE_PATH = '/api/:version/projects/:id/repository_size';
const PROJECT_TRANSFER_LOCATIONS_PATH = 'api/:version/projects/:id/transfer_locations';
const PROJECT_SHARE_LOCATIONS_PATH = 'api/:version/projects/:id/share_locations';

export function getProjects(query, options, callback = () => {}) {
  const url = buildApiUrl(PROJECTS_PATH);
  const defaults = {
    search: query,
    per_page: DEFAULT_PER_PAGE,
    simple: true,
  };

  if (gon.current_user_id) {
    defaults.membership = true;
  }

  if (query?.includes('/')) {
    defaults.search_namespaces = true;
  }

  return axios
    .get(url, {
      params: Object.assign(defaults, options),
    })
    .then(({ data, headers }) => {
      callback(data);
      return { data, headers };
    });
}

export function createProject(projectData) {
  const url = buildApiUrl(PROJECTS_PATH);
  return axios.post(url, projectData).then(({ data }) => {
    return data;
  });
}

export function updateProject(projectId, data) {
  const url = buildApiUrl(PROJECT_PATH).replace(':id', projectId);

  return axios.put(url, data);
}

export function deleteProject(projectId, params) {
  const url = buildApiUrl(PROJECT_PATH).replace(':id', projectId);

  return axios.delete(url, { params });
}

export function importProjectMembers(sourceId, targetId) {
  const url = buildApiUrl(PROJECT_IMPORT_MEMBERS_PATH)
    .replace(':id', sourceId)
    .replace(':project_id', targetId);
  return axios.post(url);
}

export function updateRepositorySize(projectPath) {
  const url = buildApiUrl(PROJECT_REPOSITORY_SIZE_PATH).replace(
    ':id',
    encodeURIComponent(projectPath),
  );
  return axios.post(url);
}

export const getTransferLocations = (projectId, params = {}) => {
  const url = buildApiUrl(PROJECT_TRANSFER_LOCATIONS_PATH).replace(':id', projectId);
  const defaultParams = { per_page: DEFAULT_PER_PAGE };

  return axios.get(url, { params: { ...defaultParams, ...params } });
};

export const getProjectMembers = (projectId, inherited = false) => {
  const path = inherited ? PROJECT_ALL_MEMBERS_PATH : PROJECT_MEMBERS_PATH;
  const url = buildApiUrl(path).replace(':id', projectId);

  return axios.get(url);
};

export const getProjectShareLocations = (projectId, params = {}, axiosOptions = {}) => {
  const url = buildApiUrl(PROJECT_SHARE_LOCATIONS_PATH).replace(':id', projectId);
  const defaultParams = { per_page: DEFAULT_PER_PAGE };

  return axios.get(url, { params: { ...defaultParams, ...params }, ...axiosOptions });
};

/**
 * Uploads an image to a project and returns the share URL.
 *
 * @param {Object} options - The options for uploading the image.
 * @param {string} options.filename - The name of the file to be uploaded.
 * @param {Blob} options.blobData - The blob data of the image to be uploaded.
 * @param {string} options.projectFullPath - The full path of the project.
 * @param {number} options.projectId - The ID of the project.
 * @returns {Promise<string>} The share URL of the uploaded image
 * @throws {Error} If any required parameter is missing or if the upload fails.
 */

export async function uploadImageToProject({ filename, blobData, projectFullPath, projectId }) {
  if (!filename) {
    // eslint-disable-next-line @gitlab/require-i18n-strings
    throw new Error('filename is required');
  }
  if (!blobData) {
    throw new Error('blobData is required');
  }
  if (!projectFullPath) {
    throw new Error('projectFullPath is required');
  }
  if (!projectId) {
    throw new Error('projectId is required');
  }

  const url = joinPaths(gon.relative_url_root || '/', projectFullPath, 'uploads');

  const formData = new FormData();
  formData.append('file', blobData, filename);

  const result = await axios.post(url, formData, {
    headers: { 'Content-Type': 'multipart/form-data' },
  });

  if (result.data?.link?.url) {
    const uploadUrl = result.data.link.url;

    const relativeUrl = joinPaths('/-/project/', `${projectId}`, uploadUrl);
    const shareUrl = new URL(relativeUrl, document.baseURI).href;

    return shareUrl;
  }
  // eslint-disable-next-line @gitlab/require-i18n-strings
  throw new Error('Upload failed');
}
