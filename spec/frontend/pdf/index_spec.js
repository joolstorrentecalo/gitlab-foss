import { shallowMount } from '@vue/test-utils';
import { FIXTURES_PATH } from 'spec/test_constants';
import PDFLab from '~/pdf/index.vue';

describe('PDFLab component', () => {
  let wrapper;

  const mountComponent = ({ pdf, flagValue = true }) =>
    shallowMount(PDFLab, {
      propsData: { pdf },
      provide: { glFeatures: { upgradePdfjs: flagValue } },
    });

  describe('without PDF data', () => {
    beforeEach(() => {
      wrapper = mountComponent({ pdf: '' });
    });

    it('does not render', () => {
      expect(wrapper.isVisible()).toBe(false);
    });
  });

  describe('with PDF data', () => {
    it('renders with pdfjs-dist v4 when upgradePdfjs flag is on', async () => {
      const mockGetDocument = jest.fn().mockReturnValue({ promise: Promise.resolve() });

      jest.mock('pdfjs-dist-v4/legacy/build/pdf.mjs', () => ({
        GlobalWorkerOptions: {},
        getDocument: mockGetDocument,
      }));

      wrapper = mountComponent({ pdf: `${FIXTURES_PATH}/blob/pdf/test.pdf` });
      await wrapper.vm.load();
      expect(mockGetDocument).toHaveBeenCalledWith({
        url: '/fixtures/blob/pdf/test.pdf',
        cMapUrl: '/assets/webpack/pdfjs-v4/cmaps/',
        cMapPacked: true,
        isEvalSupported: true,
      });
      expect(wrapper.isVisible()).toBe(true);
    });

    it('renders with pdfjs-dist v3 when upgradePdfjs flag is off', async () => {
      const mockGetDocument = jest.fn().mockReturnValue({ promise: Promise.resolve() });

      jest.mock('pdfjs-dist-v3/legacy/build/pdf', () => ({
        GlobalWorkerOptions: {},
        getDocument: mockGetDocument,
      }));
      wrapper = mountComponent({ pdf: `${FIXTURES_PATH}/blob/pdf/test.pdf`, flagValue: false });
      await wrapper.vm.load();
      expect(mockGetDocument).toHaveBeenCalledWith({
        url: '/fixtures/blob/pdf/test.pdf',
        cMapUrl: '/assets/webpack/pdfjs-v3/cmaps/',
        cMapPacked: true,
        isEvalSupported: false,
      });
      expect(wrapper.isVisible()).toBe(true);
    });
  });
});
