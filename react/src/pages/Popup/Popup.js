import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import Dialog from '@mui/material/Dialog';
import DialogActions from '@mui/material/DialogActions';
import DialogContent from '@mui/material/DialogContent';
import DialogContentText from '@mui/material/DialogContentText';
import DialogTitle from '@mui/material/DialogTitle';
import { Button } from '@material-ui/core';
import { connect } from 'react-redux';

function Popup(props){

    const location = useLocation();
    const history = useHistory();
    const [open, setOpen] = React.useState(false);

    const handleClose = () => {
        setOpen(false);
    };

    return (
        <Dialog key={props.key}
                      open={open}
                      onClose={handleClose}
                      aria-labelledby="alert-dialog-title"
                      aria-describedby="alert-dialog-description"
                    >
            <DialogTitle id="alert-dialog-title">
                {props.popupTitle}
            </DialogTitle>
            <DialogContent>
                <DialogContentText id="alert-dialog-description">
                    {props.popupBody}                        
                    </DialogContentText>
                      </DialogContent>
                      <DialogActions>
                        <Button onClick={handleClose}>Cancelar</Button>
                        <Button onClick={props.actionFunction} autoFocus>
                          Prosseguir
                        </Button>
            </DialogActions>
        </Dialog>
    );
}

export default connect(state => ({ user: state.user }))(Dialog);