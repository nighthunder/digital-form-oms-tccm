import React, { useState, useEffect } from 'react';
import './styles.css';
import { useHistory } from "react-router-dom";
import { useLocation } from "react-router-dom";
import { TextField, Select, InputLabel, Button, CircularProgress } from '@material-ui/core';

import api from '../../services/api';

import { connect } from 'react-redux';

const styles = {
    Button: {
      margin: 24,
      marginBottom: 0
    }
};

function AddProntuario({user}) {

    const history = useHistory();
    const location = useLocation();
    const [prontuario, setProntuario] = useState();
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');
    const [questionnaires, setQuestionnaires] = useState([]);
    const [questionnaireID, setQuestionnaireID] = useState();

    useEffect(() => {
        async function loadQuestionnaires() {
            const response = await api.get('/survey');
            setQuestionnaires(response.data);
        }
        loadQuestionnaires();

    }, [])

    async function handleSubmit(e) {
        e.preventDefault();
        setLoading(true);
        console.log("questionário id", {
            userid: user[location.state.hospitalIndex].userid,
            groupRoleid: user[location.state.hospitalIndex].grouproleid,
            hospitalUnitid: user[location.state.hospitalIndex].hospitalunitid,
            questionnaireId: questionnaireID,
            medicalRecord: prontuario,
        });
        const response = await api.post('/insertMedicalRecord', {
            userid: user[location.state.hospitalIndex].userid,
            groupRoleid: user[location.state.hospitalIndex].grouproleid,
            hospitalUnitid: user[location.state.hospitalIndex].hospitalunitid,
            questionnaireId: questionnaireID,
            medicalRecord: prontuario,
        }).catch( function (error) {
            setLoading(false);
            console.log(error)
            if(error.response.data.Message) {
                setError(error.response.data.Message);
            } else {
                setError(error.response.data.msgRetorno);
            }
        });

        if(response) {
            setLoading(false);
            setSuccess(response.data.msgRetorno);
        }
    }

    function handleChange(e) {
        setError('');
        //console.log(user)
        //console.log(location.state)
        setProntuario(e.target.value)
    }

    function handleSelectChange(e) {
        setError('');
        //console.log(user)
        //console.log(location.state)
        setQuestionnaireID(e.target.value)
    }

    {
        !questionnaireID && setQuestionnaireID(1);
    }

    return (
        <main className="container add-prontuario">
            <div>
                <header className="index">
                    <b>{user[location.state.hospitalIndex].hospitalName}</b>
                </header>
                <h2>Adicionar novo prontuário</h2>
            </div>
            <form noValidate autoComplete="off" onSubmit={handleSubmit}>
                <TextField name="prontuario" label="Número do prontuário" type="number" onChange={handleChange} />
                <br/>
                <InputLabel className="qstLabel" style={{marginTop: 25 + "px", marginBottom: 10 + "px"}}>Questionário:</InputLabel>
                <br/>
                <br/>
                <Select native label="Questionnaire" aria-label="Questionnaire" onChange={handleSelectChange} inputProps={styles}>
                    {questionnaires.map( (questionnaire, index) => (
                        questionnaire.questionnaireStatus === "Publicado" && <option key={questionnaire.questionnaireID} value={questionnaire.questionnaireID}>{ questionnaire.description }</option>
                    ))}
                </Select>    
                <div className="submit-prontuario">
                    <span className="error">{ error }</span>
                    <span className="success">{ success }</span>
                    <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={!prontuario}>
                        { !loading &&
                            'Registrar'
                        }
                        { loading &&
                            <CircularProgress color="white"/>
                        }
                    </Button>
                </div>
            </form>
        </main>
    );
}

export default connect(state => ({ user: state.user }))(AddProntuario);