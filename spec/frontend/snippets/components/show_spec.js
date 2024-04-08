import { GlLoadingIcon, GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import { Blob, BinaryBlob } from 'jest/blob/components/mock_data';
import SnippetApp from '~/snippets/components/show.vue';
import SnippetBlob from '~/snippets/components/snippet_blob_view.vue';
import SnippetHeader from '~/snippets/components/snippet_header.vue';
import SnippetDescription from '~/snippets/components/snippet_description.vue';
import {
  VISIBILITY_LEVEL_INTERNAL_STRING,
  VISIBILITY_LEVEL_PRIVATE_STRING,
  VISIBILITY_LEVEL_PUBLIC_STRING,
} from '~/visibility_level/constants';
import SnippetCodeDropdown from '~/vue_shared/components/code_dropdown/snippet_code_dropdown.vue';
import { stubPerformanceWebAPI } from 'helpers/performance';

describe('Snippet view app', () => {
  let wrapper;
  const defaultProps = {
    snippetGid: 'gid://gitlab/PersonalSnippet/42',
  };
  const webUrl = 'http://foo.bar';
  const dummyHTTPUrl = webUrl;
  const dummySSHUrl = 'ssh://foo.bar';

  function createComponent({ props = defaultProps, data = {}, loading = false } = {}) {
    const $apollo = {
      queries: {
        snippet: {
          loading,
        },
      },
    };

    wrapper = shallowMount(SnippetApp, {
      mocks: { $apollo },
      propsData: {
        ...props,
      },
      data() {
        return data;
      },
    });
  }

  const findLoadingIcon = () => wrapper.findComponent(GlLoadingIcon);

  beforeEach(() => {
    stubPerformanceWebAPI();
  });

  it('renders loader while the query is in flight', () => {
    createComponent({ loading: true });
    expect(findLoadingIcon().exists()).toBe(true);
  });

  it('renders all simple components required after the query is finished', () => {
    createComponent();
    expect(wrapper.findComponent(SnippetHeader).exists()).toBe(true);
    expect(wrapper.findComponent(SnippetDescription).exists()).toBe(true);
  });

  it('renders correct snippet-blob components', () => {
    createComponent({
      data: {
        snippet: {
          webUrl,
          blobs: [Blob, BinaryBlob],
        },
      },
    });
    const blobs = wrapper.findAllComponents(SnippetBlob);
    expect(blobs.length).toBe(2);
    expect(blobs.at(0).props('blob')).toEqual(Blob);
    expect(blobs.at(1).props('blob')).toEqual(BinaryBlob);
  });

  describe('hasUnretrievableBlobs alert rendering', () => {
    it.each`
      hasUnretrievableBlobs | condition       | isRendered
      ${false}              | ${'not render'} | ${false}
      ${true}               | ${'render'}     | ${true}
    `('does $condition gl-alert by default', ({ hasUnretrievableBlobs, isRendered }) => {
      createComponent({
        data: {
          snippet: {
            webUrl,
            hasUnretrievableBlobs,
          },
        },
      });
      expect(wrapper.findComponent(GlAlert).exists()).toBe(isRendered);
    });
  });

  describe('Code button rendering', () => {
    it.each`
      httpUrlToRepo   | sshUrlToRepo   | shouldRender    | isRendered
      ${null}         | ${null}        | ${'Should not'} | ${false}
      ${null}         | ${dummySSHUrl} | ${'Should'}     | ${true}
      ${dummyHTTPUrl} | ${null}        | ${'Should'}     | ${true}
      ${dummyHTTPUrl} | ${dummySSHUrl} | ${'Should'}     | ${true}
    `(
      '$shouldRender render "Clone" button when `httpUrlToRepo` is $httpUrlToRepo and `sshUrlToRepo` is $sshUrlToRepo',
      ({ httpUrlToRepo, sshUrlToRepo, isRendered }) => {
        createComponent({
          data: {
            snippet: {
              sshUrlToRepo,
              httpUrlToRepo,
              webUrl,
            },
          },
        });
        expect(wrapper.findComponent(SnippetCodeDropdown).exists()).toBe(isRendered);
      },
    );

    it.each`
      snippetVisibility                   | projectVisibility                  | condition | embeddable
      ${VISIBILITY_LEVEL_INTERNAL_STRING} | ${VISIBILITY_LEVEL_PUBLIC_STRING}  | ${'not'}  | ${false}
      ${VISIBILITY_LEVEL_PRIVATE_STRING}  | ${VISIBILITY_LEVEL_PUBLIC_STRING}  | ${'not'}  | ${false}
      ${VISIBILITY_LEVEL_PUBLIC_STRING}   | ${undefined}                       | ${''}     | ${true}
      ${VISIBILITY_LEVEL_PUBLIC_STRING}   | ${VISIBILITY_LEVEL_PUBLIC_STRING}  | ${''}     | ${true}
      ${VISIBILITY_LEVEL_INTERNAL_STRING} | ${VISIBILITY_LEVEL_PUBLIC_STRING}  | ${'not'}  | ${false}
      ${VISIBILITY_LEVEL_PRIVATE_STRING}  | ${undefined}                       | ${'not'}  | ${false}
      ${'foo'}                            | ${undefined}                       | ${'not'}  | ${false}
      ${VISIBILITY_LEVEL_PUBLIC_STRING}   | ${VISIBILITY_LEVEL_PRIVATE_STRING} | ${'not'}  | ${false}
    `(
      'is $condition embeddable if snippetVisibility is $snippetVisibility and projectVisibility is $projectVisibility',
      ({ snippetVisibility, projectVisibility, embeddable }) => {
        createComponent({
          data: {
            snippet: {
              sshUrlToRepo: dummySSHUrl,
              httpUrlToRepo: dummyHTTPUrl,
              visibilityLevel: snippetVisibility,
              webUrl,
              project: {
                visibility: projectVisibility,
              },
            },
          },
        });
        expect(wrapper.findComponent(SnippetCodeDropdown).props('embeddable')).toBe(embeddable);
      },
    );
  });
});
