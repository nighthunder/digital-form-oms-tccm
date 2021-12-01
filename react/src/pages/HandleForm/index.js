import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';
import { Button, TextField, CircularProgress, Select } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

function HandleForm({user}) {

	const location = useLocation();
	const history = useHistory();

	useEffect(() => {
        async function HandleForm() {
                console.log("Module ID",  location.state.moduleID);
                console.log("Module Desc",  location.state.moduleDescription);
                console.log("Questionnaire Desc",  location.state.description);
                console.log("Questionnaire version",  location.state.version);
                console.log("Questionnaire status", location.state.questionnaireStatus);
                console.log("Creation date", location.state.creationDate);
                console.log("Modification date",  location.state.lastModification);

                var moduleID2;

            { location.state.moduleDescription === "Formulário de Admissão" && console.log("um"); moduleID2 = "1"; }
            { location.state.moduleDescription === "Acompanhamento" && console.log("dois"); moduleID2 = "2" }
            { location.state.moduleDescription === "Formulário de alta/óbito" && console.log("tres"); moduleID2= "3" }
			//console.log("Resposta4", modules);
			//console.log("Resposta3", location.state);
            {
                 location.state.questionnaireStatus === "Publicado" &&  console.log("ID do módulo",moduleID2);

                 /*history.push('/edit-form-published',
                         { modulo: location.state.moduleID, 
                           hospitalIndex: location.state.hospitalIndex
                         }
                 )*/
            }
        }                                                                                                                                                                                                       
        HandleForm();
    }, [])

    return (null);

}

export default connect(state => ({ user: state.user }))(HandleForm);