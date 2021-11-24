import React, { useState, useEffect } from 'react';
import { useHistory, useLocation } from "react-router-dom";
import api from '../../services/api';
import ReactDOM from 'react-dom';
import { TextField, Button, InputLabel, FormLabel, Select, CircularProgress } from '@material-ui/core';
import { Add, Edit } from '@material-ui/icons';
import './styles.css';

import { connect } from 'react-redux';

const styles = {
    Button: {
      margin: 24,
      marginBottom: 0
    }
};

function AddSurvey({user}) {

    const history = useHistory();

    //console.log("history addsurvey", history);

    const location = useLocation();

    //console.log("history addsurvey", location);

    const [formError, setFormError] = useState('')

    const [survey, setSurvey] = useState('');

    const [creationDate, setCreationDate] = useState('');

    const [loading, setLoading] = useState(false);

    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    function convertToDate(somedate){
        return String(somedate.getFullYear()+
              "-"+(somedate.getMonth()+1)+
              "-"+somedate.getDate()+
              " "+somedate.getHours()+
              ":"+somedate.getMinutes()+
              ":"+somedate.getSeconds());
    }

    async function handleSubmit(e) {
        e.preventDefault();
        setLoading(true);
       
       const param = {
            userid : user[0].userid,    
            grouproleid : user[0].grouproleid,    
            hospitalunitid : user[0].hospitalunitid,    
            description: survey,
            version: "0.0",
            questionnaireStatusID: "2", // New
            creationDate: creationDate,
            lastModification: creationDate
       }
       console.log("request", param);
       const response = await api.post('/survey', param).catch( function (error) {
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
            history.push("hospital/");
        }
    }

    function handleChange(e) {
        setError('');
        console.log(user)
        console.log("Location pesq", location)
        setSurvey(e.target.value)
        console.log(survey);
        setCreationDate(convertToDate(new Date()));
    }

    return (
        <div>
            <main className="container">
                <div>
                    <h2>Adicione nova pesquisa</h2>
                </div>
                <div>
                 <form className="module" onSubmit={handleSubmit}>
                    <div className="formGroup">
                        <InputLabel>(Versão 0.0) Nome da sua versão: </InputLabel><br/>
                        <TextField name="survey" label="Descrição" onChange={handleChange} value={survey}/>
                    </div>
                    <div className="submit-prontuario">
                        <span className="error">{ error }</span>
                        <span className="success">{ success }</span>
                        <br/>
                        <Button style={styles.Button} variant="contained" type="submit" color="primary" disabled={!survey}>
                            { !loading &&
                                'Registrar nova pesquisa'
                            }
                            { loading &&
                                <CircularProgress color="white"/>
                            }
                        </Button>
                    </div>
                 </form>
                </div>
            </main>
        </div>
    );
}

export default connect(state => ({ user: state.user }))(AddSurvey);