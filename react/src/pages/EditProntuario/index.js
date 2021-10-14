import React, { useState } from 'react';
import './styles.css';
import { useHistory } from "react-router-dom";
import { useLocation } from "react-router-dom";
import { TextField, Button } from '@material-ui/core';

import api from '../../services/api';

import { connect } from 'react-redux';

const styles = {
    Button: {
      margin: 24,
      marginBottom: 0
    }
};

function EditProntuario({user}) {

    const history = useHistory();

    const location = useLocation();

    const [prontuario, setProntuario] = useState();

    const [error, setError] = useState('');

    async function handleSubmit(e) {
        e.preventDefault()
         
        const response = await api.post('/editMedicalRecord', {
            userid: user[location.state.hospitalIndex].userid,
            groupRoleid: user[location.state.hospitalIndex].grouproleid,
            hospitalUnitid: user[location.state.hospitalIndex].hospitalunitid,
            participantId: location.state.participantId,
            medicalRecordNew: prontuario
        }).catch( function (error) {
            console.log(error)
            if(error.response.data.Message) {
                setError(error.response.data.Message);
            } else {
                setError(error.response.data.msgRetorno);
            }
        });

        if(response)
            if(response.data.msgRetorno === "Alteração realizada com sucesso.")
                history.goBack()
        console.log(response);

        //history.push('/formulario', { modulo: 1 })
    }

    function handleChange(e) {
        console.log(user)
        console.log(location.state)
        setProntuario(e.target.value)
    }

    return (
        <main className="container add-prontuario">
            <div>
                <header className="index">
                    <b>{user[location.state.hospitalIndex].hospitalName}</b>
                </header>
                <h2>Editar prontuário {location.state.prontuario}</h2>
            </div>
            <form noValidate autoComplete="off" onSubmit={handleSubmit}>
                <TextField name="prontuario" label="Número do prontuário" type="number" defaultValue={location.state.prontuario} onChange={handleChange} />
                <div className="submit-prontuario">
                    <span className="error">{ error }</span>
                    <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={!prontuario}>Atualizar</Button>
                </div>
            </form>
        </main>
    );
}

export default connect(state => ({ user: state.user }))(EditProntuario);