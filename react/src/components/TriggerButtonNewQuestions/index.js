import React from 'react';
import PlusOne from '@mui/icons-material/Add';

const Trigger = ({ buttonRef, showModal }) => {
  return (
    <PlusOne
        // className="btn btn-lg btn-danger center modal-button"
        className="Icon plusIcon"
        ref={buttonRef}
        onClick={showModal}
    >
    </PlusOne>
  );
};
export default Trigger;
