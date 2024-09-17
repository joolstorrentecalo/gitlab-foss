import produce from 'immer';
import { differenceBy } from 'lodash';
import { createAlert } from '~/alert';

import { findDesignWidget } from '~/work_items/utils';

export const hasErrors = ({ errors = [] }) => errors?.length;

const onError = (data, message) => {
  createAlert({ message });
  throw new Error(data.errors);
};

const addNewDesignToStore = (store, designManagementUpload, query) => {
  const sourceData = store.readQuery(query);

  store.writeQuery({
    ...query,
    data: produce(sourceData, (draftData) => {
      const designWidget = findDesignWidget(draftData.workItem.widgets);
      const currentDesigns = designWidget.designCollection.designs.nodes;
      const difference = differenceBy(designManagementUpload.designs, currentDesigns, 'filename');

      const newDesigns = currentDesigns
        .map((design) => {
          return (
            designManagementUpload.designs.find((d) => d.filename === design.filename) || design
          );
        })
        .concat(difference);

      let newVersionNode;
      const findNewVersions = designManagementUpload.designs.find((design) => design.versions);

      if (findNewVersions) {
        const findNewVersionsNodes = findNewVersions.versions.nodes;

        if (findNewVersionsNodes && findNewVersionsNodes.length) {
          newVersionNode = [findNewVersionsNodes[0]];
        }
      }

      const newVersions = [
        ...(newVersionNode || []),
        ...designWidget.designCollection.versions.nodes,
      ];

      const updatedDesigns = {
        __typename: 'DesignCollection',
        copyState: 'READY',
        designs: {
          __typename: 'DesignConnection',
          nodes: newDesigns,
        },
        versions: {
          __typename: 'DesignVersionConnection',
          nodes: newVersions,
        },
      };
      designWidget.designCollection = updatedDesigns;
    }),
  });
};

export const updateStoreAfterUploadDesign = (store, data, query) => {
  if (hasErrors(data)) {
    onError(data, data.errors[0]);
  } else {
    addNewDesignToStore(store, data, query);
  }
};
